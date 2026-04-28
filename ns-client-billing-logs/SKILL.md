---
name: ns-client-billing-logs
description: List and filter wallet and billing log entries from the ns-client AI API, including recharge history, wallet transaction records, payment methods, and balance snapshots. Use when the user wants recharge records, wallet history, or billing logs rather than the current dashboard summary, invoice rows, product rows, or order rows.
metadata:
  author: ns-client
  version: "0.1.0"
---

# NS Client Billing Logs

> Read [`../ns-client-ai-shared/SKILL.md`](../ns-client-ai-shared/SKILL.md) first.

## Use This Skill When

- The user asks for recharge history
- The user asks for wallet transaction records
- The user asks for payment method or transaction ID filters
- The user asks for balance snapshots after wallet events

## Do Not Use This Skill When

- The user only wants the current balance or unpaid summary
  Use `ns-client-dashboard`.
- The user wants invoice rows
  Use `ns-client-invoices`.
- The user wants to recharge or change wallet balances
  The current AI API surface is read-only.

## Core Concept Mapping

- "Recharge logs" usually maps to `type_of=charge`.
- "Wallet history" maps to billing logs.
- "Available wallet" and "inventory wallet" map to `wallet_type=available` and `wallet_type=inventory`.

## Preferred Path

- Use `GET /api/ai/v1/billing_logs`

## Read Next

- `references/billing-logs-list.md`

## Troubleshooting

- For integration issues, contact your assigned business representative.
