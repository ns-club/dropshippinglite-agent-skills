# Dropshippinglite Agent Skills

Standalone agent skills for the NS Client read-only AI API.

This repository is designed for customers who use local AI coding tools and want to query their NS Client business data through natural-language requests.

## Included Skills

- `ns-client-ai-shared`
- `ns-client-dashboard`
- `ns-client-invoices`
- `ns-client-products`
- `ns-client-orders`
- `ns-client-billing-logs`

## What This Repository Provides

- A standalone multi-skill pack
- Cross-platform installers for macOS, Linux, and Windows
- No `git` or `npm` requirement for installation
- Shared rules for auth, pagination, rate limits, and error handling
- Optional helper scripts for local credential reuse

## Customer Quick Start

See [QUICK_START.md](./QUICK_START.md).

Recommended customer path: paste the one-command installer for your operating system, restart the AI tool, then ask your first NS Client business question.

## One-Command Install

macOS/Linux:

```sh
curl -fsSL https://raw.githubusercontent.com/ns-club/dropshippinglite-agent-skills/main/install.sh | sh
```

Windows PowerShell:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; & ([scriptblock]::Create((Invoke-RestMethod 'https://raw.githubusercontent.com/ns-club/dropshippinglite-agent-skills/main/install.ps1')))"
```

Windows CMD after downloading or extracting the package:

```cmd
install.cmd
```

Local PowerShell install after downloading or extracting the package:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\install.ps1
```

The installers detect supported AI tools on the current account and install all NS Client skills into each detected tool by default. Existing NS Client skill folders are moved into `.dropshippinglite-agent-skills-backups` before replacement.

The repository folder name is only the delivery package name. The installer copies each `ns-client-*` skill folder into the target tool's skills directory.

## Optional Flags

macOS/Linux examples:

```sh
curl -fsSL https://raw.githubusercontent.com/ns-club/dropshippinglite-agent-skills/main/install.sh | sh -s -- --dry-run
curl -fsSL https://raw.githubusercontent.com/ns-club/dropshippinglite-agent-skills/main/install.sh | sh -s -- --ref main
curl -fsSL https://raw.githubusercontent.com/ns-club/dropshippinglite-agent-skills/main/install.sh | sh -s -- --tool claude_code --tool codex
```

Windows examples:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\install.ps1 -DryRun
powershell -NoProfile -ExecutionPolicy Bypass -File .\install.ps1 -Ref main
powershell -NoProfile -ExecutionPolicy Bypass -File .\install.ps1 -Tool claude_code -Tool codex
```

CMD examples:

```cmd
install.cmd --dry-run
install.cmd --ref main
install.cmd --tool claude_code --tool codex
```

Supported options:

- `--dry-run` / `-DryRun`: show detected tools and planned actions without changing files
- `--ref` / `-Ref`: install from a GitHub branch or tag
- `--tool` / `-Tool`: install only to selected tool key(s); may be repeated
- `--source-dir` / `-SourceDir`: install from a local unpacked repository instead of downloading from GitHub

Use `--dry-run` first when you want to confirm detected tool directories before writing files.

## Tool Support

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

The installer uses directory-based detection and installs to all detected tools by default.
