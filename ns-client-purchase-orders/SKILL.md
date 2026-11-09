---
name: ns-client-purchase-orders
description: Query purchase order (PO) status and received quantities from the ns-client AI API. Use when the user wants to check whether purchased stock has arrived, how many units were received per SKU, purchase order lifecycle status, or order placement times — rather than browsing products, orders, invoices, or wallet logs.
metadata:
  author: ns-client
  version: "0.2.0"
---

# NS Client Purchase Orders

> Read [`../ns-client-ai-shared/SKILL.md`](../ns-client-ai-shared/SKILL.md) first.

## Use This Skill When

- The user asks whether a purchase order has been received
- The user asks for actual received quantities per SKU
- The user asks for purchase order status (purchasing / partially arrived / completed / paid state)
- The user asks when a purchase order was placed or delivered

## Do Not Use This Skill When

- The user wants Shopify SKU to NP-code mapping
  Use `ns-client-sku-mappings`.
- The user wants invoice billing amounts
  Use `ns-client-invoices` (cost fields are not exposed on purchase orders).
- The user wants to create or modify purchase orders
  The current AI API surface is read-only; purchase orders are managed in the web portal.

## Core Concept Mapping

- "Purchase quantity" maps to `purchase_quantity` (per SKU line).
- "Received / arrival quantity" maps to `received_quantity` (per SKU line).
- "Order status" maps to `status` (`pending` / `in_progress` / `done` / `printed_unpaid` / `qa_pass` / `close`).
- "Warehouse status" maps to `warehouse_status` (`warehouse_pending` / `warehouse_part` / `warehouse_done` / `warehouse_part_confirmed`).
- "Payment status" maps to `payment_status` (`unpaid` / `partially_paid` / `fully_paid`).
- All timestamps are in your account timezone.

## Preferred Path

- Use `GET /api/ai/v1/purchase_orders`

## Read Next

- `references/purchase-orders-list.md`

## Troubleshooting

- For integration issues, contact your assigned business representative.
