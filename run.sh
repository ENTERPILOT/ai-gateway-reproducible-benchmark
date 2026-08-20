#!/usr/bin/env bash
# One-command AI gateway benchmark on AWS.
#
#   1. terraform apply  -> one EC2 instance (default c7i.large, NOT free tier)
#   2. wait for SSH + docker, ship the harness
#   3. run the containerized benchmark on the instance:
#        6 request variants x 4 gateways + a no-gateway baseline,
#        REPEATS latency trials + a capacity sweep + footprint measurements
#   4. pull the raw results back, summarize, and record the run in results/
#   5. terraform destroy -> guaranteed teardown (runs even on failure)
#
# Every gateway runs from its public "latest" Docker image, pulled on the
# instance, so the run compares what users actually deploy today.
#
# Usage:  ./run.sh                          # full run, then destroy
#         N=20000 C=10 REPEATS=5 ./run.sh    # (defaults) heavier/lighter load
#         GATEWAYS="gomodel litellm" ./run.sh
#         GOMODEL_SOURCE=../gomodel ./run.sh # build GoModel from a checkout instead
#         INSTANCE_TYPE=t2.micro ./run.sh    # cheaper/burstable (free tier)
#         KEEP=1 ./run.sh                    # don't destroy at the end
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TF_DIR="$SCRIPT_DIR/terraform"
REMOTE_DIR="$SCRIPT_DIR/remote"

TF="${TERRAFORM:-terraform}"
REGION="${REGION:-us-east-1}"
INSTANCE_TYPE="${INSTANCE_TYPE:-c7i.large}"  # 2 vCPU, non-burstable (stable tail); NOT free tier
N="${N:-20000}"
C="${C:-10}"
REPEATS="${REPEATS:-5}"
GATEWAYS="${GATEWAYS:-gomodel litellm portkey bifrost}"
GOMODEL_IMAGE="${GOMODEL_IMAGE:-enterpilot/gomodel:latest}"
GOMODEL_SOURCE="${GOMODEL_SOURCE:-}"   # path to a GoModel checkout; builds + ships a local image
IMAGE_TAR="${TMPDIR:-/tmp}/gomodel-bench-amd64.tar.gz"

STAMP="$(date -u +%Y%m%d-%H%M%S)"
OUT_DIR="$SCRIPT_DIR/output/$STAMP"
HARNESS_COMMIT="$(git -C "$SCRIPT_DIR" rev-parse --short HEAD 2>/dev/null || echo unknown)"

log()  { printf '\n\033[1;34m>>> %s\033[0m\n' "$*"; }
err()  { printf '\033[1;31m!!! %s\033[0m\n' "$*" >&2; }

destroy() {
  if [[ "${KEEP:-0}" == "1" ]]; then
    err "KEEP=1 set — leaving instance up. Destroy later with: (cd $TF_DIR && $TF destroy -auto-approve)"
    return
  fi
  log "Destroying AWS resources (terraform destroy)"
  (cd "$TF_DIR" && $TF destroy -auto-approve -var "region=$REGION" >/dev/null 2>&1) \
    && echo "  teardown complete" || err "TEARDOWN FAILED — check: (cd $TF_DIR && $TF destroy)"
}
trap destroy EXIT

command -v "$TF" >/dev/null || { err "terraform not found (set TERRAFORM=/path/to/terraform)"; exit 1; }
command -v python3 >/dev/null || { err "python3 required to summarize results"; exit 1; }

# ── 1. Optionally build GoModel from source ───────────────────────
if [[ -n "$GOMODEL_SOURCE" ]]; then
  command -v docker >/dev/null || { err "docker required to build GoModel from source"; exit 1; }
  GOMODEL_IMAGE="gomodel-bench:local"
  log "Building GoModel image from $GOMODEL_SOURCE (linux/amd64)"
  docker buildx build --platform linux/amd64 -t "$GOMODEL_IMAGE" --load "$GOMODEL_SOURCE"
  log "Saving image -> $IMAGE_TAR"
  docker save "$GOMODEL_IMAGE" | gzip > "$IMAGE_TAR"
fi

# ── 2. Provision ───────────────────────────────────────────────────
MY_IP="$(curl -s https://checkip.amazonaws.com | tr -d '[:space:]')"
log "Provisioning $INSTANCE_TYPE in $REGION (SSH locked to ${MY_IP}/32)"
(cd "$TF_DIR" && $TF init -input=false >/dev/null && \
  $TF apply -auto-approve -input=false \
    -var "region=$REGION" -var "instance_type=$INSTANCE_TYPE" \
    -var "ssh_ingress_cidr=${MY_IP}/32")

IP="$(cd "$TF_DIR" && $TF output -raw public_ip)"
KEY="$(cd "$TF_DIR" && $TF output -raw ssh_private_key_path)"
USER="$(cd "$TF_DIR" && $TF output -raw ssh_user)"
SSH_OPTS=(-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=10 -i "$KEY")
echo "  instance: $USER@$IP  (key: $KEY)"
[[ -f "$KEY" ]] || { err "private key not found at $KEY"; exit 1; }

# ── 3. Wait for SSH + bootstrap ────────────────────────────────────
log "Waiting for SSH"
for i in $(seq 1 60); do
  ssh "${SSH_OPTS[@]}" "$USER@$IP" true 2>/dev/null && break
  if [[ $i == 60 ]]; then
    err "SSH never came up — last attempt error:"
    ssh "${SSH_OPTS[@]}" "$USER@$IP" true 2>&1 | sed 's/^/    /' || true
    exit 1
  fi
  sleep 5
done
log "Waiting for docker bootstrap (user-data)"
for i in $(seq 1 60); do
  ssh "${SSH_OPTS[@]}" "$USER@$IP" 'test -f ~/.bootstrap-done && docker info >/dev/null 2>&1' && break
  sleep 5
  [[ $i == 60 ]] && { err "docker bootstrap never finished"; exit 1; }
done
echo "  ready"

# ── 4. Ship harness, run ───────────────────────────────────────────
log "Shipping harness to instance"
ssh "${SSH_OPTS[@]}" "$USER@$IP" 'rm -rf ~/bench && mkdir -p ~/bench'
rsync -az -e "ssh ${SSH_OPTS[*]}" --exclude results "$REMOTE_DIR/" "$USER@$IP:~/bench/"
if [[ -n "$GOMODEL_SOURCE" ]]; then
  scp "${SSH_OPTS[@]}" "$IMAGE_TAR" "$USER@$IP:~/gomodel-bench-amd64.tar.gz"
  log "Loading GoModel image on instance"
  ssh "${SSH_OPTS[@]}" "$USER@$IP" 'gunzip -c ~/gomodel-bench-amd64.tar.gz | docker load'
fi

# Forward all benchmark knobs to the instance (only the ones that are set).
REMOTE_ENV="N=$N C=$C REPEATS=$REPEATS GATEWAYS='$GATEWAYS' GOMODEL_IMAGE=$GOMODEL_IMAGE HARNESS_COMMIT=$HARNESS_COMMIT"
for v in LITELLM_IMAGE PORTKEY_IMAGE BIFROST_IMAGE MAX_VARIANT_SECONDS SWEEP_CONCURRENCY SWEEP_DURATION RESOURCE_SECONDS REST_SECONDS WARMUP WARMUP_VARIANT; do
  if [[ -n "${!v:-}" ]]; then REMOTE_ENV="$REMOTE_ENV $v='${!v}'"; fi
done

# Launch DETACHED with setsid so the benchmark survives any SSH drop or hang —
# the controlling session no longer owns the process. We then poll for the
# terminal sentinel (results/meta.json, written only at the very end).
#
# The launching ssh itself can hang after the remote shell returns (seen with
# recent OpenSSH clients), so it runs in the background with a bounded wait:
# what matters is that run-on-instance.sh is alive on the instance, which we
# verify over a fresh connection, then reap the launcher if it is still around.
log "Launching benchmark detached (N=$N C=$C REPEATS=$REPEATS gateways: $GATEWAYS)"
ssh "${SSH_OPTS[@]}" "$USER@$IP" \
  "cd ~/bench && chmod +x run-on-instance.sh && rm -f run.log && \
   setsid env $REMOTE_ENV bash run-on-instance.sh > run.log 2>&1 < /dev/null & disown; echo launched" \
  >/dev/null 2>&1 < /dev/null &
LAUNCH_PID=$!
launched=0
for i in $(seq 1 12); do
  sleep 5
  if ssh "${SSH_OPTS[@]}" "$USER@$IP" 'pgrep -f "[r]un-on-instance.sh" >/dev/null' 2>/dev/null; then
    launched=1; break
  fi
done
kill "$LAUNCH_PID" 2>/dev/null || true
wait "$LAUNCH_PID" 2>/dev/null || true
(( launched == 1 )) || { err "run-on-instance.sh did not start on the instance"; exit 1; }
echo "  running on the instance"

log "Waiting for benchmark (polling every 15s; survives SSH drops)"
POLL_MAX="${POLL_MAX:-400}"   # 400 * 15s = 100 min ceiling (a default run takes ~75 min)
done_ok=0
for ((i=0; i<POLL_MAX; i++)); do
  sleep 15
  if ssh "${SSH_OPTS[@]}" "$USER@$IP" 'test -f ~/bench/results/meta.json' 2>/dev/null; then
    done_ok=1; echo "  benchmark complete (meta.json present)"; break
  fi
  # After warmup, a missing run-on-instance process + no meta = it died; collect partial.
  if (( i > 3 )) && ! ssh "${SSH_OPTS[@]}" "$USER@$IP" 'pgrep -f "[r]un-on-instance.sh" >/dev/null' 2>/dev/null; then
    err "remote benchmark ended without meta.json — collecting partial results"; break
  fi
  if (( i % 4 == 0 )); then
    ssh "${SSH_OPTS[@]}" "$USER@$IP" 'sed "s/\x1b\[[0-9;]*m//g" ~/bench/run.log 2>/dev/null | grep -E ">>>|trial [0-9]/" | tail -2' 2>/dev/null || true
  fi
done
(( done_ok == 1 )) || err "polling ended (timeout or early exit) — proceeding to collect whatever exists"
ssh "${SSH_OPTS[@]}" "$USER@$IP" 'echo "--- tail of remote run.log ---"; tail -25 ~/bench/run.log' 2>/dev/null || true

# ── 5. Collect, summarize, record ──────────────────────────────────
log "Collecting results -> $OUT_DIR"
mkdir -p "$OUT_DIR"
rsync -az -e "ssh ${SSH_OPTS[*]}" "$USER@$IP:~/bench/results/" "$OUT_DIR/"

python3 "$SCRIPT_DIR/scripts/summarize.py" --results-dir "$OUT_DIR" | tee "$OUT_DIR/summary.txt"
if (( done_ok == 1 )); then
  log "Recording run in results/ and rebuilding the history chart"
  python3 "$SCRIPT_DIR/scripts/record_run.py" "$OUT_DIR"
else
  err "incomplete run — not recorded in results/. Raw data kept in $OUT_DIR"
fi
log "Raw results in: $OUT_DIR"
# destroy() runs on EXIT
