CREATE OR REPLACE VIEW DIM_CLIENTS AS
SELECT DISTINCT
    client_id,
    age,
    job,
    marital,
    education,
    balance,
    housing,
    loan
FROM V_CLIENT_TRANSACTION_RISK;


CREATE OR REPLACE VIEW DIM_RISK AS
SELECT DISTINCT
    client_id,
    risk_score,
    currency,
    status,
    CASE
        WHEN risk_score >= 0.8 THEN 'HIGH'
        WHEN risk_score >= 0.5 THEN 'MEDIUM'
        ELSE 'LOW'
    END AS risk_category
FROM V_CLIENT_TRANSACTION_RISK;


CREATE OR REPLACE VIEW DIM_TRANSACTION_TYPE AS
SELECT DISTINCT
    type
FROM V_CLIENT_TRANSACTION_RISK;


CREATE OR REPLACE VIEW DIM_TIME AS
SELECT DISTINCT
    step AS time_step
FROM V_CLIENT_TRANSACTION_RISK;