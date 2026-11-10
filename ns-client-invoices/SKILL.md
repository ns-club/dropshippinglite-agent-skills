---
name: ns-client-invoices
description: List and filter customer invoices from the ns-client AI API, and fetch invoice details with per-package billed amounts for billing reconciliation. Use when the user wants to review invoices, unpaid invoices, invoice totals, invoice counts, invoice status, or a per-package billing breakdown of one invoice rather than inspect products, orders, dashboard summary data, or wallet logs.
metadata:
  author: ns-client
  version: "0.2.0"
---

# NS Client Invoices

> Read [`../ns-client-ai-shared/SKILL.md`](../ns-client-ai-shared/SKILL.md) first.

## Use This Skill When

- The user asks for invoice lists
- The user asks for unpaid invoices
- The user asks to filter invoices by invoice number, note, financial status, or date
- The user wants invoice totals exactly as shown in the customer portal
- The user asks for the billing breakdown of one invoice (per-package billed amounts, tracking numbers, included store orders)
- The user wants to reconcile a billing discrepancy between order-level figures and the invoice total

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
- "Invoice detail" or "billing breakdown" maps to the invoice detail endpoint.
- Portal-facing values should be preserved as returned by the API.

## Preferred Path

- Use `GET /api/ai/v1/invoice_orders` for invoice lists
- Use `GET /api/ai/v1/invoice_orders/:id` for one invoice with its per-package billed amounts

## Read Next

- `references/invoices-list.md`
- `references/invoice-detail.md`

## Troubleshooting

- For integration issues, contact your assigned business representative.
