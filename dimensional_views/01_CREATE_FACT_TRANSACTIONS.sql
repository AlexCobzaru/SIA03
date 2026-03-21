CREATE OR REPLACE VIEW FACT_TRANSACTIONS AS
SELECT
    client_id,
    step,
    type,
    amount,
    isFraud,
    isFlaggedFraud
FROM V_CLIENT_TRANSACTION_RISK;