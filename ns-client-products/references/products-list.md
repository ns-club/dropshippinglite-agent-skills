# Product List Endpoint

## Endpoint

```text
GET /api/ai/v1/products
```

## Supported Query Parameters

- `id`
- `status`
- `store_id`
- `title`
- `start_date`
- `end_date`
- `erp_start_date`
- `erp_end_date`
- `bind_consumables`
- `bind_consumable_id`
- `page`
- `per_page`

## Accepted Values

`status` currently accepts:

- `pending`
- `in_progress`
- `approved`
- `unapproved`
- `confirmed`
- `price_offered`

`bind_consumables` accepts:

- `1` for products with bound consumables
- `0` for products without bound consumables

## Response Highlights

- `title`
- `status`
- `image`
- `internal_sku`
- `target_price`
- `cost_range`
- `price_range`
- `order_count`
- `created_at`
- `erp_created_at`
- `bind_consumables`

## Notes

- `start_date` and `end_date` filter `shopify_created_at`.
- `erp_start_date` and `erp_end_date` filter the local record `created_at`.
- `bind_consumables` in the response is an array of the bound consumable variants exactly as shown in the portal.
