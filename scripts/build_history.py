#!/usr/bin/env python3
"""Aggregate every recorded run into a history + charts + README tables.

Reads  results/<stamp>/summary.json (one per run, see record_run.py)
Writes results/history.json          one compact record per run
       results/charts/history.svg    headline metrics over time, per gateway
       results/HISTORY.md            per-run tables, newest first
       README.md                     the block between the history markers

Runs on a different instance type than the chart's reference type still land
in history.json and HISTORY.md; the chart only plots like-for-like hardware.
Stdlib only.
"""
import argparse
import glob
import json
import math
import os
from datetime import datetime

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
RESULTS = os.path.join(ROOT, "results")
README = os.path.join(ROOT, "README.md")
MARK_START, MARK_END = "<!-- history:start -->", "<!-- history:end -->"
# Shown under the chart in README.md; a fixed fact about where the history comes from.
MOVE_NOTE = ("> Moved here from the [GoModel repository](https://github.com/ENTERPILOT/GoModel)\n"
             "> (`docs/2026-06-25_aws_gateway_benchmark`) on 20 August 2026. The runs from June and\n"
             "> July 2026 were made with that original harness and are part of the history.")

GATEWAYS = ["gomodel", "bifrost", "portkey", "litellm"]
LABEL = {"gomodel": "GoModel", "bifrost": "Bifrost", "portkey": "Portkey", "litellm": "LiteLLM"}
# Fixed categorical hue per gateway (never cycled), validated for CVD separation.
COLOR = {"gomodel": "#2a78d6", "bifrost": "#eb6834", "portkey": "#1baf7a", "litellm": "#eda100"}
EXTRA_COLORS = ["#e87ba4", "#008300", "#4a3aa7", "#e34948"]


def label(gw):
    return LABEL.get(gw, gw.capitalize())


def color(gw):
    """Known gateways keep their hue; a new gateways/<name>/ gets the next free one."""
    if gw not in COLOR:
        n = len(COLOR) - len(LABEL)
        COLOR[gw] = EXTRA_COLORS[n] if n < len(EXTRA_COLORS) else "#52514e"
    return COLOR[gw]


def ordered(names):
    """Known gateways first, in their usual order, then anything new alphabetically."""
    names = set(names)
    return [g for g in GATEWAYS if g in names] + sorted(g for g in names if g not in GATEWAYS)

# (key, panel title, unit, lower-is-better)
METRICS = [
    ("chat_p50_ms", "Latency p50 · chat, non-stream", "ms", True),
    ("chat_p99_ms", "Latency p99 · chat, non-stream", "ms", True),
    ("peak_rps", "Peak throughput", "req/s", False),
    ("peak_mem_mb", "Peak RAM under load", "MB", True),
    ("startup_s", "Cold start to first 200", "s", True),
    ("image_mb", "Image size, compressed", "MB", True),
]


def load(path):
    try:
        with open(path) as f:
            return json.load(f)
    except (OSError, ValueError):
        return None


def dig(d, *keys):
    for k in keys:
        if not isinstance(d, dict):
            return None
        d = d.get(k)
    return d if isinstance(d, (int, float)) else None


def run_date(stamp, meta):
    if meta.get("date"):
        return meta["date"]
    # legacy runs: stamp is YYYYMMDD-HHMMSS (UTC)
    return datetime.strptime(stamp, "%Y%m%d-%H%M%S").strftime("%Y-%m-%dT%H:%M:%SZ")


def record(stamp, summary):
    meta = summary.get("meta") or {}
    rec = {
        "run": stamp,
        "date": run_date(stamp, meta),
        "instance_type": meta.get("instance_type"),
        "cpus": meta.get("cpus"),
        "n_requests": meta.get("n_requests"),
        "concurrency": meta.get("concurrency"),
        "repeats": meta.get("repeats", summary.get("trials")),
        "litellm_num_workers": meta.get("litellm_num_workers", 1),
        "harness_commit": meta.get("harness_commit"),
        "gateways": {},
    }
    for gw in ordered(g for g in (summary.get("latency") or {}) if g != "baseline"):
        lat = (summary.get("latency") or {}).get(gw)
        if not lat:
            continue
        res = (summary.get("resources") or {}).get(gw) or {}
        cap = (summary.get("capacity") or {}).get(gw) or {}
        variants = {k: v for k, v in lat.items() if v and v.get("ok")}
        rec["gateways"][gw] = {
            "image": (res.get("image") or {}).get("image"),
            "version": (res.get("image") or {}).get("version") or None,
            "digest": (res.get("image") or {}).get("digest"),
            "image_mb": dig(res, "image", "compressed_mb"),
            "startup_s": dig(res, "startup", "startup_s"),
            "idle_mem_mb": dig(res, "resources", "idle_mem_mb"),
            "peak_mem_mb": dig(res, "resources", "under_load", "peak_mem_mb"),
            "avg_cpu_pct": dig(res, "resources", "under_load", "avg_cpu_pct"),
            "rps_per_cpu_pct": res.get("rps_per_cpu_pct"),
            "peak_rps": cap.get("peak_rps"),
            "chat_p50_ms": dig(lat, "chat/nonstream", "p50"),
            "chat_p99_ms": dig(lat, "chat/nonstream", "p99"),
            "chat_overhead_p50_ms": dig(lat, "chat/nonstream", "overhead_p50"),
            "chat_stream_ttft_p50_ms": dig(lat, "chat/stream", "ttft_p50"),
            "variants_served": f"{len(variants)}/{len(lat)}",
        }
    return rec


def fmt(v, dp=1):
    if v is None:
        return "—"
    if isinstance(v, float) and v >= 1000:
        return f"{v:,.0f}"
    return f"{v:,.{dp}f}" if isinstance(v, float) else f"{v:,}"


def short_date(iso):
    return iso[:10]


# ── SVG chart ─────────────────────────────────────────────────────────────────
def nice_log_ticks(lo, hi):
    """1-2-5 ticks covering [lo, hi] on a log10 axis."""
    ticks = []
    e = math.floor(math.log10(lo))
    while 10 ** e <= hi * 1.0001:
        for m in (1, 2, 5):
            v = m * 10 ** e
            if lo * 0.999 <= v <= hi * 1.001:
                ticks.append(v)
        e += 1
    return ticks


def esc(s):
    return str(s).replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")


def tick_label(v):
    return f"{v:g}" if v < 1000 else f"{v/1000:g}k"


def panel(x0, y0, w, h, title, unit, runs, key, lower_better):
    """One small-multiple: log-y line chart of `key` per gateway over runs."""
    pad_l, pad_r, pad_t, pad_b = 44, 70, 44, 34
    px, py = x0 + pad_l, y0 + pad_t
    pw, ph = w - pad_l - pad_r, h - pad_t - pad_b

    series = {}
    for gw in ordered(g for r in runs for g in r["gateways"]):
        pts = [(i, r["gateways"].get(gw, {}).get(key)) for i, r in enumerate(runs)]
        pts = [(i, v) for i, v in pts if isinstance(v, (int, float)) and v > 0]
        if pts:
            series[gw] = pts
    vals = [v for pts in series.values() for _, v in pts]
    out = [f'<text x="{px}" y="{y0 + 16}" class="ttl">{esc(title)}</text>',
           f'<text x="{px}" y="{y0 + 31}" class="sub">'
           f'{esc(unit)} · log scale · {"lower" if lower_better else "higher"} is better</text>']
    if not vals:
        out.append(f'<text x="{px + pw / 2}" y="{py + ph / 2}" class="sub" text-anchor="middle">no data</text>')
        return "\n".join(out)

    lo, hi = min(vals), max(vals)
    steps = nice_log_ticks(10 ** math.floor(math.log10(lo)), 10 ** math.ceil(math.log10(hi)))
    lo_e = max(t for t in steps if t <= lo * 1.0001)
    hi_e = min(t for t in steps if t >= hi * 0.9999)
    if lo_e == hi_e:
        hi_e *= 10
    ly = lambda v: py + ph - (math.log10(v) - math.log10(lo_e)) / (math.log10(hi_e) - math.log10(lo_e)) * ph
    n = len(runs)
    lx = lambda i: px + (pw / 2 if n == 1 else i * pw / (n - 1))

    for t in nice_log_ticks(lo_e, hi_e):
        y = ly(t)
        out.append(f'<line x1="{px}" y1="{y:.1f}" x2="{px + pw}" y2="{y:.1f}" class="grid"/>')
        out.append(f'<text x="{px - 6}" y="{y + 3:.1f}" class="tick" text-anchor="end">{tick_label(t)}</text>')
    out.append(f'<line x1="{px}" y1="{py + ph}" x2="{px + pw}" y2="{py + ph}" class="axis"/>')
    seen = {}
    for i, r in enumerate(runs):
        d = short_date(r["date"])
        seen[d] = seen.get(d, 0) + 1
    for i, r in enumerate(runs):
        d = short_date(r["date"])
        label = datetime.strptime(d, "%Y-%m-%d").strftime("%b %-d")
        if seen[d] > 1:
            label += " " + r["date"][11:16]
        out.append(f'<text x="{lx(i):.1f}" y="{py + ph + 16}" class="tick" text-anchor="middle">{label}</text>')

    # end labels, de-overlapped top-to-bottom
    ends = []
    for gw, pts in series.items():
        path = " ".join(f'{"M" if k == 0 else "L"}{lx(i):.1f},{ly(v):.1f}' for k, (i, v) in enumerate(pts))
        out.append(f'<path d="{path}" class="line" stroke="{color(gw)}"/>')
        for i, v in pts:
            out.append(f'<circle cx="{lx(i):.1f}" cy="{ly(v):.1f}" r="4" fill="{color(gw)}" class="dot"/>')
        i, v = pts[-1]
        ends.append([ly(v), gw, v, lx(i)])
    ends.sort()
    for k in range(1, len(ends)):
        ends[k][0] = max(ends[k][0], ends[k - 1][0] + 13)
    for k in range(len(ends) - 2, -1, -1):  # push back up if we ran off the bottom
        ends[k][0] = min(ends[k][0], ends[k + 1][0] - 13)
    for y, gw, v, x in ends:
        out.append(f'<text x="{px + pw + 8}" y="{y + 4:.1f}" class="lbl">'
                   f'<tspan fill="{color(gw)}">●</tspan> {fmt(v, 2 if v < 10 else 1 if v < 100 else 0)}</text>')
    return "\n".join(out)


def build_svg(runs, instance_type, path):
    cols, rows = 3, 2
    W, PH = 1080, 262
    top = 88
    H = top + rows * PH + 16
    legend = "".join(
        f'<g transform="translate({16 + k * 110},64)"><circle cx="6" cy="-4" r="5" fill="{color(gw)}"/>'
        f'<text x="16" y="0" class="lg">{label(gw)}</text></g>'
        for k, gw in enumerate(ordered(g for r in runs for g in r["gateways"])))
    first, last = short_date(runs[0]["date"]), short_date(runs[-1]["date"])
    sub = (f"{len(runs)} run{'s' if len(runs) != 1 else ''} on AWS {instance_type} · {first} → {last} · "
           "latest public Docker image of each gateway · same mock backend, so numbers are gateway overhead")
    out = [f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}" width="{W}" height="{H}" '
           'font-family="-apple-system, BlinkMacSystemFont, Segoe UI, Helvetica, Arial, sans-serif">',
           '<style>.ttl{font-size:13px;font-weight:600;fill:#0b0b0b}.sub{font-size:10.5px;fill:#52514e}'
           '.tick{font-size:10.5px;fill:#52514e}.lbl{font-size:11px;fill:#0b0b0b}.lg{font-size:12px;fill:#0b0b0b}'
           '.grid{stroke:#e6e6e3;stroke-width:1}.axis{stroke:#c3c2b7;stroke-width:1}'
           '.line{fill:none;stroke-width:2;stroke-linejoin:round;stroke-linecap:round}'
           '.dot{stroke:#fcfcfb;stroke-width:2}.h1{font-size:17px;font-weight:700;fill:#0b0b0b}</style>',
           f'<rect width="{W}" height="{H}" fill="#fcfcfb"/>',
           '<text x="16" y="26" class="h1">AI gateway benchmark over time</text>',
           f'<text x="16" y="42" class="sub">{esc(sub)}</text>',
           legend]
    pw = (W - 32) / cols
    for k, (key, title, unit, lower) in enumerate(METRICS):
        cx, cy = 16 + (k % cols) * pw, top + (k // cols) * PH
        out.append(panel(cx, cy, pw, PH, title, unit, runs, key, lower))
    out.append("</svg>")
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w") as f:
        f.write("\n".join(out))


# ── Markdown ──────────────────────────────────────────────────────────────────
def run_table(rec):
    L = ["| Gateway | Version | Image | p50 (ms) | p99 (ms) | Peak req/s | Peak RAM (MB) | Cold start (s) | Image (MB) | Variants |",
         "|---|---|---|--:|--:|--:|--:|--:|--:|:-:|"]
    for gw, g in rec["gateways"].items():
        img = (g.get("image") or "?").split("@")[0]
        L.append(f"| {label(gw)} | {g.get('version') or '—'} | `{img}` | {fmt(g['chat_p50_ms'], 2)} | {fmt(g['chat_p99_ms'], 2)} | "
                 f"{fmt(g['peak_rps'], 0)} | {fmt(g['peak_mem_mb'])} | {fmt(g['startup_s'], 2)} | "
                 f"{fmt(g['image_mb'])} | {g['variants_served']} |")
    return "\n".join(L)


def run_caption(rec):
    return (f"`{rec['run']}` · {short_date(rec['date'])} · AWS **{rec['instance_type']}** "
            f"({rec['cpus']} vCPU) · N={fmt(rec['n_requests'])} per variant · c={rec['concurrency']} · "
            f"{rec['repeats']} trial(s) · LiteLLM workers={rec['litellm_num_workers']}")


def write_history_md(records, path):
    L = ["# Run history", "",
         "Newest first. Latency is chat/completions non-streaming, median across trials. "
         "Peak req/s comes from the capacity sweep, RAM from `docker stats` under sustained load. "
         "Raw data for each run is in the directory named after it; `history.json` holds the same "
         "numbers in machine-readable form.", "",
         "![History chart](charts/history.svg)", ""]
    for rec in reversed(records):
        L += [f"## {short_date(rec['date'])} — {rec['run']}", "", run_caption(rec), "",
              run_table(rec), "",
              f"Full tables: [`{rec['run']}/summary.md`]({rec['run']}/summary.md)", ""]
    with open(path, "w") as f:
        f.write("\n".join(L))


def update_readme(latest, n_runs):
    if not os.path.isfile(README):
        return
    with open(README) as f:
        text = f.read()
    if MARK_START not in text or MARK_END not in text:
        return
    block = "\n".join([MARK_START,
                       "![History chart](results/charts/history.svg)", "",
                       MOVE_NOTE, "",
                       f"Latest run — {run_caption(latest)}", "",
                       run_table(latest), "",
                       f"All {n_runs} runs: [results/HISTORY.md](results/HISTORY.md) · "
                       "machine-readable: [results/history.json](results/history.json)",
                       MARK_END])
    head, rest = text.split(MARK_START, 1)
    _, tail = rest.split(MARK_END, 1)
    with open(README, "w") as f:
        f.write(head + block + tail)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--instance-type", help="hardware to chart (default: the latest run's)")
    args = ap.parse_args()

    records = []
    for sp in sorted(glob.glob(os.path.join(RESULTS, "*", "summary.json"))):
        stamp = os.path.basename(os.path.dirname(sp))
        s = load(sp)
        if s:
            records.append(record(stamp, s))
    if not records:
        raise SystemExit("no results/*/summary.json found")
    records.sort(key=lambda r: r["date"])

    with open(os.path.join(RESULTS, "history.json"), "w") as f:
        json.dump(records, f, indent=2)

    inst = args.instance_type or records[-1]["instance_type"]
    charted = [r for r in records if r["instance_type"] == inst]
    build_svg(charted, inst, os.path.join(RESULTS, "charts", "history.svg"))
    write_history_md(records, os.path.join(RESULTS, "HISTORY.md"))
    update_readme(records[-1], len(records))
    print(f"history: {len(records)} runs ({len(charted)} charted on {inst}) -> results/history.json, "
          "results/charts/history.svg, results/HISTORY.md")


if __name__ == "__main__":
    main()
