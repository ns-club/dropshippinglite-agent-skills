# Invoice List Endpoint

## Endpoint

```text
GET /api/ai/v1/invoice_orders
```

## Supported Query Parameters

- `invoice_number`
- `start_date`
- `end_date`
- `note`
- `page`
- `per_page`
- `fulfillment_status`
- `financial_status`

`financial_status` may be sent as a single value or as an array.

## Common Filters

- Unpaid invoices:
  - `financial_status=unpaid`
- Paid invoices:
  - `financial_status=paid`
- Search by invoice number:
  - `invoice_number=MU33...`
- Filter by note fragment:
  - `note=priority`

## Response Shape

```json
{
  "total_count": 11735,
  "orders": [
    {
      "id": 320851,
      "invoice_number": "MU339fa83ac02f78",
      "financial_status": "unpaid",
      "fulfillment_status": "submit",
      "total_cost": "34.50",
      "inventory_total_cost": "0.00",
      "invoice_count": 4,
      "note": "",
      "upload_tracking_early": false,
      "fulfill_by_client": false,
      "created_at": "2026-02-03T06:20:04.982Z",
      "paid_at": null,
      "cancel_paid_at": null,
      "client_balance": "-119834.42"
    }
  ]
}
```

## Notes

- `total_cost` and `inventory_total_cost` are display values from the portal response.
- `invoice_count` is the order count shown in the invoice list row.
- If the user only needs the unpaid invoice count and amount, `ns-client-dashboard` is usually cheaper.
