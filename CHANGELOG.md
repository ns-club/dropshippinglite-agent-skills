# Changelog

## 0.3.0

- Added invoice detail endpoint `GET /api/ai/v1/invoice_orders/:id`: invoice-level totals (`item_cost` / `shipping_cost` / `total_cost` / `marketing_discount_amount`) plus per-package billed amounts (`tracking_number`, `carrier`, `country_code`, `shipping_weight`, USD-converted costs, `store_order_names`)
- `ns-client-invoices`: new `invoice-detail.md` reference with reconciliation guidance; skill version bumped to 0.2.0
- `ns-client-orders`: reconciliation note now points to the invoice detail endpoint for per-package billed amounts grouped by store order

## 0.2.0

- Added `ns-client-sku-mappings` skill: Shopify SKU to internal NP-code lookup (`GET /api/ai/v1/sku_mappings`)
- Added `ns-client-purchase-orders` skill: purchase order status and received quantities, scoped to client stock product lines (`GET /api/ai/v1/purchase_orders`)
- `ns-client-orders`: response now includes `source_order_id` (Shopify internal order ID); documented that cost fields are quote-reference and must not be summed as billing amounts
- `ns-client-products`: documented that some accounts may have an earlier data floor on the product list endpoint only; other endpoints keep the March 1, 2026 floor
- `ns-client-purchase-orders`: added `sku` filter (exact match on internal SKU lines) for per-SKU arrival lookups

## 0.1.0

- Initial public skill pack
- Read-only NS Client skills for:
  - dashboard
  - invoices
  - products
  - orders
  - billing logs
- Added cross-platform installers for macOS, Linux, and Windows
- Added Windows `install.ps1` and `install.cmd` entrypoints
- Added local config helper scripts for credential reuse
