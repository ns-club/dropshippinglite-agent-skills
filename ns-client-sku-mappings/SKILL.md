---
name: ns-client-sku-mappings
description: Map Shopify SKUs to internal NS Client SKUs (NP-codes) via the ns-client AI API. Use when the user needs a Shopify SKU to NP-code lookup table, needs to translate between store SKUs and internal SKUs for purchase orders or inventory queries, or asks which internal product a Shopify variant maps to.
metadata:
  author: ns-client
  version: "0.2.0"
---

# NS Client SKU Mappings

> Read [`../ns-client-ai-shared/SKILL.md`](../ns-client-ai-shared/SKILL.md) first.

## Use This Skill When

- The user asks for the mapping between Shopify SKUs and internal NP-codes
- The user needs a one-shot SKU ↔ NP-code crosswalk table for inventory planning
- The user asks which internal product/SKU a Shopify variant corresponds to

## Do Not Use This Skill When

- The user wants stock quantities or inventory levels
  The current AI API surface does not expose SKU-level stock.
- The user wants purchase order status or received quantities
  Use `ns-client-purchase-orders`.

## Core Concept Mapping

- "Shopify SKU" maps to `shopify_sku` (the SKU string on the store side).
- "NP-code" maps to `np_code` (internal product code, format `NP-xxxxx`).
- "Internal SKU" maps to `internal_sku` (internal child SKU, usually `NP-code_suffix`).
- `linked=false` means the Shopify variant is not yet bound to an internal product.

## Preferred Path

- Use `GET /api/ai/v1/sku_mappings`

## Read Next

- `references/sku-mappings-list.md`

## Troubleshooting

- For integration issues, contact your assigned business representative.
