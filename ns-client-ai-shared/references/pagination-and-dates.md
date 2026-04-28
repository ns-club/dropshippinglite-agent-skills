# Pagination And Dates

## Dates

- Send dates as `YYYY-MM-DD`
- The API expands:
  - `start_date` to the start of that day
  - `end_date` to the end of that day
- If the date string is invalid, expect:
  - HTTP `422`
  - `code=invalid_date`

Some endpoints also support additional date filters:

- Products:
  - `erp_start_date`
  - `erp_end_date`

## Pagination

- Recommended default:
  - `page=1`
  - `per_page=50`
- Maximum supported `per_page` is `100`
- List endpoints return `total_count`, not `total_pages`

## Page Collection Rule

When collecting multiple pages:

1. Start from `page=1`
2. Continue incrementing `page`
3. Stop when:
   - the returned array is smaller than `per_page`, or
   - you have collected enough records for the user task
