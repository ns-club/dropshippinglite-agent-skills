# Errors And Retries

## Response Shape

Errors are returned as JSON:

```json
{
  "error": "human-readable message",
  "status": 422,
  "code": "stable_machine_code"
}
```

`Retry-After` may also be present for rate limits.

## Common Error Codes

- `unauthorized`
- `resource_not_found`
- `invalid_date`
- `invalid_per_page`
- `invalid_request`
- `rate_limit_exceeded`

Resource-specific validation codes currently include:

- Invoices:
  - `invalid_financial_status`
  - `invalid_fulfillment_status`
- Products:
  - `invalid_status`
  - `invalid_bind_consumables`
- Orders:
  - `invalid_financial_status`
  - `invalid_fulfillment_status`
  - `invalid_soupin_status`
  - `invalid_order_source`
  - `invalid_source_platform`
  - `invalid_address_status`
- Billing logs:
  - `invalid_type_of`
  - `invalid_wallet_type`
  - `invalid_payment_method`

## Retry Policy

- `401`: do not retry blindly
- `422`: do not retry without changing the request
- `429`: wait `Retry-After`, then retry once
- `5xx`: stop and report the failure
