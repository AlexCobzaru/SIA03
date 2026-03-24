--------------------------------------------------------------------------------
-- DEMO PROIECT: Sistem de analiză și monitorizare a tranzacțiilor bancare
--------------------------------------------------------------------------------
-- USER: FDBO_XE
-- Servicii externe care trebuie pornite înainte de demo:
-- 1. PostgreSQL + PostgREST  -> http://localhost:3000/transactions ->cd C:\Proiect_SIA03 postgrest tutorial.conf
-- 2. MongoDB                 -> mongod
-- 3. RESTHeart              -> http://localhost:8081/client_risk -> "C:\Proiect_SIA03\support\restheart\restheart-windows-amd64.exe" -o "C:\Proiect_SIA03\support\restheart\conf-override.conf"
--
-- Surse integrate:
--   DS_1 -> Excel / bank_marketing.xlsx
--   DS_2 -> PostgreSQL / transactions
--   DS_3 -> MongoDB / client_risk
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- 1. DATA SOURCE REMOTE / EXTERNAL VIEWS
--------------------------------------------------------------------------------

-- Excel source: profil client
SELECT * FROM V_CLIENT_PROFILE_XLS FETCH FIRST 3 ROWS ONLY;

-- PostgreSQL source: flux tranzactii
SELECT * FROM V_TRANSACTION_STREAM_PG FETCH FIRST 3 ROWS ONLY;

-- MongoDB source: risc client
SELECT * FROM V_CLIENT_RISK_MONGO FETCH FIRST 3 ROWS ONLY;

--------------------------------------------------------------------------------
-- 2. INTEGRATION VIEW
--------------------------------------------------------------------------------

-- View-ul central care uneste toate cele 3 surse prin client_id
SELECT * 
FROM V_CLIENT_TRANSACTION_RISK
FETCH FIRST 5 ROWS ONLY;

-- Verificare consistenta integrare
SELECT
    COUNT(*) AS total_rows,
    COUNT(age) AS rows_with_profile,
    COUNT(risk_score) AS rows_with_risk
FROM V_CLIENT_TRANSACTION_RISK;

-- Verificare cazuri incomplete
SELECT *
FROM V_CLIENT_TRANSACTION_RISK
WHERE age IS NULL
   OR risk_score IS NULL
FETCH FIRST 5 ROWS ONLY;

--------------------------------------------------------------------------------
-- 3. DIMENSIONAL VIEWS
--------------------------------------------------------------------------------

-- D1: Dimensiune clienti
SELECT * FROM DIM_CLIENTS FETCH FIRST 3 ROWS ONLY;

-- Verificare duplicate in DIM_CLIENTS
SELECT client_id, COUNT(*) AS cnt
FROM DIM_CLIENTS
GROUP BY client_id
HAVING COUNT(*) > 1;

-- D2: Dimensiune risc
SELECT * FROM DIM_RISK FETCH FIRST 10 ROWS ONLY;

-- Distributie categorii risc
SELECT risk_category, COUNT(*) AS total_clients
FROM DIM_RISK
GROUP BY risk_category
ORDER BY total_clients DESC;

-- D3: Dimensiune tip tranzactie
SELECT * FROM DIM_TRANSACTION_TYPE;

-- D4: Dimensiune timp
SELECT * FROM DIM_TIME ORDER BY time_step FETCH FIRST 20 ROWS ONLY;

--------------------------------------------------------------------------------
-- 4. FACT VIEW
--------------------------------------------------------------------------------

-- Fact principal pentru modelul analitic
SELECT * FROM FACT_TRANSACTIONS FETCH FIRST 10 ROWS ONLY;

-- Verificare volum total
SELECT COUNT(*) AS total_transactions
FROM FACT_TRANSACTIONS;

-- Verificare distributie frauda
SELECT isFraud, COUNT(*) AS total_rows
FROM FACT_TRANSACTIONS
GROUP BY isFraud
ORDER BY isFraud;

-- Indicatori sintetici
SELECT
    COUNT(*) AS total_transactions,
    ROUND(SUM(amount), 2) AS total_amount
FROM FACT_TRANSACTIONS;

--------------------------------------------------------------------------------
-- 5. ANALYTICAL VIEWS
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- OLAP 1: Fraud by Risk
--------------------------------------------------------------------------------
SELECT * FROM OLAP_FRAUD_BY_RISK;

-- Verificare total tranzactii din view-ul OLAP_FRAUD_BY_RISK
SELECT SUM(total_transactions) AS total_transactions_check
FROM OLAP_FRAUD_BY_RISK;

--------------------------------------------------------------------------------
-- OLAP 2: Fraud by Transaction Type
--------------------------------------------------------------------------------
SELECT * FROM OLAP_FRAUD_BY_TYPE;

-- Verificare tipuri distincte
SELECT COUNT(DISTINCT type) AS distinct_types
FROM FACT_TRANSACTIONS;

--------------------------------------------------------------------------------
-- OLAP 3: CUBE Analysis
--------------------------------------------------------------------------------
SELECT * 
FROM OLAP_CUBE_ANALYSIS
ORDER BY risk_category, type;

-- Verificare total general (grand total)
SELECT *
FROM OLAP_CUBE_ANALYSIS
WHERE risk_category IS NULL
  AND type IS NULL;

--------------------------------------------------------------------------------
-- OLAP 4: ROLLUP Time Analysis
--------------------------------------------------------------------------------
SELECT *
FROM OLAP_ROLLUP_TIME
ORDER BY step, type;

-- Verificare subtotaluri pe timp
SELECT *
FROM OLAP_ROLLUP_TIME
WHERE type IS NULL
ORDER BY step;

--------------------------------------------------------------------------------
-- 6. COMPLEX ANALYTICAL QUERIES
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Q1. Top clienti dupa suma tranzactiilor suspecte
--------------------------------------------------------------------------------
SELECT
    client_id,
    ROUND(SUM(amount), 2) AS suspicious_amount,
    COUNT(*) AS suspicious_transactions
FROM FACT_TRANSACTIONS
WHERE isFraud = 1 OR isFlaggedFraud = 1
GROUP BY client_id
ORDER BY suspicious_amount DESC
FETCH FIRST 10 ROWS ONLY;

--------------------------------------------------------------------------------
-- Q2. Clienti cu risc ridicat si tranzactii frauduloase
--------------------------------------------------------------------------------
SELECT
    t.client_id,
    r.risk_category,
    r.status,
    COUNT(*) AS fraud_transactions,
    ROUND(SUM(t.amount), 2) AS fraud_amount
FROM FACT_TRANSACTIONS t
JOIN DIM_RISK r
    ON t.client_id = r.client_id
WHERE r.risk_category = 'HIGH'
  AND t.isFraud = 1
GROUP BY t.client_id, r.risk_category, r.status
ORDER BY fraud_amount DESC;

--------------------------------------------------------------------------------
-- Q3. Matrice risc x tip tranzactie
--------------------------------------------------------------------------------
SELECT
    r.risk_category,
    t.type,
    COUNT(*) AS total_transactions,
    ROUND(SUM(t.amount), 2) AS total_amount,
    SUM(CASE WHEN t.isFraud = 1 THEN 1 ELSE 0 END) AS fraud_count
FROM FACT_TRANSACTIONS t
JOIN DIM_RISK r
    ON t.client_id = r.client_id
GROUP BY r.risk_category, t.type
ORDER BY r.risk_category, total_amount DESC;

--------------------------------------------------------------------------------
-- Q4. Ponderea fraudelor in total tranzactii
--------------------------------------------------------------------------------
SELECT
    ROUND(100 * SUM(CASE WHEN isFraud = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS fraud_percentage,
    ROUND(100 * SUM(CASE WHEN isFlaggedFraud = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS flagged_percentage
FROM FACT_TRANSACTIONS;

--------------------------------------------------------------------------------
-- Q5. Corelare intre profil financiar si risc
--------------------------------------------------------------------------------
SELECT
    CASE
        WHEN c.balance < 0 THEN 'NEGATIVE'
        WHEN c.balance BETWEEN 0 AND 5000 THEN 'LOW_BALANCE'
        WHEN c.balance BETWEEN 5000 AND 20000 THEN 'MEDIUM_BALANCE'
        ELSE 'HIGH_BALANCE'
    END AS balance_category,
    r.risk_category,
    COUNT(*) AS total_clients
FROM DIM_CLIENTS c
JOIN DIM_RISK r
    ON c.client_id = r.client_id
GROUP BY
    CASE
        WHEN c.balance < 0 THEN 'NEGATIVE'
        WHEN c.balance BETWEEN 0 AND 5000 THEN 'LOW_BALANCE'
        WHEN c.balance BETWEEN 5000 AND 20000 THEN 'MEDIUM_BALANCE'
        ELSE 'HIGH_BALANCE'
    END,
    r.risk_category
ORDER BY balance_category, r.risk_category;

--------------------------------------------------------------------------------
-- Q6. Distribuirea sumelor pe risc si tip tranzactie
--------------------------------------------------------------------------------
SELECT
    r.risk_category,
    t.type,
    ROUND(SUM(t.amount), 2) AS total_amount
FROM FACT_TRANSACTIONS t
JOIN DIM_RISK r
    ON t.client_id = r.client_id
GROUP BY r.risk_category, t.type
ORDER BY r.risk_category, total_amount DESC;

--------------------------------------------------------------------------------
-- Q7. Valoarea fraudelor pe categorie de risc
--------------------------------------------------------------------------------
SELECT
    r.risk_category,
    ROUND(SUM(CASE WHEN t.isFraud = 1 THEN t.amount ELSE 0 END), 2) AS fraud_amount,
    SUM(CASE WHEN t.isFraud = 1 THEN 1 ELSE 0 END) AS fraud_count
FROM FACT_TRANSACTIONS t
JOIN DIM_RISK r
    ON t.client_id = r.client_id
GROUP BY r.risk_category
ORDER BY fraud_amount DESC;

--------------------------------------------------------------------------------
-- Q8. Analiza pe tipuri de tranzactii suspecte
--------------------------------------------------------------------------------
SELECT
    type,
    COUNT(*) AS suspicious_transactions,
    ROUND(SUM(amount), 2) AS suspicious_amount
FROM FACT_TRANSACTIONS
WHERE isFraud = 1 OR isFlaggedFraud = 1
GROUP BY type
ORDER BY suspicious_amount DESC;

--------------------------------------------------------------------------------
-- 7. raport OLAP multidimensional de tip ROLLUP — raport ierarhic „risc × tip tranzacție” cu subtotaluri și total general.
--------------------------------------------------------------------------------

SELECT
    CASE
        WHEN GROUPING(r.risk_category) = 1 THEN '{TOTAL GENERAL}'
        ELSE r.risk_category
    END AS risk_category,
    CASE
        WHEN GROUPING(r.risk_category) = 1 THEN ' '
        WHEN GROUPING(t.type) = 1 THEN 'subtotal ' || r.risk_category
        ELSE t.type
    END AS transaction_type,
    COUNT(*) AS total_transactions,
    ROUND(SUM(t.amount), 2) AS total_amount,
    SUM(CASE WHEN t.isFraud = 1 THEN 1 ELSE 0 END) AS fraud_count
FROM FACT_TRANSACTIONS t
JOIN DIM_RISK r
    ON t.client_id = r.client_id
GROUP BY ROLLUP (r.risk_category, t.type)
ORDER BY r.risk_category, t.type;
