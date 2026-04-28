# Order List Endpoint

## Endpoint

```text
GET /api/ai/v1/orders
```

## Safe Request Example

Prefer the installed shared helper so credentials can come from environment variables or local config files without printing the secret:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\ai_api_request.ps1 request /api/ai/v1/orders --param page=1 --param per_page=50
```

```sh
sh ./scripts/ai_api_request.sh request /api/ai/v1/orders --param page=1 --param per_page=50
```

## Supported Query Parameters

- `store_id`
- `order_number`
- `pre_fulfill`
- `source_order_name`
- `title`
- `order_source`
- `myshopify_domain`
- `invoice_number`
- `source_platform`
- `address_status`
- `country_code`
- `buyer`
- `start_date`
- `end_date`
- `page`
- `per_page`
- `financial_status`
- `fulfillment_status`
- `soupin_status`

`financial_status`, `fulfillment_status`, and `soupin_status` may be sent as a single value or as arrays.

## Accepted Values

`order_source`:

- `shopify`
- `sp`
- `manual_creation`

`address_status`:

- `invalid_address`

`source_platform`:

- `shopify`
- `csv`
- `woo`
- `other`

`fulfillment_status=fulfilled` is a public alias accepted by the API.

## Cost Field Semantics

- `price`:
  source store line-item price
- `cost`:
  per-unit product cost shown to the customer in the portal
- `total_item_cost`:
  product cost total
- `shipping_cost`:
  logistics cost shown in the portal
- `margin_total_cost`:
  total order cost shown in the portal

## Response Highlights

- `source_order_name`
- `order_number`
- `invoice_number`
- `title`
- `source_variant_title`
- `price`
- `cost`
- `total_item_cost`
- `shipping_cost`
- `margin_total_cost`
- `buyer`
- `shipping_address`
- `financial_status`
- `fulfillment_status`

## Notes

- The response is intended to match what the customer sees in the order list page.
- If the user asks only for a quick unpaid invoice or balance summary, use `ns-client-dashboard` instead.
