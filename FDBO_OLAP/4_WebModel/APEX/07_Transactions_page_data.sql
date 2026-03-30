SELECT
    client_id,
    step,
    type,
    amount,
    isFraud,
    isFlaggedFraud
FROM FACT_TRANSACTIONS
WHERE ROWNUM <= 10;