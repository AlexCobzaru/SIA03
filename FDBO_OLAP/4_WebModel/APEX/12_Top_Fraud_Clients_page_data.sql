SELECT
    client_id,
    COUNT(*) AS fraud_count
FROM FACT_TRANSACTIONS
WHERE isFraud = 1
GROUP BY client_id
ORDER BY fraud_count DESC
FETCH FIRST 10 ROWS ONLY