# Product SKU Price Endpoints

## Endpoints

```text
GET /api/ai/v1/products/:id/sku_price_filters
GET /api/ai/v1/products/:id/sku_prices
```

## `sku_price_filters`

Use this endpoint to discover valid filter values before requesting SKU prices for one product.

### Response

- `titles`
- `country_codes`

## `sku_prices`

Use this endpoint to get SKU price rows for one product.

### Supported Query Parameters

- `country_code`
- `title`
- `quantity`
- `page`
- `per_page`

### Defaults And Limits

- `quantity` defaults to `1`
- `per_page` defaults to `10`
- `per_page` is capped at `20`
- `quantity` must be greater than `0`

### Response Highlights

- `sku_prices`
- `current_page`
- `total_pages`
- `pagination_basis`
- `per_page`
- `returned_row_count`

### Pagination Semantics

- Pagination is based on product variants first.
- Each variant may expand into one or more returned SKU price rows.
- Because of that, `per_page` is not a guaranteed final row count.
- Use `returned_row_count` to describe how many price rows were actually returned in the current response.

## Notes

- Use `sku_price_filters` first when the user does not know valid `title` or `country_code` values.
- The AI API only allows products whose Shopify created time is on or after March 1, 2026.
- If a product has no valid bound variant or no matching logistics for the requested filters, `sku_prices` may return an empty list.
