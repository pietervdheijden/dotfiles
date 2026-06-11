#!/usr/bin/env python3
"""Recompute Claude Code spend from transcript token usage x model pricing.

This is the authoritative cost source (the same method claude.ai/ccusage use).
It replaces the statusline's render-time delta summing, which undercounts due to
resume resets and cost-field lag.

Usage:
    recompute_cost.py [--month YYYY-MM] [--day YYYY-MM-DD] [--json]
    recompute_cost.py --summary [--cache SECONDS]
    recompute_cost.py --report      # per-day/month/total breakdown (claude-usage)

--summary prints {"day", "month"} totals (today + current month) in one pass,
for the statusline. --cache reuses a recent result file to stay cheap on
frequent renders. Without a date filter, sums all time (2-decimal USD).

Pricing is pulled from LiteLLM and cached locally, refreshed once a day; a
small built-in table backstops new models and offline use.
"""
import sys
import json
import glob
import os
import re
import time
import urllib.request

# Rates come from LiteLLM's published price map (the source ccusage uses);
# the local copy is refreshed at most once a day. Each tuple is per million
# tokens: input, output, cache-write-5m, cache-write-1h, cache-read.
LITELLM_URL = ("https://raw.githubusercontent.com/BerriAI/litellm/main/"
               "model_prices_and_context_window.json")
PRICING_CACHE = os.path.join(os.path.expanduser("~"), ".claude", "usage",
                             ".pricing-cache.json")
PRICING_TTL = 86400  # refresh daily

# Backstop for models LiteLLM doesn't list yet (brand-new) or when offline.
FALLBACK_PRICING = {
    "claude-opus-4-8":  (5.0,  25.0, 6.25, 10.0, 0.50),
    "claude-opus-4-7":  (5.0,  25.0, 6.25, 10.0, 0.50),
    "claude-opus-4-6":  (5.0,  25.0, 6.25, 10.0, 0.50),
    "claude-opus-4-5":  (5.0,  25.0, 6.25, 10.0, 0.50),
    "claude-sonnet-4-6": (3.0, 15.0, 3.75, 6.0,  0.30),
    "claude-sonnet-4-5": (3.0, 15.0, 3.75, 6.0,  0.30),
    "claude-haiku-4-5": (1.0,  5.0,  1.25, 2.0,  0.10),
}
# Last-resort fallback by family for unrecognized IDs.
FAMILY = [
    ("opus",   (5.0, 25.0, 6.25, 10.0, 0.50)),
    ("sonnet", (3.0, 15.0, 3.75, 6.0,  0.30)),
    ("haiku",  (1.0, 5.0,  1.25, 2.0,  0.10)),
]

_LITELLM = None  # parsed LiteLLM map, loaded once per process


def _fetch_litellm():
    """Return the LiteLLM price map, refreshing the daily cache as needed.

    Never raises: a fresh cache is used without any network call; a stale or
    missing cache triggers a fetch (5s timeout); on failure the last-good
    cache is reused, and callers fall back to FALLBACK_PRICING beyond that.
    """
    try:
        if time.time() - os.path.getmtime(PRICING_CACHE) < PRICING_TTL:
            with open(PRICING_CACHE) as f:
                return json.load(f)
    except (OSError, ValueError):
        pass
    try:
        req = urllib.request.Request(
            LITELLM_URL, headers={"User-Agent": "claude-code-statusline"})
        with urllib.request.urlopen(req, timeout=5) as r:
            data = json.loads(r.read().decode("utf-8"))
        try:
            os.makedirs(os.path.dirname(PRICING_CACHE), exist_ok=True)
            with open(PRICING_CACHE, "w") as f:
                json.dump(data, f)
        except OSError:
            pass
        return data
    except Exception:
        pass
    try:
        with open(PRICING_CACHE) as f:
            return json.load(f)
    except (OSError, ValueError):
        return {}


def _litellm_rate(entry):
    """Per-MTok tuple from a LiteLLM entry, or None if it carries no price."""
    inp = entry.get("input_cost_per_token")
    out = entry.get("output_cost_per_token")
    if inp is None or out is None:
        return None
    cr = entry.get("cache_read_input_token_cost", inp * 0.1)
    cw5 = entry.get("cache_creation_input_token_cost", inp * 1.25)
    cw1 = entry.get("cache_creation_input_token_cost_above_1hr", inp * 2)
    M = 1_000_000
    return (inp * M, out * M, cw5 * M, cw1 * M, cr * M)


def _ensure_litellm():
    """Load (and daily-refresh) the price map once per process, eagerly — so
    the refresh happens whenever the script runs, not only when a priced
    message happens to be found."""
    global _LITELLM
    if _LITELLM is None:
        _LITELLM = _fetch_litellm()


def _strip_date(model):
    # claude-haiku-4-5-20251001 -> claude-haiku-4-5
    return re.sub(r"-\d{8}$", "", model)


def price_for(model):
    if not model:
        return None
    global _LITELLM
    if _LITELLM is None:
        _LITELLM = _fetch_litellm()
    # LiteLLM: exact key, then with the date suffix stripped.
    for key in (model, _strip_date(model)):
        entry = _LITELLM.get(key)
        if entry:
            rate = _litellm_rate(entry)
            if rate:
                return rate
    # Backstop table, then family.
    if model in FALLBACK_PRICING:
        return FALLBACK_PRICING[model]
    if _strip_date(model) in FALLBACK_PRICING:
        return FALLBACK_PRICING[_strip_date(model)]
    for key, p in FAMILY:
        if key in model:
            return p
    return None


def sum_costs(prefix):
    """Sum cost over assistant messages whose timestamp starts with `prefix`.

    Returns (total, per_model). Empty prefix means all-time.
    """
    _ensure_litellm()
    home = os.path.expanduser("~")
    files = glob.glob(os.path.join(home, ".claude", "projects", "**", "*.jsonl"),
                      recursive=True)

    seen = set()  # dedupe by (message.id, requestId)
    total = 0.0
    per_model = {}

    for fp in files:
        try:
            f = open(fp, "r", encoding="utf-8")
        except OSError:
            continue
        with f:
            for line in f:
                line = line.strip()
                if not line or '"usage"' not in line:
                    continue
                try:
                    obj = json.loads(line)
                except ValueError:
                    continue
                if obj.get("type") != "assistant":
                    continue
                ts = obj.get("timestamp", "")
                if prefix and not ts.startswith(prefix):
                    continue
                msg = obj.get("message", {})
                usage = msg.get("usage")
                if not usage:
                    continue
                # Dedupe: same assistant message can appear across resumed
                # transcripts. Key on message id + request id.
                key = (msg.get("id"), obj.get("requestId"))
                if key != (None, None):
                    if key in seen:
                        continue
                    seen.add(key)
                model = msg.get("model")
                p = price_for(model)
                if p is None:
                    continue
                p_in, p_out, p_cw5, p_cw1, p_cr = p

                inp = usage.get("input_tokens", 0) or 0
                out = usage.get("output_tokens", 0) or 0
                cr = usage.get("cache_read_input_tokens", 0) or 0
                # Split cache creation into 5m / 1h for accurate write pricing.
                cc = usage.get("cache_creation") or {}
                cw5 = cc.get("ephemeral_5m_input_tokens")
                cw1 = cc.get("ephemeral_1h_input_tokens")
                if cw5 is None and cw1 is None:
                    # No breakdown: treat all cache creation as 5m.
                    cw5 = usage.get("cache_creation_input_tokens", 0) or 0
                    cw1 = 0
                else:
                    cw5 = cw5 or 0
                    cw1 = cw1 or 0

                cost = (inp * p_in + out * p_out + cr * p_cr
                        + cw5 * p_cw5 + cw1 * p_cw1) / 1_000_000
                total += cost
                per_model[model] = per_model.get(model, 0.0) + cost

    return total, per_model


def summary():
    """Today + current-month totals in a single traversal (statusline path)."""
    import datetime
    _ensure_litellm()
    now = datetime.datetime.now()
    month = now.strftime("%Y-%m")
    day = now.strftime("%Y-%m-%d")

    home = os.path.expanduser("~")
    files = glob.glob(os.path.join(home, ".claude", "projects", "**", "*.jsonl"),
                      recursive=True)
    seen = set()
    month_total = 0.0
    day_total = 0.0

    for fp in files:
        try:
            f = open(fp, "r", encoding="utf-8")
        except OSError:
            continue
        with f:
            for line in f:
                if '"usage"' not in line:
                    continue
                try:
                    obj = json.loads(line)
                except ValueError:
                    continue
                if obj.get("type") != "assistant":
                    continue
                ts = obj.get("timestamp", "")
                if not ts.startswith(month):
                    continue
                msg = obj.get("message", {})
                usage = msg.get("usage")
                if not usage:
                    continue
                key = (msg.get("id"), obj.get("requestId"))
                if key != (None, None):
                    if key in seen:
                        continue
                    seen.add(key)
                p = price_for(msg.get("model"))
                if p is None:
                    continue
                p_in, p_out, p_cw5, p_cw1, p_cr = p
                inp = usage.get("input_tokens", 0) or 0
                out = usage.get("output_tokens", 0) or 0
                cr = usage.get("cache_read_input_tokens", 0) or 0
                cc = usage.get("cache_creation") or {}
                cw5 = cc.get("ephemeral_5m_input_tokens")
                cw1 = cc.get("ephemeral_1h_input_tokens")
                if cw5 is None and cw1 is None:
                    cw5 = usage.get("cache_creation_input_tokens", 0) or 0
                    cw1 = 0
                else:
                    cw5 = cw5 or 0
                    cw1 = cw1 or 0
                cost = (inp * p_in + out * p_out + cr * p_cr
                        + cw5 * p_cw5 + cw1 * p_cw1) / 1_000_000
                month_total += cost
                if ts.startswith(day):
                    day_total += cost
    return day_total, month_total


def _is_user_turn(msg):
    """True if a type==user entry is a real prompt, not just a tool result."""
    content = msg.get("content")
    if isinstance(content, str):
        return content.strip() != ""
    if isinstance(content, list):
        return any(b.get("type") != "tool_result" for b in content
                   if isinstance(b, dict))
    return False


def report():
    """Per-day / per-month / total breakdown from transcripts.

    Returns a list of day dicts with billing-accurate cost and tokens,
    distinct session ids, user-turn count, and per-model cost.
    """
    _ensure_litellm()
    home = os.path.expanduser("~")
    files = glob.glob(os.path.join(home, ".claude", "projects", "**", "*.jsonl"),
                      recursive=True)
    seen = set()       # assistant dedupe: (message.id, requestId)
    seen_turns = set()  # user-turn dedupe: uuid
    days = {}

    def day_rec(date):
        return days.setdefault(date, {
            "date": date, "cost": 0.0, "in": 0, "out": 0,
            "sessions": set(), "turns": 0, "models": {},
        })

    for fp in files:
        try:
            f = open(fp, "r", encoding="utf-8")
        except OSError:
            continue
        with f:
            for line in f:
                if '"timestamp"' not in line:
                    continue
                try:
                    obj = json.loads(line)
                except ValueError:
                    continue
                typ = obj.get("type")
                ts = obj.get("timestamp", "")
                if len(ts) < 10:
                    continue
                date = ts[:10]
                msg = obj.get("message", {})

                if typ == "user":
                    uid = obj.get("uuid")
                    if uid and uid in seen_turns:
                        continue
                    if uid:
                        seen_turns.add(uid)
                    if _is_user_turn(msg):
                        day_rec(date)["turns"] += 1
                    continue
                if typ != "assistant":
                    continue
                usage = msg.get("usage")
                if not usage:
                    continue
                key = (msg.get("id"), obj.get("requestId"))
                if key != (None, None):
                    if key in seen:
                        continue
                    seen.add(key)
                model = msg.get("model")
                p = price_for(model)
                if p is None:
                    continue
                p_in, p_out, p_cw5, p_cw1, p_cr = p
                inp = usage.get("input_tokens", 0) or 0
                out = usage.get("output_tokens", 0) or 0
                cr = usage.get("cache_read_input_tokens", 0) or 0
                cc = usage.get("cache_creation") or {}
                cw5 = cc.get("ephemeral_5m_input_tokens")
                cw1 = cc.get("ephemeral_1h_input_tokens")
                if cw5 is None and cw1 is None:
                    cw5 = usage.get("cache_creation_input_tokens", 0) or 0
                    cw1 = 0
                else:
                    cw5 = cw5 or 0
                    cw1 = cw1 or 0
                cost = (inp * p_in + out * p_out + cr * p_cr
                        + cw5 * p_cw5 + cw1 * p_cw1) / 1_000_000

                d = day_rec(date)
                d["cost"] += cost
                d["in"] += inp + cr + cw5 + cw1   # all input-side tokens
                d["out"] += out
                sid = obj.get("sessionId")
                if sid:
                    d["sessions"].add(sid)
                if model:
                    d["models"][model] = d["models"].get(model, 0.0) + cost

    out = []
    for date in sorted(days):
        d = days[date]
        out.append({
            "date": date, "cost": round(d["cost"], 4),
            "in": d["in"], "out": d["out"],
            "sessions": sorted(d["sessions"]), "turns": d["turns"],
            "models": d["models"],
        })
    return out


def _fmt_tokens(n):
    if n >= 1_000_000:
        return f"{round(n / 1_000_000, 1)}M"
    if n >= 1_000:
        return f"{round(n / 1_000)}K"
    return str(n)


def _top_model(models):
    if not models:
        return "unknown"
    name = max(models, key=lambda k: models[k])
    return name.replace("claude-", "")


def print_report():
    days = report()
    if not days:
        print("No usage data found.")
        return

    def fmt_row(label, cost, sessions, turns, tin, tout, model):
        return (f"  {label}  ${cost:.2f}  {sessions} sessions, "
                f"{turns} turns, {_fmt_tokens(tin)} in, "
                f"{_fmt_tokens(tout)} out, {model}")

    # Group days into months; track distinct sessions per month and overall.
    months = {}
    for d in days:
        m = months.setdefault(d["date"][:7],
                              {"days": [], "sessions": set(), "models": {}})
        m["days"].append(d)
        m["sessions"].update(d["sessions"])
        for k, v in d["models"].items():
            m["models"][k] = m["models"].get(k, 0.0) + v

    tot_sessions, tot_models = set(), {}
    tot_cost = tot_turns = tot_in = tot_out = 0
    lines = []
    for m in sorted(months):
        info = months[m]
        for d in info["days"]:
            lines.append(fmt_row(d["date"], d["cost"], len(d["sessions"]),
                                 d["turns"], d["in"], d["out"],
                                 _top_model(d["models"])))
        m_cost = sum(d["cost"] for d in info["days"])
        m_turns = sum(d["turns"] for d in info["days"])
        m_in = sum(d["in"] for d in info["days"])
        m_out = sum(d["out"] for d in info["days"])
        lines.append(fmt_row(f"{m}  ", m_cost, len(info["sessions"]),
                             m_turns, m_in, m_out, _top_model(info["models"])))
        lines.append("")
        tot_cost += m_cost; tot_turns += m_turns
        tot_in += m_in; tot_out += m_out
        tot_sessions.update(info["sessions"])
        for k, v in info["models"].items():
            tot_models[k] = tot_models.get(k, 0.0) + v

    print("\n".join(lines))
    print(f"Total  ${tot_cost:.2f}  {len(tot_sessions)} sessions, "
          f"{tot_turns} turns, {_fmt_tokens(tot_in)} in, "
          f"{_fmt_tokens(tot_out)} out, {_top_model(tot_models)}")
    if days:
        print(f"\n(from {days[0]['date']} — limited by Claude Code transcript "
              f"retention; older history is pruned)")


def main():
    args = sys.argv[1:]
    month = day = cache_secs = None
    as_json = do_summary = do_report = False
    i = 0
    while i < len(args):
        if args[i] == "--month":
            month = args[i + 1]; i += 2
        elif args[i] == "--day":
            day = args[i + 1]; i += 2
        elif args[i] == "--json":
            as_json = True; i += 1
        elif args[i] == "--summary":
            do_summary = True; i += 1
        elif args[i] == "--report":
            do_report = True; i += 1
        elif args[i] == "--cache":
            cache_secs = float(args[i + 1]); i += 2
        else:
            i += 1

    if do_report:
        print_report()
        return

    if do_summary:
        cache_path = os.path.join(os.path.expanduser("~"), ".claude", "usage",
                                  ".summary-cache.json")
        if cache_secs:
            try:
                import time
                if time.time() - os.path.getmtime(cache_path) < cache_secs:
                    with open(cache_path) as cf:
                        sys.stdout.write(cf.read())
                        return
            except OSError:
                pass
        d, m = summary()
        out = json.dumps({"day": round(d, 4), "month": round(m, 4)})
        try:
            with open(cache_path, "w") as cf:
                cf.write(out)
        except OSError:
            pass
        print(out)
        return

    total, per_model = sum_costs(day or month)
    if as_json:
        print(json.dumps({"total": round(total, 4),
                          "per_model": {k: round(v, 4) for k, v in per_model.items()}}))
    else:
        print(f"{total:.2f}")


if __name__ == "__main__":
    main()
