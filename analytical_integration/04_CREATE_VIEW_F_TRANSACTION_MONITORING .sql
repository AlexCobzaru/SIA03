CREATE OR REPLACE VIEW F_TRANSACTION_MONITORING AS
SELECT
    client_id,
    step,
    type,
    amount,
    risk_score,
    status,
    isFraud,
    isFlaggedFraud
FROM V_CLIENT_TRANSACTION_RISK;

SELECT * FROM F_TRANSACTION_MONITORING;