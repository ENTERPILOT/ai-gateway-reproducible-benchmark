#!/usr/bin/env bash
# Print the release version of a pulled gateway image, or nothing if unknown.
#
#   resolve-version.sh IMAGE_REF [DIGEST]
#
# 1. the OCI label org.opencontainers.image.version on the local image
# 2. Docker Hub: the most specific x.y.z tag that shares the image's digest
#    (covers images without a version label, e.g. litellm/litellm, maximhq/bifrost)
set -uo pipefail
ref="$1"; digest="${2:-}"

v="$(docker image inspect "$ref" --format '{{index .Config.Labels "org.opencontainers.image.version"}}' 2>/dev/null || true)"
if [[ -n "$v" ]]; then echo "${v#v}"; exit 0; fi

[[ -n "$digest" ]] || digest="$(docker image inspect "$ref" --format '{{if .RepoDigests}}{{index .RepoDigests 0}}{{end}}' 2>/dev/null || true)"
digest="${digest##*@}"
repo="${ref%%@*}"; repo="${repo%%:*}"
case "$repo" in
  docker.io/*) repo="${repo#docker.io/}";;
  *.*/*|*:*/*) exit 0;;           # another registry (ghcr.io, quay.io, ...): no lookup
esac
[[ "$repo" == */* ]] || repo="library/$repo"

python3 - "$repo" "$digest" <<'PY'
import json, re, sys, urllib.request
repo, digest = sys.argv[1], sys.argv[2]
if not digest:
    sys.exit(0)
best = ""
for page in range(1, 6):
    url = f"https://hub.docker.com/v2/repositories/{repo}/tags?page_size=100&page={page}&ordering=last_updated"
    try:
        with urllib.request.urlopen(url, timeout=15) as r:
            data = json.load(r)
    except Exception:
        break
    for t in data.get("results", []):
        if t.get("digest") == digest or any(i.get("digest") == digest for i in t.get("images", [])):
            name = t["name"]
            if re.fullmatch(r"v?\d+(\.\d+)+", name) and len(name.lstrip("v")) > len(best):
                best = name.lstrip("v")
    if best or not data.get("next"):
        break
print(best)
PY
