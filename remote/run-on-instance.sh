#!/usr/bin/env bash
# Runs the gateway latency + capacity + resource benchmark on the local docker host.
#
# Designed to run ON the provisioned EC2 instance (invoked by ../run.sh over
# SSH), but it works on any docker host. Two passes:
#
#   Pass A — latency: REPEATS independent trials. Each trial brings up exactly one
#            gateway at a time (no contention), warms it, drives all six request
#            variants, tears it down. Gateway *order is randomized every trial* so
#            no gateway is pinned to the most-favorable slot; results land in
#            results/run<k>/. Aggregation (median + spread across trials) is left
#            to scripts/summarize.py.
#
#   Pass B — capacity + footprint (once): per gateway, measure cold-start latency,
#            image size, a throughput-vs-concurrency sweep (sustained req/s at each
#            concurrency level — true capacity, not latency-coupled), and CPU/mem
#            under sustained load.
#
# Gateways are discovered from gateways/<name>/: a compose.yml (the service, in a
# profile of the same name), a gateway.env (image, port, model, headers, paths)
# and any config file the gateway needs. See gw_load for the contract.
#
# Results are written as JSON to ./results/ for the orchestrator to collect.
#
# NOTE: deliberately NOT `set -e`. This is a resilient benchmark harness — a
# single flaky docker/compose/curl on one variant must not abort the whole run;
# it should skip to the next variant and still reach the final meta.json sentinel
# the orchestrator polls for. Failures are visible in each variant's ok/failed.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"
RESULTS_DIR="$SCRIPT_DIR/results"
GATEWAYS_DIR="$SCRIPT_DIR/gateways"
COMPOSE=(docker compose -p bench)

# Load knobs. Defaults target a non-burstable box (c7i.large); see ../run.sh.
N="${N:-20000}"          # requests per variant (large enough for a stable p99)
C="${C:-10}"             # reference concurrency for the latency pass
REPEATS="${REPEATS:-5}"  # independent latency trials (median + spread)
WARMUP="${WARMUP:-100}"  # global chat warmup after a gateway starts (process/connection init)
WARMUP_VARIANT="${WARMUP_VARIANT:-30}"  # per-variant warmup (per-dialect lazy-import cold start)
RESOURCE_SECONDS="${RESOURCE_SECONDS:-15}"  # sustained-load window for CPU/mem sampling
REST_SECONDS="${REST_SECONDS:-5}"           # settle gap between targets (cooldown)
# Per-variant wall cap: fast variants hit full N in seconds; this only bites the
# idle-bound streaming variants (e.g. Bifrost streams over a non-native backend
# fall back to the 1.5s idle timeout → ~7 req/s, which would take ~50 min for N).
MAX_VARIANT_SECONDS="${MAX_VARIANT_SECONDS:-60}"
SWEEP_CONCURRENCY="${SWEEP_CONCURRENCY:-1 2 4 8 16 32 64 128 256}"  # capacity-sweep points
SWEEP_DURATION="${SWEEP_DURATION:-8}"       # seconds of sustained load per sweep point
GATEWAYS="${GATEWAYS:-$(ls "$GATEWAYS_DIR")}"  # every gateways/<name>/ unless narrowed
BENCH_TOOLS_IMAGE="${BENCH_TOOLS_IMAGE:-bench-tools:local}"
# LiteLLM recommends one worker per CPU core; match the box so it isn't pinned to a
# single core while the Go gateways use all of them. Exported for docker-compose's
# ${LITELLM_NUM_WORKERS} substitution.
export LITELLM_NUM_WORKERS="${LITELLM_NUM_WORKERS:-$(nproc 2>/dev/null || echo 1)}"
export BENCH_TOOLS_IMAGE

AUTH="sk-bench-test-key"

# The six benchmark variants: dialect|mode. Paths come from dialect_path.
VARIANTS=("chat|nonstream" "chat|stream" "responses|nonstream" "responses|stream" "messages|nonstream" "messages|stream")

log() { printf '\n\033[1;34m>>> %s\033[0m\n' "$*"; }

rm -rf "$RESULTS_DIR"; mkdir -p "$RESULTS_DIR"

# ── helpers ────────────────────────────────────────────────────────
# epoch as a float second (python3 is present on AL2023 + macOS; coarse fallback).
epoch() { python3 -c 'import time;print(time.time())' 2>/dev/null || date +%s; }

# shuffle a space-separated list; seed varies per call so trials differ in order.
shuffle() {
  printf '%s\n' $1 | awk -v seed="${2:-$RANDOM}" 'BEGIN{srand(seed)} {print rand()"\t"$0}' \
    | sort -k1,1n | cut -f2- | tr '\n' ' '
}

# json_num FILE KEY: first numeric value of "KEY" in a loadgen summary, or empty.
json_num() { grep -o "\"$2\": *[0-9.]*" "$1" 2>/dev/null | head -1 | grep -o '[0-9.]*$' || true; }

# ── the gateway contract ───────────────────────────────────────────
# gw_load NAME sources gateways/NAME/gateway.env and exposes the loaded gateway as:
#   NAME, SERVICE (compose service; "mock" for the baseline), IMAGE, PORT (in-network),
#   HOST_PORT (published on this host, for probes), MODEL, MESSAGES_PATH, HDR_ARGS
#   (extra "-H 'Name: value'" pairs for loadgen and curl).
# Overrides: <NAME>_IMAGE and <NAME>_HOST_PORT env vars (uppercased name). They are
# exported so the gateway's compose.yml sees the same values.
gw_load() {
  NAME="$1"; SERVICE="$1"; IMAGE=""; PORT=""; MODEL="gpt-4o-mini"; MESSAGES_PATH="/v1/messages"
  local HEADERS=(); HDR_ARGS=()
  if [[ "$NAME" == "baseline" ]]; then SERVICE="mock"; PORT=9999; HOST_PORT=9999; return 0; fi
  [[ -f "$GATEWAYS_DIR/$NAME/gateway.env" ]] || { echo "  ERROR: no gateways/$NAME/gateway.env" >&2; return 1; }
  # shellcheck disable=SC1090
  . "$GATEWAYS_DIR/$NAME/gateway.env"
  local up var; up="$(printf '%s' "$NAME" | tr 'a-z-' 'A-Z_')"
  var="${up}_IMAGE";     IMAGE="${!var:-$IMAGE}"
  var="${up}_HOST_PORT"; HOST_PORT="${!var:-$PORT}"
  export "${up}_IMAGE=$IMAGE" "${up}_HOST_PORT=$HOST_PORT"
  local h; for h in ${HEADERS[@]+"${HEADERS[@]}"}; do HDR_ARGS+=(-H "$h"); done
}

dialect_path() {  # dialect -> request path on the loaded gateway
  case "$1" in chat) echo /v1/chat/completions;; responses) echo /v1/responses;; messages) echo "$MESSAGES_PATH";; esac
}
gw_url() { echo "http://${SERVICE}:${PORT}$(dialect_path "${1:-chat}")"; }  # in-network URL

# loadgen ARGS...: run the load generator against the loaded gateway. It runs in a
# throwaway container on the shared benchnet network so it can reach gateways and
# the mock by service name; the JSON summary comes back on stdout.
loadgen() {
  docker run --rm --network benchnet "$BENCH_TOOLS_IMAGE" /loadgen \
    -model "$MODEL" -auth "$AUTH" -json - "$@" ${HDR_ARGS[@]+"${HDR_ARGS[@]}"}
}

# probe: HTTP status of a real chat request to the loaded gateway via its host port.
probe() {
  curl -s -o /dev/null -w '%{http_code}' -m 5 -X POST \
    "http://localhost:${HOST_PORT}/v1/chat/completions" \
    -H 'Content-Type: application/json' -H "Authorization: Bearer $AUTH" ${HDR_ARGS[@]+"${HDR_ARGS[@]}"} \
    -d "{\"model\":\"$MODEL\",\"messages\":[{\"role\":\"user\",\"content\":\"ping\"}]}" 2>/dev/null || echo 000
}

gw_up()   { "${COMPOSE[@]}" --profile "$NAME" up -d "$NAME" >/dev/null 2>&1 || true; }
# Remove only this gateway's container — NOT `compose down`, which would also
# tear down the profile-less mock and break the next baseline.
gw_down() { "${COMPOSE[@]}" --profile "$NAME" rm -sf "$NAME" >/dev/null 2>&1 || true; }
all_profiles() { local d; for d in "$GATEWAYS_DIR"/*/; do printf -- '--profile %s ' "$(basename "$d")"; done; }

wait_ready() {  # poll the loaded gateway until HTTP 200 (up to tries*2s)
  local tries="${1:-60}" code
  for ((i=0;i<tries;i++)); do
    code="$(probe)"; [[ "$code" == "200" ]] && return 0
    sleep 2
  done
  echo "  WARN: $NAME did not return 200 within $((tries*2))s (last code: ${code:-?})" >&2
  return 1
}

warmup_gateway() { loadgen -url "$(gw_url chat)" -dialect chat -n "$WARMUP" -c "$C" >/dev/null 2>&1 || true; }

# ── measurements ───────────────────────────────────────────────────
run_variant() {  # dialect|mode outfile -> one latency measurement of the loaded gateway
  local dialect mode; IFS='|' read -r dialect mode <<< "$1"
  local outfile="$2"
  local args=(-url "$(gw_url "$dialect")" -dialect "$dialect" -c "$C")
  [[ "$mode" == "stream" ]] && args+=(-stream)
  [[ "$MAX_VARIANT_SECONDS" -gt 0 ]] && args+=(-max-wall "${MAX_VARIANT_SECONDS}s")

  # Per-variant warmup: warm THIS exact dialect+mode before measuring. Python
  # gateways (LiteLLM) lazily import per-dialect translation modules on first use,
  # so a chat-only warmup leaves responses/messages cold and inflates their tails.
  if [[ "$WARMUP_VARIANT" -gt 0 ]]; then
    loadgen "${args[@]}" -n "$WARMUP_VARIANT" >/dev/null 2>&1 || true
  fi
  loadgen "${args[@]}" -n "$N" > "$outfile" 2>/dev/null || true
  printf '    %-8s %-10s %-9s ok=%-6s failed=%s\n' "$NAME" "$dialect" "$mode" \
    "$(json_num "$outfile" ok)" "$(json_num "$outfile" failed)"
}

# run_sweep drives a throughput-vs-concurrency sweep (chat, non-stream) so we can
# read each gateway's saturation point — sustained req/s at each concurrency, via
# loadgen's time-boxed mode (not the latency pass's fixed-N, latency-coupled rps).
run_sweep() {
  mkdir -p "$RESULTS_DIR/sweep"
  local cc out
  for cc in $SWEEP_CONCURRENCY; do
    out="$RESULTS_DIR/sweep/${NAME}_c${cc}.json"
    loadgen -url "$(gw_url chat)" -dialect chat -c "$cc" -duration "${SWEEP_DURATION}s" > "$out" 2>/dev/null || true
    printf '    sweep %-8s c=%-4s rps=%s\n' "$NAME" "$cc" "$(json_num "$out" rps)"
  done
}

# awk program that normalizes a docker-stats MemUsage field to MiB, then prints
# "mem_mb,cpu_pct".
STAT_AWK='
function tomib(s,  v){ v=s; gsub(/[^0-9.]/,"",v); v=v+0;
  if (s ~ /GiB|GB/) return v*1024;
  if (s ~ /MiB|MB/) return v;
  if (s ~ /KiB|kB/) return v/1024;
  if (s ~ /[0-9]B/) return v/1048576;
  return v }
{ split($0,a,";"); mem=a[1]; sub(/ ?\/.*/,"",mem);
  cpu=a[2]; gsub(/[^0-9.]/,"",cpu);
  m=tomib(mem); if (m>0) printf "%.2f,%s\n", m, cpu }'

SAMPLER_PID=""
start_sampler() {  # container csv: sample mem/cpu while the container runs
  local cname="$1" csv="$2"
  echo "mem_mb,cpu_pct" > "$csv"
  (
    while docker ps --format '{{.Names}}' | grep -q "^${cname}$"; do
      docker stats --no-stream --format '{{.MemUsage}};{{.CPUPerc}}' "$cname" 2>/dev/null \
        | awk "$STAT_AWK" >> "$csv" || true
    done
  ) &
  SAMPLER_PID=$!
}
stop_sampler() {
  [[ -n "$SAMPLER_PID" ]] && kill "$SAMPLER_PID" 2>/dev/null || true
  [[ -n "$SAMPLER_PID" ]] && wait "$SAMPLER_PID" 2>/dev/null || true
  SAMPLER_PID=""
}

summarize_resources() {  # csv -> json {peak_mem_mb, avg_mem_mb, avg_cpu_pct, samples}
  [[ -f "$1" ]] || { printf '{"peak_mem_mb":0,"avg_mem_mb":0,"avg_cpu_pct":0,"samples":0}'; return 0; }
  awk -F, 'NR>1 && $1>0 { n++; s_mem+=$1; s_cpu+=$2; if($1>peak)peak=$1 }
    END {
      if(n>0) printf "{\"peak_mem_mb\":%.1f,\"avg_mem_mb\":%.1f,\"avg_cpu_pct\":%.1f,\"samples\":%d}", peak, s_mem/n, s_cpu/n, n;
      else printf "{\"peak_mem_mb\":0,\"avg_mem_mb\":0,\"avg_cpu_pct\":0,\"samples\":0}"
    }' "$1"
}

record_image() {  # -> results/<gw>_image.json (size, digest, version) for the loaded gateway
  local size digest compressed version
  size="$(docker image inspect "$IMAGE" --format '{{.Size}}' 2>/dev/null || echo 0)"
  digest="$(docker image inspect "$IMAGE" --format '{{if .RepoDigests}}{{index .RepoDigests 0}}{{else}}{{.Id}}{{end}}' 2>/dev/null || echo unknown)"
  # Compressed size = what you actually pull/store: gzip the saved image (uniform
  # across locally built and pulled images).
  compressed="$(docker save "$IMAGE" 2>/dev/null | gzip -c | wc -c | tr -d ' ' || echo 0)"
  # Release version: OCI label, else the x.y.z tag sharing this digest on Docker Hub.
  version="$("$SCRIPT_DIR/resolve-version.sh" "$IMAGE" "$digest" 2>/dev/null || true)"
  printf '{"gateway":"%s","image":"%s","version":"%s","size_bytes":%s,"size_mb":%.1f,"compressed_bytes":%s,"compressed_mb":%.1f,"digest":"%s"}\n' \
    "$NAME" "$IMAGE" "$version" "${size:-0}" "$(awk "BEGIN{print ${size:-0}/1048576}")" \
    "${compressed:-0}" "$(awk "BEGIN{print ${compressed:-0}/1048576}")" "$digest" \
    > "$RESULTS_DIR/${NAME}_image.json"
  echo "    image: ${NAME} ${IMAGE} version=${version:-unknown}"
}

# Bring the loaded gateway up and time cold start (compose up -> first HTTP 200).
# Leaves the gateway running. Writes results/<gw>_startup.json.
measure_startup() {
  local t0 t1 ready=0
  t0="$(epoch)"
  gw_up
  for ((i=0;i<600;i++)); do  # up to ~120s, 0.2s resolution
    [[ "$(probe)" == "200" ]] && { ready=1; break; }
    sleep 0.2
  done
  t1="$(epoch)"
  local elapsed; elapsed="$(awk -v a="$t0" -v b="$t1" 'BEGIN{printf "%.3f", b-a}')"
  printf '{"gateway":"%s","startup_s":%s,"ready":%s}\n' "$NAME" "$elapsed" "$ready" \
    > "$RESULTS_DIR/${NAME}_startup.json"
  echo "    startup: ${NAME} ${elapsed}s (ready=$ready)"
}

# Sustained chat load for RESOURCE_SECONDS while the sampler watches the container,
# so CPU/mem are captured under genuine pressure. loadgen's summary is kept so the
# achieved rps shares the exact window the CPU sample covers (summarize.py derives
# a self-consistent rps-per-CPU% efficiency from it).
measure_resources() {
  local cname="bench-${NAME}-1"
  local csv="$RESULTS_DIR/${NAME}_resources.csv" load_json="$RESULTS_DIR/${NAME}_sustained.json"
  local idle_mem res
  idle_mem="$(docker stats --no-stream --format '{{.MemUsage}};0' "$cname" 2>/dev/null | awk "$STAT_AWK" | cut -d, -f1 || true)"
  start_sampler "$cname" "$csv"
  loadgen -url "$(gw_url chat)" -dialect chat -duration "${RESOURCE_SECONDS}s" -c "$C" > "$load_json" 2>/dev/null || true
  stop_sampler
  res="$(summarize_resources "$csv")"
  printf '{"gateway":"%s","idle_mem_mb":%s,"load_rps":%s,"under_load":%s}\n' \
    "$NAME" "${idle_mem:-0}" "$(json_num "$load_json" rps | sed 's/^$/0/')" "$res" > "$RESULTS_DIR/${NAME}_resources.json"
  echo "    resources: idle=${idle_mem:-0}MiB load_rps=$(json_num "$load_json" rps) $res"
}

# ── Build the bench-tools image ────────────────────────────────────
log "Building bench-tools image"
docker build -q -t "$BENCH_TOOLS_IMAGE" ./bench-tools >/dev/null

# ── Validate gateways, pull their images (digests recorded per gateway) ──
# A locally built tag (GOMODEL_SOURCE=... in ../run.sh) fails to pull and is
# used as-is; everything else resolves to the registry's current "latest".
for gw in $GATEWAYS; do
  gw_load "$gw" || exit 1
  docker pull -q "$IMAGE" 2>/dev/null || docker image inspect "$IMAGE" >/dev/null 2>&1 \
    || echo "  WARN: image $IMAGE for $NAME is neither pullable nor present locally" >&2
done

# ── Clean any leftover state, then bring up the shared mock ────────
# shellcheck disable=SC2046
"${COMPOSE[@]}" $(all_profiles) down -v >/dev/null 2>&1 || true
log "Starting mock backend"
"${COMPOSE[@]}" up -d mock
sleep 2

# ── PASS A: latency, REPEATS trials, randomized target order ───────
for r in $(seq 1 "$REPEATS"); do
  RUN_DIR="$RESULTS_DIR/run${r}"; mkdir -p "$RUN_DIR"
  "${COMPOSE[@]}" up -d mock >/dev/null 2>&1 || true  # ensure the shared mock is up
  ORDER="$(shuffle "baseline $GATEWAYS" "$((r * 7919 + RANDOM))")"
  log "Latency trial ${r}/${REPEATS}  (order: ${ORDER})"
  for t in $ORDER; do
    gw_load "$t"
    if [[ "$t" != "baseline" ]]; then
      gw_up; wait_ready || true; warmup_gateway
    fi
    for spec in "${VARIANTS[@]}"; do
      run_variant "$spec" "$RUN_DIR/${t}_${spec%%|*}_${spec##*|}.json"
    done
    [[ "$t" != "baseline" ]] && gw_down
    sleep "$REST_SECONDS"
  done
done

# ── PASS B: capacity sweep + startup + footprint, once, randomized ─
log "Capacity + footprint pass"
"${COMPOSE[@]}" up -d mock >/dev/null 2>&1 || true  # ensure the shared mock is up
gw_load baseline; run_sweep   # capacity ceiling of the mock itself, no gateway lifecycle

for gw in $(shuffle "$GATEWAYS"); do
  gw_load "$gw"
  log "Capacity: $NAME  (image: $IMAGE)"
  measure_startup          # brings the gateway up + times cold start
  record_image
  warmup_gateway
  run_sweep
  measure_resources
  gw_down
  sleep "$REST_SECONDS"
done

"${COMPOSE[@]}" down -v >/dev/null 2>&1 || true

# ── Run metadata ───────────────────────────────────────────────────
IMDS_TOKEN="$(curl -s -m 2 -X PUT 'http://169.254.169.254/latest/api/token' -H 'X-aws-ec2-metadata-token-ttl-seconds: 60' 2>/dev/null || true)"
INSTANCE_TYPE_META="$(curl -s -m 2 -H "X-aws-ec2-metadata-token: $IMDS_TOKEN" http://169.254.169.254/latest/meta-data/instance-type 2>/dev/null || true)"
[[ "$INSTANCE_TYPE_META" == *"<"* || -z "$INSTANCE_TYPE_META" ]] && INSTANCE_TYPE_META="unknown"
IMAGES_JSON="$(first=1; for gw in $GATEWAYS; do gw_load "$gw"; [[ $first == 1 ]] || printf ', '; first=0; printf '"%s": "%s"' "$NAME" "$IMAGE"; done)"
cat > "$RESULTS_DIR/meta.json" <<JSON
{
  "date": "$(date -u +%FT%TZ)",
  "harness_commit": "${HARNESS_COMMIT:-unknown}",
  "images": {$IMAGES_JSON},
  "n_requests": $N,
  "max_variant_seconds": $MAX_VARIANT_SECONDS,
  "concurrency": $C,
  "repeats": $REPEATS,
  "litellm_num_workers": $LITELLM_NUM_WORKERS,
  "warmup": $WARMUP,
  "resource_seconds": $RESOURCE_SECONDS,
  "rest_seconds": $REST_SECONDS,
  "sweep_concurrency": "$(echo "$SWEEP_CONCURRENCY" | tr ' ' ',')",
  "sweep_duration_s": $SWEEP_DURATION,
  "gateways": "$(echo $GATEWAYS | tr ' ' ',')",
  "instance_type": "$INSTANCE_TYPE_META",
  "cpus": $(nproc 2>/dev/null || echo 1),
  "kernel": "$(uname -r)"
}
JSON

log "Done. Results in $RESULTS_DIR"
ls -1 "$RESULTS_DIR"
