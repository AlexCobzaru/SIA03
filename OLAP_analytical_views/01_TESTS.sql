//1. TEST — View integrare
-- Test 1: verificare existență date
SELECT COUNT(*) AS total_rows
FROM V_CLIENT_TRANSACTION_RISK;

-- Test 2: vizualizare date
SELECT *
FROM V_CLIENT_TRANSACTION_RISK
WHERE ROWNUM <= 10;

-- Test 3: verificare join (client fără profil sau risc)
SELECT *
FROM V_CLIENT_TRANSACTION_RISK
WHERE age IS NULL OR risk_score IS NULL;

//2. TEST — DIM_CLIENTS
-- Test 1: fără duplicate
SELECT client_id, COUNT(*)
FROM DIM_CLIENTS
GROUP BY client_id
HAVING COUNT(*) > 1;

-- Test 2: preview
SELECT *
FROM DIM_CLIENTS
WHERE ROWNUM <= 10;

//3. TEST — DIM_RISK
-- Test 1: verificare categorii
SELECT risk_category, COUNT(*)
FROM DIM_RISK
GROUP BY risk_category;

-- Test 2: valori lipsă
SELECT *
FROM DIM_RISK
WHERE risk_score IS NULL;

//4. TEST — DIM_TRANSACTION_TYPE
-- Test 1: valori distincte
SELECT *
FROM DIM_TRANSACTION_TYPE;

-- Test 2: verificare manuală
SELECT DISTINCT type
FROM V_CLIENT_TRANSACTION_RISK;

//5. TEST — DIM_TIME
-- Test 1: valori distincte
SELECT *
FROM DIM_TIME
ORDER BY time_step;

-- Test 2: interval timp
SELECT MIN(time_step), MAX(time_step)
FROM DIM_TIME;

//6. TEST — FACT_TRANSACTIONS
-- Test 1: volum date
SELECT COUNT(*) FROM FACT_TRANSACTIONS;

-- Test 2: verificare corectitudine
SELECT *
FROM FACT_TRANSACTIONS
WHERE ROWNUM <= 10;

-- Test 3: verificare valori fraudă
SELECT isFraud, COUNT(*)
FROM FACT_TRANSACTIONS
GROUP BY isFraud;

//7. TEST — OLAP_FRAUD_BY_RISK
SELECT *
FROM OLAP_FRAUD_BY_RISK;

-- verificare total
SELECT SUM(total_transactions)
FROM OLAP_FRAUD_BY_RISK;

-- comparare cu fact
SELECT COUNT(*)
FROM FACT_TRANSACTIONS;

//8. TEST — OLAP_FRAUD_BY_TYPE
SELECT *
FROM OLAP_FRAUD_BY_TYPE;

-- verificare tipuri
SELECT COUNT(DISTINCT type)
FROM FACT_TRANSACTIONS;

//9. TEST — OLAP_CUBE_ANALYSIS
SELECT *
FROM OLAP_CUBE_ANALYSIS;

-- verificare total general (grand total)
SELECT *
FROM OLAP_CUBE_ANALYSIS
WHERE risk_category IS NULL AND type IS NULL;

//10. TEST — OLAP_ROLLUP_TIME
SELECT *
FROM OLAP_ROLLUP_TIME;

-- verificare subtotaluri
SELECT *
FROM OLAP_ROLLUP_TIME
WHERE type IS NULL;