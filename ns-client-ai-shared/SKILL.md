---
name: ns-client-ai-shared
description: "Shared rules for the ns-client AI read-only API: credential discovery from environment variables and local config files, safe credential persistence, Authorization header format, validation probe, pagination, date filters, rate-limit handling, error codes, and customer-data safety rules. Use when any ns-client skill needs global auth or execution rules before calling invoices, products, orders, dashboard, or billing logs."
metadata:
  author: ns-client
  version: "0.1.0"
---

# NS Client AI Shared Rules

> Read this skill before using any `ns-client-*` domain skill.

## Shared Responsibilities

- Authentication and credential handling
- Base URL discovery
- Pagination and date defaults
- Rate-limit and retry behavior
- Stable error handling
- Customer-data handling boundaries

## Preconditions

- You need three inputs before calling the API:
  - Base URL
  - `access_key_id`
  - `secret`
- Resolve credentials in this order before asking the user:
  1. Environment variables
  2. Local config files
  3. User-provided credentials
- If the user provides credentials and wants reuse, persist them to the local config file without printing the secret.
- Prefer these environment variables when present:
  - `NS_CLIENT_AI_BASE_URL`
  - `NS_CLIENT_AI_ACCESS_KEY_ID`
  - `NS_CLIENT_AI_SECRET`
- Prefer configured local environment variables over pasting credential values into prompts.
- Prefer the installed shared helper to inspect whether credentials are already resolved, instead of printing live credential values.

## Authentication

- Build the header exactly as:
  - `Authorization: Bearer <access_key_id>.<secret>`
- Never print or restate the secret after it is provided.
- Never recommend pasting live credential values into a prompt when local environment variables are already available.
- Never substitute web JWTs or `/api/*` browser credentials for the AI API.

Read: `references/auth-and-headers.md`
Read credential discovery and persistence rules before asking for credentials: `references/local-config.md`

## Validation Probe

- Before the first business request in a session, validate connectivity and credentials with:
  - `GET /api/ai/v1/dashboard`
- Prefer the installed shared helper for the validation probe so the secret is not printed into shell output.
- If that returns `401` with `code=unauthorized`, stop and ask for valid credentials.

## Read-Only Boundary

- The current skill pack is read-only.
- Only use `/api/ai/v1/*` routes.
- Do not invent write calls such as create, pay, confirm, import, hide, recharge, or update actions.
- If the user asks for a write operation, explain that the current AI API surface is read-only and stop.

## Request Defaults

- Dates must be sent as `YYYY-MM-DD`.
- Unless the user specifies otherwise, start with:
  - `page=1`
  - `per_page=50`
- The current maximum `per_page` is `100`.
- Only send documented parameters. Do not guess hidden filters.

Read: `references/pagination-and-dates.md`

## Rate Limits And Retries

- Read these response headers when present:
  - `X-RateLimit-Limit`
  - `X-RateLimit-Remaining`
  - `X-RateLimit-Reset`
  - `Retry-After`
- If the API returns `429` with `code=rate_limit_exceeded`, wait `Retry-After` seconds and retry once.
- Do not aggressively parallelize page fetches for the same resource.

## Error Handling

- Treat HTTP status as the first classifier.
- Use the JSON `code` field to decide the next action.
- Common cases:
  - `401` + `unauthorized`: credentials are missing or invalid
  - `404` + `resource_not_found`: the requested object does not exist in the current tenant scope
  - `422` + endpoint-specific code: the request shape or filter value is invalid
  - `429` + `rate_limit_exceeded`: back off and retry once
  - `5xx`: stop and report the failure without retry loops

Read: `references/errors-and-retries.md`

## Customer Data Handling

- Treat invoice numbers, transaction IDs, email addresses, buyer names, addresses, and wallet balances as customer data.
- Use standard English in user-facing summaries.
- Summarize results when possible instead of echoing large raw payloads.
- Do not expose credentials in logs, notes, or examples.
- If shell commands are shown, prefer environment-variable references such as `${NS_CLIENT_AI_SECRET}` instead of literal secrets.
- Do not print local config file contents when they contain `secret`.

## Domain Routing

- Use `ns-client-invoices` for invoice lists and invoice filters.
- Use `ns-client-products` for customer product lists and consumable-binding filters.
- Use `ns-client-orders` for order lists and order cost fields.
- Use `ns-client-dashboard` for quick account summary data.
- Use `ns-client-billing-logs` for recharge history and wallet transaction history.

## References

- `references/auth-and-headers.md`
- `references/local-config.md`
- `references/errors-and-retries.md`
- `references/pagination-and-dates.md`

## Troubleshooting

- For integration issues, contact your assigned business representative.
