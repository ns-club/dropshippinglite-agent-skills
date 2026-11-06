# Changelog

## 0.2.0

- Added `ns-client-sku-mappings` skill: Shopify SKU to internal NP-code lookup (`GET /api/ai/v1/sku_mappings`)
- Added `ns-client-purchase-orders` skill: purchase order status and received quantities, scoped to client stock product lines (`GET /api/ai/v1/purchase_orders`)
- `ns-client-orders`: response now includes `source_order_id` (Shopify internal order ID); documented that cost fields are quote-reference and must not be summed as billing amounts

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
