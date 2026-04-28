# Dashboard Summary Endpoint

## Endpoint

```text
GET /api/ai/v1/dashboard
```

## Response Shape

```json
{
  "balance": "123.45",
  "inventory_balance": "67.89",
  "unpaid_invoice_count": 1,
  "unpaid_invoice_amount": "35.0",
  "unconfirm_product_count": 1
}
```

## Field Semantics

- `balance`:
  available wallet balance
- `inventory_balance`:
  inventory wallet value
- `unpaid_invoice_count`:
  number of unpaid invoices
- `unpaid_invoice_amount`:
  unpaid invoice amount summary
- `unconfirm_product_count`:
  count used by the portal for unconfirmed products

## Notes

- This is the cheapest summary endpoint in the current read-only API surface.
- Use it as the validation probe in a new session when credentials need to be tested.
