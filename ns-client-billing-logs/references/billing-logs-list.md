# Billing Logs Endpoint

## Endpoint

```text
GET /api/ai/v1/billing_logs
```

## Supported Query Parameters

- `transaction_id`
- `payment_method`
- `id`
- `type_of`
- `wallet_type`
- `start_date`
- `end_date`
- `note`
- `store_id`
- `page`
- `per_page`

## Accepted Values

`payment_method`:

- `balance`
- `stripe`
- `airwallex`

`wallet_type`:

- `available`
- `inventory`

`type_of` currently accepts:

- `invoice`
- `charge`
- `refund`
- `commission`
- `debit`
- `manual_invoice_charge`
- `other`
- `after_sale_refund`
- `after_sale_deduction`
- `transfer`
- `cancel_pay_refund`
- `inventory_stock_deduction`
- `payment_processing_payment`
- `advertisement_fee`
- `auto_invoice_charge`
- `inventory_reduce`

## Response Highlights

- `transaction_id`
- `date`
- `amount`
- `extra_fee`
- `balance`
- `inventory_balance`
- `total_balance`
- `invoice_number`
- `type`
- `wallet_type`
- `payment_method`
- `note`

## Notes

- `store_id` is only meaningful when `type_of` is `after_sale_refund` or `after_sale_deduction`.
- If the user wants just the current balance, use `ns-client-dashboard` instead of scanning logs.
