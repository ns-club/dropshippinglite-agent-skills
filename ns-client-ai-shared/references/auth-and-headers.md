# Authentication And Headers

## Required Inputs

- Base URL, for example `http://127.0.0.1:8000`
- `access_key_id`
- `secret`

Resolve these inputs from environment variables first, then local config files. See `local-config.md` before asking the user for credentials.

## Authorization Header

Use exactly:

```text
Authorization: Bearer <access_key_id>.<secret>
```

## Validation Example

Prefer the installed shared helper because it reads environment variables and local config files without printing the secret. In many AI hosts, the tool can resolve the helper from the installed skill automatically.

Windows PowerShell:

```powershell
Use the installed NS Client shared helper to request /api/ai/v1/dashboard.
```

macOS/Linux sh:

```sh
Use the installed NS Client shared helper to request /api/ai/v1/dashboard.
```

If the helper is unavailable, a minimal probe is:

```sh
curl -sS \
  -H "Authorization: Bearer ${NS_CLIENT_AI_ACCESS_KEY_ID}.${NS_CLIENT_AI_SECRET}" \
  "${NS_CLIENT_AI_BASE_URL}/api/ai/v1/dashboard"
```

## Important Rules

- Prefer local environment variables over explicit credential values in prompts.
- Prefer local config files over asking the user when environment variables are missing.
- If your AI host can resolve installed skill files automatically, prefer that path instead of manually constructing helper file paths.
- Do not send web JWTs to `/api/ai/v1/*`.
- Do not call `/api/*` browser routes from these skills.
- Do not echo the secret back to the user after it is supplied.
- Use literal credential values in prompts only as a short-lived troubleshooting fallback.
