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
- A macOS/Linux one-command installer
- Shared rules for auth, pagination, rate limits, and error handling
- Optional helper scripts for local credential reuse

## Customer Quick Start

See [QUICK_START.md](./QUICK_START.md).

## One-Command Install

macOS/Linux:

```sh
curl -fsSL https://raw.githubusercontent.com/ns-club/dropshippinglite-agent-skills/main/install.sh | sh
```

Windows:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\install.ps1
```

Note: the Windows entrypoint exists now, but Windows installation logic is intentionally deferred to a later phase.

Optional:

- Pin a ref:

```sh
curl -fsSL https://raw.githubusercontent.com/ns-club/dropshippinglite-agent-skills/main/install.sh | sh -s -- --ref main
```

- Preview what would happen:

```sh
curl -fsSL https://raw.githubusercontent.com/ns-club/dropshippinglite-agent-skills/main/install.sh | sh -s -- --dry-run
```

## Tool Support

### Verified

- Codex
- Claude Code
- OpenClaw

### Windows Installer Status

- `install.ps1` is reserved as the official Windows installer entrypoint
- Windows installation logic is not implemented in this phase
- macOS/Linux remain the only fully supported one-command installation targets in phase one

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
