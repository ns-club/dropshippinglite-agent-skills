# Local Credential Config

## Resolution Order

Resolve credentials before calling any `/api/ai/v1/*` endpoint:

1. Environment variables:
   - `NS_CLIENT_AI_BASE_URL`
   - `NS_CLIENT_AI_ACCESS_KEY_ID`
   - `NS_CLIENT_AI_SECRET`
2. Explicit config path from `NS_CLIENT_AI_CONFIG`.
3. Repo-local config discovered from the current working directory upward:
   - `.ns-client-ai.local.json`
4. User config:
   - Windows: `%USERPROFILE%\.ns-client\ai-api.json`
   - macOS/Linux: `~/.config/ns-client/ai-api.json`

Environment variables override file values. File values may fill missing environment values.

## Config Format

```json
{
  "base_url": "https://your-base-url",
  "access_key_id": "your_access_key_id",
  "secret": "your_secret"
}
```

Also accept uppercase environment-style keys in JSON for compatibility:

- `NS_CLIENT_AI_BASE_URL`
- `NS_CLIENT_AI_ACCESS_KEY_ID`
- `NS_CLIENT_AI_SECRET`

## Required Workflow

1. Detect the current operating system.
2. Run the installed shared helper for that operating system.
3. Use the helper to check credential status before any business request.
4. If all credentials are resolved, continue with the validation probe and then the business endpoint.
5. If any credential is missing, ask the user for the missing values and persist them for local reuse. Prefer user config by default; use repo-local config only when the user asks for repo-specific credentials.
6. Never print the `secret` or dump the config file contents.

Windows PowerShell status example:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\ai_api_request.ps1 status
```

macOS/Linux status example:

```sh
sh ./scripts/ai_api_request.sh status
```

Run these examples from the installed `ns-client-ai-shared` skill directory, or adapt the helper path to that directory. When the helper is available, use it as the default path instead of building a separate request flow.

## Persist Credentials To Local Config

If the user provides `base_url`, `access_key_id`, and `secret` directly in the conversation and approves local reuse, persist them into local JSON config as the default reuse path.

Environment variables can still be used as a source when they are already present, but they are not required for normal customer onboarding.

Windows PowerShell user config example:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\ai_api_request.ps1 set-from-env --scope user
```

macOS/Linux user config example:

```sh
sh ./scripts/ai_api_request.sh set-from-env --scope user
```

For repo-only storage, replace `--scope user` with `--scope repo`.

The repo-local file `.ns-client-ai.local.json` must remain gitignored.

## API Request Helper

Use the helper as the standard request path so credentials stay out of shell output and the request flow stays consistent across environments.

Windows PowerShell example:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\ai_api_request.ps1 request /api/ai/v1/orders --param page=1 --param per_page=50
```

macOS/Linux example:

```sh
sh ./scripts/ai_api_request.sh request /api/ai/v1/orders --param page=1 --param per_page=50
```

The helper prints only the API response body and errors, not credentials. Use other request methods only when the installed helper is unavailable.
