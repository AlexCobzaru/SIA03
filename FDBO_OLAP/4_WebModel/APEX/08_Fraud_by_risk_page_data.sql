SELECT
    risk_category,
    total_amount
FROM OLAP_FRAUD_BY_RISK
WHERE ROWNUM <= 50;