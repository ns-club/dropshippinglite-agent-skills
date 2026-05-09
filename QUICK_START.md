# NS Client AI Quick Start

This guide explains how to start using the NS Client read-only AI API with local AI tools.

## 1. What You Will Receive

NS Client support will provide:

- Your API base URL

You will generate your own `access_key_id` and `secret` from the NS Client Account page after the skills are installed.

You will use this repository as the skill pack.

## 2. What You Need

For the current one-command installer:

- macOS/Linux:
  - `sh`
  - `curl` or `wget`
  - `unzip`
- Windows:
  - Windows PowerShell or PowerShell 7

You do not need:

- `git`
- `npm`

## 3. Install The Skills

Choose the command for your operating system and paste it into a terminal.

macOS/Linux:

Run:

```sh
curl -fsSL https://raw.githubusercontent.com/ns-club/dropshippinglite-agent-skills/main/install.sh | sh
```

Windows:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; & ([scriptblock]::Create((Invoke-RestMethod 'https://raw.githubusercontent.com/ns-club/dropshippinglite-agent-skills/main/install.ps1')))"
```

If you already downloaded or extracted the package on Windows, you can run either entrypoint:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\install.ps1
```

```cmd
install.cmd
```

The installer will:

- detect supported AI tools on your machine
- install the NS Client skills into all detected tools
- keep other non-NS Client skills untouched

After installation, restart your AI tool so it reloads the newly installed skills.

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

After installation, open the NS Client Account page, generate your AI credential there, and then use a prompt like this:

```text
I already installed the NS Client skills. Please use them if relevant.

I already generated my NS Client AI credential from the NS Client Account page.

If local NS Client credentials are not configured yet, ask me for:
- Base URL
- access_key_id from my NS Client Account page
- secret from my NS Client Account page

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

Credential notes:

- `secret` is shown only once when you generate it or refresh it
- save it immediately in a secure place
- refreshing the secret immediately invalidates the previous secret

Typical local config locations:

- Windows:
  - `%USERPROFILE%\.ns-client\ai-api.json`
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

### Product SKU prices

```text
Find a product by title first if needed. Then show me the available SKU price filters for that product and get the SKU prices for quantity 1 in the US.
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
