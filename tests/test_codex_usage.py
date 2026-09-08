import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest
from datetime import datetime, timedelta
from zoneinfo import ZoneInfo


SCRIPT = Path(__file__).resolve().parents[1] / 'dotfiles/bin/codex-usage'


def event(stamp, inputs, cached, outputs):
    return {'timestamp': stamp, 'type': 'event_msg', 'payload': {
        'type': 'token_count', 'info': {'total_token_usage': {
            'input_tokens': inputs, 'cached_input_tokens': cached,
            'output_tokens': outputs}}}}


class UsageTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.home = Path(self.temp.name)
        (self.home / 'sessions/nested').mkdir(parents=True)

    def write(self, events, name='one', model='test-model'):
        rows = [{'type': 'session_meta', 'payload': {'id': 'session-123'}},
                {'type': 'turn_context', 'payload': {'model': model}}, *events]
        (self.home / f'sessions/nested/{name}.jsonl').write_text(
            ''.join(json.dumps(row) + '\n' for row in rows))

    def run_usage(self, *args):
        return subprocess.run([str(SCRIPT), *args], capture_output=True, text=True,
                              env={**os.environ, 'CODEX_HOME': str(self.home),
                                   'CODEX_USAGE_PRICES': str(self.home / 'prices.json')})

    def test_duplicates_copies_and_recorded_totals(self):
        first = event('2026-09-07T12:00:00Z', 100, 20, 10)
        last = event('2026-09-07T12:01:00Z', 300, 70, 40)
        self.write([first, first, last, last])
        self.write([first, last], name='copy')
        result = self.run_usage('session', 'session-123')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('Input tokens:        300 ', result.stdout)
        self.assertIn('Cached input tokens: 70\n', result.stdout)
        self.assertIn('Output tokens:       40\n', result.stdout)
        self.assertIn('unknown (missing prices: test-model)', result.stdout)

    def test_amsterdam_midnight_uses_delta_from_previous_day(self):
        midnight = datetime.now(ZoneInfo('Europe/Amsterdam')).replace(
            hour=0, minute=0, second=0, microsecond=0)
        def stamp(value):
            return value.astimezone(ZoneInfo('UTC')).isoformat()
        self.write([event(stamp(midnight - timedelta(seconds=1)), 100, 20, 10),
                    event(stamp(midnight + timedelta(seconds=1)), 300, 70, 40)])
        result = self.run_usage('today')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('Input tokens:        200 ', result.stdout)
        self.assertIn('Cached input tokens: 50\n', result.stdout)
        self.assertIn('Output tokens:       30\n', result.stdout)

    def test_model_change_and_cached_pricing(self):
        self.write([event('2026-09-07T12:00:00Z', 1000000, 200000, 100000),
                    {'type': 'turn_context', 'payload': {'model': 'second'}},
                    event('2026-09-07T12:01:00Z', 2000000, 400000, 200000)])
        (self.home / 'prices.json').write_text(json.dumps({'currency': 'EUR', 'models': {
            'test-model': {'input_tokens': 2, 'cached_input_tokens': 1, 'output_tokens': 10},
            'second': {'input_tokens': 4, 'cached_input_tokens': 2, 'output_tokens': 20}}}))
        result = self.run_usage('session', 'session-1')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('EUR 8.400000', result.stdout)
        prices = json.loads((self.home / 'prices.json').read_text())
        del prices['models']['second']
        (self.home / 'prices.json').write_text(json.dumps(prices))
        self.assertIn('unknown (missing prices: second)', self.run_usage('session', 'session-1').stdout)

    def test_cache_writes_use_separate_rate(self):
        row = event('2026-09-07T12:00:00Z', 1000000, 200000, 100000)
        row['payload']['info']['total_token_usage']['cache_write_input_tokens'] = 300000
        self.write([row, row])
        (self.home / 'prices.json').write_text(json.dumps({'models': {
            'test-model': {'input_tokens': 10, 'cached_input_tokens': 1,
                           'cache_write_input_tokens': 12.5, 'output_tokens': 50}}}))
        result = self.run_usage('session', 'session-123')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('USD 13.950000', result.stdout)

    def test_partial_line_and_null_info(self):
        self.write([{'type': 'event_msg', 'payload': {'type': 'token_count', 'info': None}},
                    event('2026-09-07T12:00:00Z', 100, 20, 10)])
        with (self.home / 'sessions/nested/one.jsonl').open('a') as stream:
            stream.write('{"unfinished":')
        result = self.run_usage('session', 'session-123')
        self.assertEqual(result.returncode, 0)
        self.assertIn('Input tokens:        100 ', result.stdout)
        self.assertIn('skipped malformed record', result.stderr)

    def test_empty_and_unknown_session(self):
        self.assertIn('Input tokens:        0 ', self.run_usage('today').stdout)
        self.assertNotEqual(self.run_usage('session', 'missing').returncode, 0)
        self.assertIn('No usage data found.', self.run_usage().stdout)

    def test_daily_default_midnight_duplicates_and_totals(self):
        first = event('2026-09-07T21:59:59Z', 1000000, 200000, 100000)
        last = event('2026-09-07T22:00:01Z', 3000000, 600000, 300000)
        self.write([first, first, last])
        self.write([first, last], name='copy')
        (self.home / 'prices.json').write_text(json.dumps({'models': {
            'test-model': {'input_tokens': 2, 'cached_input_tokens': 1, 'output_tokens': 10}}}))
        result = self.run_usage()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, self.run_usage('daily').stdout)
        rows = [line.split() for line in result.stdout.splitlines()
                if line.startswith(('2026-', 'Total'))]
        self.assertEqual(rows, [
            ['2026-09-07', '1', '1,000,000', '200,000', '100,000', '2.80'],
            ['2026-09-08', '1', '2,000,000', '400,000', '200,000', '5.60'],
            ['Total', '1', '3,000,000', '600,000', '300,000', '8.40']])

    def test_daily_missing_pricing_only_affects_relevant_day(self):
        self.write([event('2026-09-07T12:00:00Z', 1000000, 200000, 100000),
                    {'type': 'turn_context', 'payload': {'model': 'unpriced'}},
                    event('2026-09-08T12:00:00Z', 2000000, 400000, 200000)])
        (self.home / 'prices.json').write_text(json.dumps({'models': {
            'test-model': {'input_tokens': 2, 'cached_input_tokens': 1, 'output_tokens': 10}}}))
        result = self.run_usage('daily')
        rows = [line.split() for line in result.stdout.splitlines()
                if line.startswith(('2026-', 'Total'))]
        self.assertEqual([row[-1] for row in rows], ['2.80', 'unknown', 'unknown'])
        self.assertIn('Missing prices: unpriced.', result.stdout)

    def test_pricing_assumptions_are_visible_for_used_models(self):
        self.write([event('2026-09-07T12:00:00Z', 1000000, 200000, 100000)])
        (self.home / 'prices.json').write_text(json.dumps({'models': {
            'test-model': {'input_tokens': 2, 'cached_input_tokens': 1,
                           'output_tokens': 10, 'note': 'Provisional estimate.'},
            'unused': {'input_tokens': 2, 'cached_input_tokens': 1,
                       'output_tokens': 10, 'note': 'Unused assumption.'}}}))
        result = self.run_usage()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('Pricing note (test-model): Provisional estimate.', result.stdout)
        self.assertNotIn('Unused assumption.', result.stdout)


if __name__ == '__main__':
    unittest.main()
