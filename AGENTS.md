# Working on this repository

## Always benchmark from the latest `main`

Before starting a run, `git fetch` and make sure the working tree is the tip of `main`:

```bash
git checkout main && git pull --ff-only
```

A run records `harness_commit` and is published as a comparison between gateways. Running
from a stale checkout silently produces a run that is wrong in ways the numbers do not
show:

- **Gateways added on `main` are missing.** `GATEWAYS` defaults to the folders under
  `remote/gateways/`, so an older checkout measures an older set and the published table
  drops a competitor without saying so.
- **Metric definitions change.** Peak RAM, for example, became
  `max(idle sample, under-load peak)` — the same raw data summarized by two harness
  versions gives two different published numbers, and the history chart then compares
  values that were never comparable.

If a run has already been made from a stale checkout, do not merge `main` into the results
and publish them as they are: re-summarize the raw data with the current scripts
(`scripts/summarize.py`, then `scripts/build_history.py`) and re-measure any gateway the
older checkout did not know about.

## Recording a run

- `./run.sh` records the run and rebuilds the tables and chart; commit `results/<stamp>/`.
- A gateway that was deliberately not re-measured (no new release) may have its raw files
  copied from an earlier run. When you do that, list it in the run's `meta.json` under
  `copied_gateways` (`{"<gateway>": "<source run stamp>"}`). The tables then mark the row
  with a † and footnote where the numbers came from, so a carried-over row is never
  published as a fresh measurement.
- Copy carried-over values from the most recent run that measured that gateway on the same
  hardware and load, not from an arbitrary older one.
