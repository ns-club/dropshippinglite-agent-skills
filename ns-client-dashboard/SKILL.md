---
name: ns-client-dashboard
description: "Get the customer account summary from the ns-client AI API: available balance, inventory balance, unpaid invoice count, unpaid invoice amount, and unconfirmed product count. Use when the user wants a quick wallet or account summary rather than a detailed invoice list, order list, product list, or billing log history."
metadata:
  author: ns-client
  version: "0.1.0"
---

# NS Client Dashboard Summary

> Read [`../ns-client-ai-shared/SKILL.md`](../ns-client-ai-shared/SKILL.md) first.

## Use This Skill When

- The user asks for the current account balance
- The user asks for inventory balance
- The user asks how many unpaid invoices exist
- The user asks for unpaid invoice amount
- The user asks for the unconfirmed product count

## Do Not Use This Skill When

- The user wants the underlying invoice rows
  Use `ns-client-invoices`.
- The user wants wallet transaction history
  Use `ns-client-billing-logs`.
- The user wants product or order detail rows
  Use `ns-client-products` or `ns-client-orders`.

## Core Concept Mapping

- "Balance" means available wallet balance.
- "Inventory balance" means inventory value.
- "Unconfirmed Product Count" maps to the portal summary field with that exact meaning.

## Preferred Path

- Use `GET /api/ai/v1/dashboard`

## Read Next

- `references/dashboard-summary.md`

## Troubleshooting

- For integration issues, contact your assigned business representative.
