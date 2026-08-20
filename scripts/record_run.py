#!/usr/bin/env python3
"""Record one benchmark run in results/ and rebuild the history.

    scripts/record_run.py output/20260820-101500

Copies the raw results directory to results/<stamp>/, (re)generates its
summary.json / summary.md with summarize.py, then runs build_history.py so
results/history.json, the charts, and the README tables reflect the new run.
Stdlib only.
"""
import argparse
import os
import shutil
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
RESULTS = os.path.join(ROOT, "results")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("results_dir", help="raw results dir produced by run.sh (output/<stamp>)")
    ap.add_argument("--stamp", help="name under results/ (default: basename of results_dir)")
    ap.add_argument("--force", action="store_true", help="overwrite an existing results/<stamp>")
    args = ap.parse_args()

    src = os.path.abspath(args.results_dir)
    if not os.path.isfile(os.path.join(src, "meta.json")):
        sys.exit(f"{src}: no meta.json — not a complete run")
    stamp = args.stamp or os.path.basename(src.rstrip("/"))
    dst = os.path.join(RESULTS, stamp)
    if os.path.exists(dst):
        if not args.force:
            sys.exit(f"{dst} already exists (use --force to overwrite)")
        shutil.rmtree(dst)

    # Raw per-variant JSON, sweep points, image/startup/resource files, meta.
    shutil.copytree(src, dst, ignore=shutil.ignore_patterns("summary.*", "*.log"))
    subprocess.run([sys.executable, os.path.join(HERE, "summarize.py"), "--results-dir", dst],
                   check=True, stdout=subprocess.DEVNULL)
    subprocess.run([sys.executable, os.path.join(HERE, "build_history.py")], check=True)
    print(f"recorded {stamp} -> {os.path.relpath(dst, ROOT)}")


if __name__ == "__main__":
    main()
