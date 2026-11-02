// Seeds a fresh LLMGateway with one organization and project, the benchmark's API key, and an
// OpenAI provider key pointing at the mock. It uses the project's own packages, so hashing and
// encryption always match the running release. This is what the dashboard would create; the
// dashboards are not part of the deployment under test.
import { encryptProviderKeyForStorage } from "@llmgateway/actions";
import { db, tables } from "@llmgateway/db";
import { hashApiKeyForStorage } from "@llmgateway/shared/api-key-hash";

await db.insert(tables.user).values({ id: "bench-user", name: "bench", email: "bench@bench.invalid" });
await db.insert(tables.organization).values({
  id: "bench-org",
  name: "bench",
  billingEmail: "bench@bench.invalid",
  retentionLevel: "none", // metadata only: no prompts or completions kept
});
await db.insert(tables.userOrganization).values({ id: "bench-user-org", userId: "bench-user", organizationId: "bench-org" });
// api-keys: the organization's own provider key, no credit accounting. Response cache stays
// at its default (off), so every request reaches the mock.
await db.insert(tables.project).values({ id: "bench-project", name: "bench", organizationId: "bench-org", mode: "api-keys" });
await db.insert(tables.apiKey).values({
  id: "bench-key",
  ...hashApiKeyForStorage("sk-bench-test-key"),
  projectId: "bench-project",
  description: "benchmark",
  createdBy: "bench-user",
});
await db.insert(tables.providerKey).values({
  id: "bench-openai",
  ...encryptProviderKeyForStorage("sk-bench-test-key", "bench-openai", "bench-org"),
  provider: "openai",
  organizationId: "bench-org",
  baseUrl: "http://mock:9999",
});
console.log("[bench-seed] ready");
process.exit(0);
