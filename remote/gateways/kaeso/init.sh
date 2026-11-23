#!/bin/sh
# First-boot setup of a fresh Kaeso, as its first user would do it in the console: set up the
# install, create a project, add the OpenAI provider key (pointed at the mock by
# KAESO_PROVIDERS_OPENAI_BASE_URL), allow the model in the project, and create an API key. Then
# make that key the bench-only one the harness sends: Kaeso stores only a key's SHA-256, so the
# row the API created gets the declared key's hash, prefix and last four characters.
set -eu
API="$KAESO_URL/platform/v1"
ORIGIN="Origin: $KAESO_ORIGIN"
q() { psql -tAq -v ON_ERROR_STOP=1 -c "$1"; }

# The gateway runs its migrations as it starts; /readyz answers once they're done.
i=0
until wget -q -O /dev/null "$KAESO_URL/readyz"; do
  i=$((i + 1)); [ "$i" -gt 600 ] && { echo "kaeso-init: gateway never became ready" >&2; exit 1; }
  sleep 0.2
done

# `kaeso setup-link` prints a one-time link whose token Kaeso stores as a SHA-256 hash; this is
# the same row, written directly, because the gateway image has no shell to run it from here.
TOKEN="$(head -c 32 /dev/urandom | od -An -tx1 | tr -d ' \n')"
q "INSERT INTO sign_in_tokens (id, kind, token_hash, expires_at)
   VALUES (gen_random_uuid(), 'setup', decode('$(printf %s "$TOKEN" | sha256sum | cut -d' ' -f1)', 'hex'), now() + interval '1 hour')"
wget -S -q -O /dev/null --header "$ORIGIN" --header 'Content-Type: application/json' \
  --post-data "{\"token\":\"$TOKEN\",\"email\":\"owner@example.com\",\"name\":\"Bench\",\"org_name\":\"Bench\",\"password\":\"bench-only-password-1234\"}" \
  "$API/auth/setup" 2>/tmp/headers
COOKIE="$(sed -n 's/^ *[Ss]et-[Cc]ookie: *\([^;]*\).*/\1/p' /tmp/headers | paste -sd';' -)"
[ -n "$COOKIE" ] || { echo "kaeso-init: setup returned no session" >&2; cat /tmp/headers >&2; exit 1; }
post() { wget -q -O "${3:-/dev/null}" --header "$ORIGIN" --header 'Content-Type: application/json' --header "Cookie: $COOKIE" --post-data "$2" "$API$1"; }
# The Platform API names things by public id (org_..., proj_...); pick one field out of a reply.
field() { grep -o "\"$1\":\"[^\"]*\"" "$2" | head -n1 | cut -d'"' -f4; }

wget -q -O /tmp/session --header "$ORIGIN" --header "Cookie: $COOKIE" "$API/auth/session"
ORG="$(field org_id /tmp/session)"
post "/orgs/$ORG/projects" '{"name":"Bench"}' /tmp/project
PROJECT="$(field id /tmp/project)"
post "/orgs/$ORG/credentials" '{"provider":"openai","name":"mock","secret":"sk-bench-test-key"}'
post "/orgs/$ORG/projects/$PROJECT/models" "{\"provider\":\"openai\",\"model_id\":\"$BENCH_MODEL\"}"
post "/orgs/$ORG/projects/$PROJECT/keys" '{"name":"bench"}'

RANDOM_PART="${BENCH_KEY#sk-kso-}"
q "UPDATE api_keys
   SET secret_hash = decode('$(printf %s "$BENCH_KEY" | sha256sum | cut -d' ' -f1)', 'hex'),
       secret_prefix = '$(printf %s "$RANDOM_PART" | cut -c1-6)',
       secret_last4 = '$(printf %s "$RANDOM_PART" | tail -c 4)'
   WHERE name = 'bench'"
echo "kaeso-init: ready"
