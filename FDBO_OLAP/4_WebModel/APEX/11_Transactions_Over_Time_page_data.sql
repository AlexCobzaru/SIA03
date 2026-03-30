SELECT
    step,
    total_amount
FROM OLAP_ROLLUP_TIME
WHERE type IS NULL
  AND step IS NOT NULL;