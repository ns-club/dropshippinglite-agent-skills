# NS Client AI Quick Start

This guide explains how to start using the NS Client read-only AI API with local AI tools.

## 1. What You Will Receive

NS Client support will provide:

- Your API base URL
- Your `access_key_id`
- Your `secret`

You will use this repository as the skill pack.

## 2. What You Need

For the current one-command installer:

- macOS or Linux
- `sh`
- `curl` or `wget`
- `unzip`

You do not need:

- `git`
- `npm`

Windows note:

- This repository already includes `install.ps1` as the official Windows installer entrypoint.
- Windows installation logic is intentionally deferred to a later phase.

## 3. Install The Skills

macOS/Linux:

Run:

```sh
curl -fsSL https://raw.githubusercontent.com/ns-club/dropshippinglite-agent-skills/main/install.sh | sh
```

Windows:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\install.ps1
```

The installer will:

- detect supported AI tools on your machine
- install the NS Client skills into all detected tools
- keep other non-NS Client skills untouched

## 4. Supported Tools

### Verified

- Codex
- Claude Code
- OpenClaw

### Best Effort

- Cursor
- Antigravity
- OpenClaude
- OpenCode
- Continue
- Gemini CLI
- GitHub Copilot
- Qwen Code
- Windsurf

## 5. First Use

After installation, open your AI tool and use a prompt like this:

```text
I already installed the NS Client skills. Please use them if relevant.

If local NS Client credentials are not configured yet, ask me for:
- Base URL
- access_key_id
- secret

After I provide them, save them locally for reuse and do not print the secret in your final response.

Then validate connectivity and show me the current dashboard summary.
```

## 6. What Happens Next

If local credentials do not exist yet:

- the AI tool should ask for:
  - Base URL
  - `access_key_id`
  - `secret`
- after you approve it, the AI tool can save them to local configuration
- future requests should reuse that local configuration

Typical local config locations:

- macOS/Linux:
  - `~/.config/ns-client/ai-api.json`
- repo-local optional config:
  - `.ns-client-ai.local.json`

## 7. Example Business Prompts

### Dashboard

```text
Show me the current NS Client account summary.
I want:
- available balance
- inventory balance
- unpaid invoice count
- unpaid invoice amount
- unconfirmed product count
```

### Latest invoices

```text
Get the latest 20 invoices for my account and summarize them in English.
```

### Latest orders

```text
Get the first 50 recent orders for my account and summarize the key cost fields in English.
```

### Billing logs

```text
Get the first 50 billing log rows for my account and summarize the payment methods and wallet types in English.
```

## 8. Troubleshooting

### 401 Unauthorized

Possible causes:

- wrong `access_key_id`
- wrong `secret`
- disabled or rotated credential

Ask NS Client support for a valid credential if needed.

### 422 Invalid Request

Possible causes:

- invalid date
- invalid filter value
- invalid page size

Try a simpler request first.

### 429 Rate Limit Exceeded

Wait and retry later.

### No Tools Detected

The installer only installs to detected tool directories. Make sure the target AI tool is installed on your machine first.
