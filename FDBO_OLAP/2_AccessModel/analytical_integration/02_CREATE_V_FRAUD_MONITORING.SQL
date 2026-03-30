CREATE OR REPLACE VIEW V_FRAUD_MONITORING AS
SELECT
    client_id,
    age,
    job,
    marital,
    education,
    balance,
    housing,
    loan,
    risk_score,
    currency,
    status,
    step,
    type,
    amount,
    isFraud,
    isFlaggedFraud,
    CASE
        WHEN risk_score >= 0.8 THEN 'HIGH'
        WHEN risk_score >= 0.5 THEN 'MEDIUM'
        ELSE 'LOW'
    END AS risk_category,
    CASE
        WHEN isFraud = 1 OR isFlaggedFraud = 1 THEN 'ALERT'
        ELSE 'NORMAL'
    END AS fraud_alert
FROM V_CLIENT_TRANSACTION_RISK;

SELECT *
FROM V_FRAUD_MONITORING
WHERE ROWNUM <= 20;