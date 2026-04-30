---
name: ns-client-products
description: List and filter customer products from the ns-client AI API, including product status, store, title, Shopify dates, ERP dates, consumable-binding filters, SKU price filters, and SKU price lookups for a specific product. Use when the user wants to review customer products, approved or confirmed products, consumable-binding state, or SKU prices rather than inspect orders, invoices, dashboard summary data, or wallet logs.
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
- The user wants SKU price filters for a specific product
- The user wants SKU prices for a specific product, optionally by country, title, quantity, or page

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
- "SKU price filters" maps to available `titles` and `country_codes` for one product.
- "SKU prices" maps to product variant shipping price rows for one product.

## Preferred Path

- Use `GET /api/ai/v1/products`
- Use `GET /api/ai/v1/products/:id/sku_price_filters` before a targeted SKU price lookup when the user does not already know valid titles or country codes.
- Use `GET /api/ai/v1/products/:id/sku_prices` for SKU prices on one product.

## Read Next

- `references/products-list.md`
- `references/product-sku-prices.md`

## SKU Price Workflow

- First identify the target product.
- If the user does not provide an exact product title, use the product list first.
- If the user wants SKU prices for one product but does not know valid filter values, use `sku_price_filters` first.
- Then call `sku_prices` with any provided filters such as `country_code`, `title`, `quantity`, `page`, or `per_page`.
- Treat SKU price pagination as variant-based pagination, not final row-based pagination.

## Pagination Notes For SKU Prices

- `sku_prices` paginates variants first, then expands each variant into one or more returned price rows.
- Because of that, `per_page` is a variant count, not a final row count.
- Use the API response fields:
  - `pagination_basis`
  - `current_page`
  - `total_pages`
  - `per_page`
  - `returned_row_count`
- Do not assume `returned_row_count == per_page`.

## Troubleshooting

- For integration issues, contact your assigned business representative.
