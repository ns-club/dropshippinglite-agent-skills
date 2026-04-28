---
name: ns-client-invoices
description: List and filter customer invoices from the ns-client AI API. Use when the user wants to review invoices, unpaid invoices, invoice totals, invoice counts, or invoice status for a customer account rather than inspect products, orders, dashboard summary data, or wallet logs.
metadata:
  author: ns-client
  version: "0.1.0"
---

# NS Client Invoices

> Read [`../ns-client-ai-shared/SKILL.md`](../ns-client-ai-shared/SKILL.md) first.

## Use This Skill When

- The user asks for invoice lists
- The user asks for unpaid invoices
- The user asks to filter invoices by invoice number, note, financial status, or date
- The user wants invoice totals exactly as shown in the customer portal

## Do Not Use This Skill When

- The user only wants the quick account summary
  Use `ns-client-dashboard` instead.
- The user wants order-level line items or buyer details
  Use `ns-client-orders` instead.
- The user wants to pay, create, export, or modify invoices
  The current AI API surface is read-only.

## Core Concept Mapping

- "Invoice" and "invoice order" both map to the invoice list resource.
- "Unpaid invoices" usually means `financial_status=unpaid`.
- Portal-facing values should be preserved as returned by the API.

## Preferred Path

- Use `GET /api/ai/v1/invoice_orders`

## Read Next

- `references/invoices-list.md`

## Troubleshooting

- For integration issues, contact your assigned business representative.
