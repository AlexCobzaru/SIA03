CREATE OR REPLACE VIEW OLAP_FRAUD_BY_RISK AS
SELECT
    r.risk_category,
    COUNT(*) AS total_transactions,
    SUM(f.amount) AS total_amount,
    SUM(CASE WHEN f.isFraud = 1 THEN 1 ELSE 0 END) AS fraud_count
FROM FACT_TRANSACTIONS f
JOIN DIM_RISK r ON f.client_id = r.client_id
GROUP BY r.risk_category;


CREATE OR REPLACE VIEW OLAP_FRAUD_BY_TYPE AS
SELECT
    type,
    COUNT(*) AS total_transactions,
    SUM(amount) AS total_amount,
    SUM(CASE WHEN isFraud = 1 THEN 1 ELSE 0 END) AS fraud_count
FROM FACT_TRANSACTIONS
GROUP BY type;


CREATE OR REPLACE VIEW OLAP_CUBE_ANALYSIS AS
SELECT
    r.risk_category,
    f.type,
    COUNT(*) AS total_transactions,
    SUM(f.amount) AS total_amount
FROM FACT_TRANSACTIONS f
JOIN DIM_RISK r ON f.client_id = r.client_id
GROUP BY CUBE (r.risk_category, f.type);


CREATE OR REPLACE VIEW OLAP_ROLLUP_TIME AS
SELECT
    step,
    type,
    SUM(amount) AS total_amount
FROM FACT_TRANSACTIONS
GROUP BY ROLLUP (step, type);