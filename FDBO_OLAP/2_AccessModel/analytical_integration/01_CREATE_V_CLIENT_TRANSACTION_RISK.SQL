CREATE OR REPLACE VIEW V_CLIENT_TRANSACTION_RISK AS
SELECT
    t.client_id,
    p.age,
    p.job,
    p.marital,
    p.education,
    p.balance,
    p.housing,
    p.loan,
    r.risk_score,
    r.currency,
    r.status,
    t.step,
    t.type,
    t.amount,
    t.nameOrig,
    t.nameDest,
    t.oldbalanceOrg,
    t.newbalanceOrig,
    t.oldbalanceDest,
    t.newbalanceDest,
    t.isFraud,
    t.isFlaggedFraud
FROM V_TRANSACTION_STREAM_PG t
LEFT JOIN V_CLIENT_PROFILE_XLS p
    ON t.client_id = p.client_id
LEFT JOIN V_CLIENT_RISK_MONGO r
    ON t.client_id = r.client_id;
    
SELECT *
FROM V_CLIENT_TRANSACTION_RISK
WHERE ROWNUM <= 5;