CREATE OR REPLACE VIEW V_TOP_TRANSACTIONS AS
SELECT
    client_id,
    type,
    amount,
    rn
FROM (
    SELECT
        client_id,
        type,
        amount,
        ROW_NUMBER() OVER (
            PARTITION BY type
            ORDER BY amount DESC
        ) AS rn
    FROM FACT_TRANSACTIONS
)
WHERE rn <= 5;

SELECT * 
FROM V_TOP_TRANSACTIONS
ORDER BY type, rn;
