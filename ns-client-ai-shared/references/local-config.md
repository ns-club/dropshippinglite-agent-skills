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

## Safe Workflow

1. Run the installed shared helper for the current shell.
2. If all credentials are resolved, continue with the business endpoint.
3. If any credential is missing, ask the user to provide the missing values or set the environment variables locally.
4. If the user wants future reuse, persist credentials to config. Prefer user config by default; use repo-local config only when the user asks for repo-specific credentials.
5. Never print the `secret` or dump the config file contents.

Windows PowerShell status example:

```powershell
Use the installed NS Client shared helper to run the status command.
```

macOS/Linux status example:

```sh
Use the installed NS Client shared helper to run the status command.
```

## Persist From Environment

Ask the user to set environment variables first, then persist without putting secrets in command history.

Windows PowerShell user config example:

```powershell
Use the installed NS Client shared helper to persist credentials from the current environment into user config.
```

macOS/Linux user config example:

```sh
Use the installed NS Client shared helper to persist credentials from the current environment into user config.
```

For repo-only storage, replace `--scope user` with `--scope repo`.

The repo-local file `.ns-client-ai.local.json` must remain gitignored.

## API Request Helper

Use the helper to avoid exposing the Authorization header.

Windows PowerShell example:

```powershell
Use the installed NS Client shared helper to request /api/ai/v1/orders with page and per_page parameters.
```

macOS/Linux example:

```sh
Use the installed NS Client shared helper to request /api/ai/v1/orders with page and per_page parameters.
```

The helper prints only the API response body and errors, not credentials.
