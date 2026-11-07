# Purchase Order List Endpoint

## Endpoint

```text
GET /api/ai/v1/purchase_orders
```

## Safe Request Example

Prefer the installed shared helper so credentials can come from environment variables or local config files without printing the secret:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\ai_api_request.ps1 request /api/ai/v1/purchase_orders --param page=1 --param per_page=50
```

```sh
sh ./scripts/ai_api_request.sh request /api/ai/v1/purchase_orders --param page=1 --param per_page=50
```

## Supported Query Parameters

- `po_number` (exact match)
- `sku` (exact match on the internal SKU line SKU, e.g. `NP-2190930373327_07234`; only purchase orders whose stock-scope lines contain this SKU are returned)
- `status`
- `warehouse_status`
- `payment_status`
- `start_date` / `end_date` (filters on purchase order creation time; earliest allowed date is 2026-03-01)
- `page`
- `per_page`

## Accepted Values

`status`:

- `pending`
- `in_progress`
- `done`
- `printed_unpaid`
- `qa_pass`
- `close`

`warehouse_status`:

- `warehouse_pending`
- `warehouse_part`
- `warehouse_done`
- `warehouse_part_confirmed`

`payment_status`:

- `unpaid`
- `partially_paid`
- `fully_paid`

## Response Highlights

- `po_number`
- `status`
- `warehouse_status`
- `payment_status`
- `created_at` / `purchase_time` / `delivery_time` / `warehouse_delivery_time` / `completed_at` (all in your account timezone)
- `listings` (SKU lines):
  - `sku`
  - `title`
  - `option1` / `option2` / `option3`
  - `quantity`
  - `purchase_quantity` (purchased quantity)
  - `received_quantity` (actually received quantity)
- `total_purchase_quantity` / `total_received_quantity` (sums over the returned SKU lines)
- `listings_scope` (always `client_stock_products_only`)

## Notes

- Purchasing may merge several clients' goods into one purchase order. This endpoint therefore returns **only the SKU lines that belong to your own stock products**, and `total_purchase_quantity` / `total_received_quantity` are sums over those lines only.
- Header-level `status` / `warehouse_status` / `payment_status` describe the **whole purchase order** (possibly including other clients' goods), so treat them as reference. Authoritative quantities are the per-SKU lines and their sums.
- Cost/price fields are intentionally not exposed; billing reconciliation must use the `ns-client-invoices` skill.
- To check arrival status for one product, pass its internal SKU via `sku` (use `ns-client-sku-mappings` first if you only have the Shopify SKU). SKUs outside your stock product list return no results.
- Timestamps follow your account timezone setting in the portal.
