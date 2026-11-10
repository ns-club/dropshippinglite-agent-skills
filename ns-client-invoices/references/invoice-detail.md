# Invoice Detail Endpoint

## Endpoint

```text
GET /api/ai/v1/invoice_orders/:id
```

Returns one invoice with its billing breakdown: invoice-level totals plus one row per package (parcel) billed under the invoice. Use it for billing reconciliation — the package rows sum to the invoice totals.

## Path Parameters

- `id` — the invoice `id` from the invoice list response (`GET /api/ai/v1/invoice_orders`)

## Response Shape

```json
{
  "id": 320851,
  "invoice_number": "MU339fa83ac02f78",
  "financial_status": "paid",
  "fulfillment_status": "approved",
  "created_at": "2026-03-02T12:00:00.000Z",
  "paid_at": "2026-03-05T10:20:00.000Z",
  "exchange_rate": "6.6",
  "item_cost": "40.44",
  "shipping_cost": "2479.69",
  "total_cost": "2520.13",
  "marketing_discount_amount": "0.00",
  "package_count": 223,
  "packages": [
    {
      "id": 34655756,
      "tracking_number": "WS1835513139826",
      "carrier": "YunExpress",
      "country_code": "NL",
      "shipping_weight": "0.58",
      "item_cost": "0.15",
      "shipping_cost": "11.37",
      "total_cost": "11.52",
      "store_order_names": "#369113367, #369120001"
    }
  ]
}
```

## Field Notes

- Invoice-level `item_cost`, `shipping_cost`, `total_cost` are in USD, exactly as shown in the customer portal. Use `total_cost` as the billed invoice total.
- Rounding note: amounts are displayed with 2 decimals. Summing the displayed package values can differ from the displayed `total_cost` by up to one cent, because the billed total is computed from unrounded values. Treat `total_cost` as the authoritative billed amount and cent-level differences as rounding effects.
- `marketing_discount_amount` is the marketing discount applied to the invoice, reported separately from `total_cost`.
- Package amounts (`packages[].item_cost`, `packages[].shipping_cost`, `packages[].total_cost`) are returned in USD, converted from RMB at the invoice's `exchange_rate`.
- `store_order_names` lists the store order names (for example `#369113367`) included in that package, comma-separated. Multiple store orders can share one package, and the package is billed once — this is the billed amount those orders should reconcile against.
- `package_count` is the number of billed packages under the invoice.

## Reconciliation Guidance

- Per-package billed amounts: use `packages[].item_cost` and `packages[].shipping_cost` from this endpoint.
- Do not use order-level cost fields for billing math; they are quote-reference figures (see the `ns-client-orders` notes).
- To match orders against packages, group by `store_order_names` (or by `tracking_number`).
- For invoice totals, use `total_cost` from this endpoint or from the invoice list; do not sum anything else.

## Errors

- `404` + `resource_not_found`: the invoice does not exist, belongs to another account, is hidden, or was created before the preview data floor (March 1, 2026).

## Notes

- Detail visibility matches the invoice list: only non-hidden invoices of the current account, created on or after the preview data floor.
- Requests are rate-limited and audited the same way as all `/api/ai/v1/*` endpoints (see the shared skill).
