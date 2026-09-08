# Dotfiles

This repository contains my dotfiles.

To install the dotfiles, execute script: `./install.sh`.

`codex-usage` (or `codex-usage daily`) shows a daily overview of all retained
logs, with session counts, input/cached/output tokens, estimated cost, and a
grand total. Dates use Europe/Amsterdam. Sessions spanning multiple days count
on each active day but only once in the grand total. Days without usage are omitted.
Missing prices mark only the affected days and the grand total as `unknown`.

`codex-usage today` reports today's Codex usage in Europe/Amsterdam;
`codex-usage session <id>` reports a session's totals (a unique ID prefix also works).
Before installing, run `./dotfiles/bin/codex-usage`. Requires Bash and Python 3.9+
with system timezone data; no packages or network access are needed.

The script reads `~/.codex/sessions/**/*.jsonl` (or `$CODEX_HOME/sessions`). It
counts cumulative token increases, ignores duplicate counts and copied logs with
the same session ID, and assigns each increase to its event timestamp's local
date. Input includes cached input; output includes reasoning tokens already
present in the recorded output count. Decreasing counters and malformed records
produce warnings; resets may undercount. Only retained logs are included.

Configure Azure rates per million tokens in `~/.codex/usage-prices.json`, or set
`CODEX_USAGE_PRICES` to another JSON file. Use exact model names from the logs.
For example, replace the illustrative model name and rates below with your own
Azure rates (these are **not actual prices**):

```json
{
  "currency": "EUR",
  "models": {
    "your-model-name": {
      "input_tokens": 2.0,
      "cached_input_tokens": 0.5,
      "output_tokens": 10.0
    }
  }
}
```

Cost uses ordinary input × input rate + cached input × cached rate + cache
writes × write rate + output × output rate. Set `cache_write_input_tokens` to
configure the write rate; it defaults to the input rate when omitted. Input
totals include cached reads and writes, which are subtracted before charging
ordinary input. Missing model pricing makes the total cost `unknown`. Rates apply
to all recorded usage of that model, without tier or historical price adjustments.
The script only reads files. Costs are estimates; Azure billing is authoritative.

The included `dotfiles/.codex/usage-prices.json` configures Luna, Terra, Sol, and
Astra using published Azure Global Standard short-context USD rates, checked
September 8, 2026. The `gpt56sol-datazone-payg` alias uses Sol Standard Data Zone
rates. `codex-auto-review` uses **provisional Sol Global rates** because its
underlying model and actual price are unknown. Reports show these assumptions
when the relevant models have usage. Source URLs are in the pricing file.
Long-context and other service tiers can cost more; these estimates do not
automatically select those rates. Optional per-model `note` fields appear in
the report to explain pricing assumptions.

Run the usage checks with `python3 -B -m unittest discover -s tests`.

Inspired by:
- https://github.com/jqno/dotfiles
- https://github.com/michelgrootjans/dotfiles
- https://github.com/PHillemans/dotFiles
- https://github.com/elijahmanor/youtube-lazyvim
- https://github.com/LazyVim/starter
- https://github.com/LazyVim/LazyVim
