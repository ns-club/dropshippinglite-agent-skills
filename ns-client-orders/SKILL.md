---
name: ns-client-orders
description: List and filter customer orders from the ns-client AI API, including source unit price, internal product cost, logistics cost, invoice linkage, buyer, and shipping details. Use when the user wants to review orders, order cost lines, buyers, shipping country, invoice-linked orders, or store-specific order lists rather than inspect products, invoices, dashboard summary data, or wallet logs.
metadata:
  author: ns-client
  version: "0.1.0"
---

# NS Client Orders

> Read [`../ns-client-ai-shared/SKILL.md`](../ns-client-ai-shared/SKILL.md) first.

## Use This Skill When

- The user asks for customer orders
- The user asks for order costs or unit price fields
- The user asks for buyer, country, store, or invoice-linked order filters
- The user wants orders for a date range or fulfillment state

## Do Not Use This Skill When

- The user wants invoice rows rather than order rows
  Use `ns-client-invoices`.
- The user wants product catalog data
  Use `ns-client-products`.
- The user wants to import, hide, unhide, or edit orders
  The current AI API surface is read-only.

## Core Concept Mapping

- "Order unit price" maps to `price`.
- "Product cost" maps to `cost`.
- "Total item cost" maps to `total_item_cost`.
- "Total order cost" maps to `margin_total_cost`.
- "Fulfilled orders" can be queried with the public alias `fulfillment_status=fulfilled`.

## Preferred Path

- Use `GET /api/ai/v1/orders`

## Read Next

- `references/orders-list.md`

## Troubleshooting

- For integration issues, contact your assigned business representative.
