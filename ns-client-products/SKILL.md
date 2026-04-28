---
name: ns-client-products
description: List and filter customer products from the ns-client AI API, including product status, store, title, Shopify dates, ERP dates, and consumable-binding filters. Use when the user wants to review customer products, approved or confirmed products, or consumable-binding state rather than inspect orders, invoices, dashboard summary data, or wallet logs.
metadata:
  author: ns-client
  version: "0.1.0"
---

# NS Client Products

> Read [`../ns-client-ai-shared/SKILL.md`](../ns-client-ai-shared/SKILL.md) first.

## Use This Skill When

- The user asks for the customer product list
- The user asks for approved, confirmed, or in-progress products
- The user asks which products are bound to consumables
- The user wants to filter products by store, title, Shopify date, or ERP date

## Do Not Use This Skill When

- The user wants order-level costs or buyers
  Use `ns-client-orders`.
- The user wants a simple count of unconfirmed products
  Use `ns-client-dashboard`.
- The user wants to confirm, edit, or bind products
  The current AI API surface is read-only.

## Core Concept Mapping

- "Customer products" and "client products" map to `shopify_products`.
- "Approved products" map to `status=approved`.
- "Confirmed products" map to `status=confirmed`.
- "Bound consumables" maps to `bind_consumables=1`.

## Preferred Path

- Use `GET /api/ai/v1/products`

## Read Next

- `references/products-list.md`

## Troubleshooting

- For integration issues, contact your assigned business representative.
