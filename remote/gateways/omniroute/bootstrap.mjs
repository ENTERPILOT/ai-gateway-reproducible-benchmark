// Seeds a fresh OmniRoute with one OpenAI-compatible provider pointing at the mock.
const base = `http://127.0.0.1:${process.env.PORT || 20128}`;
const upstream = process.env.BENCH_UPSTREAM_URL || "http://mock:9999/v1";
const prefix = process.env.BENCH_PROVIDER_PREFIX || "mock";
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const log = (m) => console.log(`[bench-bootstrap] ${m}`);

async function api(path, opts = {}, cookie = "") {
  const r = await fetch(base + path, {
    ...opts,
    headers: { "content-type": "application/json", ...(cookie ? { cookie } : {}), ...(opts.headers || {}) },
  });
  let body = null;
  try { body = await r.json(); } catch {}
  return { status: r.status, body, cookie: r.headers.get("set-cookie") || "" };
}

async function seed() {
  const login = await api("/api/auth/login", { method: "POST", body: JSON.stringify({ password: process.env.INITIAL_PASSWORD }) });
  if (login.status !== 200) throw new Error(`login: ${login.status} ${JSON.stringify(login.body)}`);
  const cookie = login.cookie.split(";")[0];

  const nodes = await api("/api/provider-nodes", {}, cookie);
  let node = (nodes.body?.nodes || []).find((n) => n.prefix === prefix);
  if (!node) {
    const r = await api("/api/provider-nodes", { method: "POST", body: JSON.stringify({ name: prefix, prefix, apiType: "chat", baseUrl: upstream }) }, cookie);
    if (r.status !== 201) throw new Error(`create node: ${r.status} ${JSON.stringify(r.body)}`);
    node = r.body.node;
  }
  const conns = await api("/api/providers", {}, cookie);
  if (!(conns.body?.connections || []).some((c) => c.provider === node.id)) {
    const r = await api("/api/providers", { method: "POST", body: JSON.stringify({ provider: node.id, name: prefix, apiKey: "sk-bench-test-key" }) }, cookie);
    if (r.status !== 200 && r.status !== 201) throw new Error(`create connection: ${r.status} ${JSON.stringify(r.body)}`);
  }
  log(`provider ${node.id} -> ${upstream} ready`);
}

for (let attempt = 1; attempt <= 240; attempt++) {
  try { await seed(); process.exit(0); } catch (e) { if (attempt % 20 === 0) log(`attempt ${attempt}: ${e.message}`); }
  await sleep(500);
}
log("giving up"); process.exit(1);
