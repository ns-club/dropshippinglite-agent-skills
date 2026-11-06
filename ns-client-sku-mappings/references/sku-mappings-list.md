# SKU Mapping Endpoint

## Endpoint

```text
GET /api/ai/v1/sku_mappings
```

## Safe Request Example

Prefer the installed shared helper so credentials can come from environment variables or local config files without printing the secret:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\ai_api_request.ps1 request /api/ai/v1/sku_mappings --param page=1 --param per_page=50
```

```sh
sh ./scripts/ai_api_request.sh request /api/ai/v1/sku_mappings --param page=1 --param per_page=50
```

## Supported Query Parameters

- `sku` (fuzzy match on the Shopify-side SKU)
- `np_code` (exact match, e.g. `NP-4564270224491`)
- `shopify_variant_id` (exact match on the Shopify variant ID)
- `unmapped_only` (`true`/`false`; `true` returns only variants not yet bound to an internal product)
- `page`
- `per_page`

## Accepted Values

- `unmapped_only`: `1`, `true`, `0`, `false`

## Response Highlights

- `shopify_sku`
- `shopify_variant_id` (Shopify internal variant ID)
- `shopify_product_id` (Shopify internal product ID)
- `shopify_product_title`
- `shopify_variant_title`
- `myshopify_domain`
- `internal_sku`
- `np_code`
- `linked` (boolean; `false` = no internal product bound yet)

## Notes

- This endpoint is NOT restricted by the 2026-03-01 preview cutoff: mappings for older products are returned too. All rows are scoped to your own store products.
- A typical inventory-planning flow: pull the full mapping table once, cache it, then use `np_code` / `internal_sku` values when querying other endpoints.
- Rows with `linked=false` have no internal product binding yet; contact your business representative if those need to be created.
