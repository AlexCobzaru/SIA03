--------------------------------------------------------------------------------
-- DEMO FINAL PROIECT: Sistem de analiză și monitorizare a tranzacțiilor bancare
--------------------------------------------------------------------------------
-- USER: FDBO_XE
--
-- Acest script:
-- 1. verifică sursele externe
-- 2. creează view-ul de integrare
-- 3. creează modelul dimensional ROLAP
-- 4. creează fact view-ul
-- 5. creează view-urile OLAP
-- 6. adaugă un view cu WINDOW FUNCTION
-- 7. rulează interogări de test și prezentare
--
-- Servicii externe care trebuie pornite înainte de demo:
--
-- 1. PostgreSQL + PostgREST
--    cd C:\Proiect_SIA03\postgREST
--    postgrest tutorial.conf
--
-- 2. MongoDB
--    mongod
--
-- 3. RESTHeart
--    "C:\Proiect_SIA03\support\restheart\restheart-windows-amd64.exe" -o
--    "C:\Proiect_SIA03\support\restheart\conf-override.conf"
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- 0. TEST RAPID AL SURSELOR EXTERNE
--------------------------------------------------------------------------------

-- DS_1: Excel / profil client
SELECT *
FROM V_CLIENT_PROFILE_XLS
FETCH FIRST 3 ROWS ONLY;

-- DS_2: PostgreSQL / flux tranzacții
SELECT *
FROM V_TRANSACTION_STREAM_PG
FETCH FIRST 3 ROWS ONLY;

-- DS_3: MongoDB / risc client
SELECT *
FROM V_CLIENT_RISK_MONGO
FETCH FIRST 3 ROWS ONLY;


--------------------------------------------------------------------------------
-- 1. VIEW DE INTEGRARE
--------------------------------------------------------------------------------
-- View-ul central de integrare păstrează toate tranzacțiile și aduce alături
-- datele descriptive din Excel și datele de risc din MongoDB.
--------------------------------------------------------------------------------

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

-- Preview integrare
SELECT *
FROM V_CLIENT_TRANSACTION_RISK
FETCH FIRST 5 ROWS ONLY;

-- Verificare consistență integrare
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
-- 2. DIMENSIONAL VIEWS (MODEL ROLAP)
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- D1. DIM_CLIENTS
--------------------------------------------------------------------------------
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

SELECT *
FROM DIM_CLIENTS
FETCH FIRST 3 ROWS ONLY;

SELECT
    client_id,
    COUNT(*) AS cnt
FROM DIM_CLIENTS
GROUP BY client_id
HAVING COUNT(*) > 1;


--------------------------------------------------------------------------------
-- D2. DIM_RISK
--------------------------------------------------------------------------------
-- Categoria de risc este derivată din risk_score conform documentației:
--   HIGH   >= 0.8
--   MEDIUM >= 0.5
--   LOW    altfel
--------------------------------------------------------------------------------
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

SELECT *
FROM DIM_RISK
FETCH FIRST 10 ROWS ONLY;

SELECT
    risk_category,
    COUNT(*) AS total_clients
FROM DIM_RISK
GROUP BY risk_category
ORDER BY total_clients DESC;


--------------------------------------------------------------------------------
-- D3. DIM_TRANSACTION_TYPE
--------------------------------------------------------------------------------
CREATE OR REPLACE VIEW DIM_TRANSACTION_TYPE AS
SELECT DISTINCT
    type
FROM V_CLIENT_TRANSACTION_RISK;

SELECT *
FROM DIM_TRANSACTION_TYPE;


--------------------------------------------------------------------------------
-- D4. DIM_TIME
--------------------------------------------------------------------------------
CREATE OR REPLACE VIEW DIM_TIME AS
SELECT DISTINCT
    step AS time_step
FROM V_CLIENT_TRANSACTION_RISK;

SELECT *
FROM DIM_TIME
ORDER BY time_step
FETCH FIRST 20 ROWS ONLY;


--------------------------------------------------------------------------------
-- 3. FACT VIEW
--------------------------------------------------------------------------------
CREATE OR REPLACE VIEW FACT_TRANSACTIONS AS
SELECT
    client_id,
    step,
    type,
    amount,
    isFraud,
    isFlaggedFraud
FROM V_CLIENT_TRANSACTION_RISK;

SELECT *
FROM FACT_TRANSACTIONS
FETCH FIRST 10 ROWS ONLY;

SELECT COUNT(*) AS total_transactions
FROM FACT_TRANSACTIONS;

SELECT
    isFraud,
    COUNT(*) AS total_rows
FROM FACT_TRANSACTIONS
GROUP BY isFraud
ORDER BY isFraud;

SELECT
    COUNT(*) AS total_transactions,
    ROUND(SUM(amount), 2) AS total_amount
FROM FACT_TRANSACTIONS;


--------------------------------------------------------------------------------
-- 4. VIEW OPERAȚIONAL DE MONITORIZARE
--------------------------------------------------------------------------------
CREATE OR REPLACE VIEW F_TRANSACTION_MONITORING AS
SELECT
    client_id,
    step,
    type,
    amount,
    isFraud,
    isFlaggedFraud
FROM FACT_TRANSACTIONS;

SELECT *
FROM F_TRANSACTION_MONITORING
FETCH FIRST 10 ROWS ONLY;


--------------------------------------------------------------------------------
-- 5. VIEW-URI OLAP
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- OLAP 1. Fraud by Risk
--------------------------------------------------------------------------------
CREATE OR REPLACE VIEW OLAP_FRAUD_BY_RISK AS
SELECT
    r.risk_category,
    COUNT(*) AS total_transactions,
    SUM(f.amount) AS total_amount,
    SUM(CASE WHEN f.isFraud = 1 THEN 1 ELSE 0 END) AS fraud_count
FROM FACT_TRANSACTIONS f
JOIN DIM_RISK r
    ON f.client_id = r.client_id
GROUP BY r.risk_category;

SELECT *
FROM OLAP_FRAUD_BY_RISK;

SELECT
    SUM(total_transactions) AS total_transactions_check
FROM OLAP_FRAUD_BY_RISK;


--------------------------------------------------------------------------------
-- OLAP 2. Fraud by Transaction Type
--------------------------------------------------------------------------------
CREATE OR REPLACE VIEW OLAP_FRAUD_BY_TYPE AS
SELECT
    type,
    COUNT(*) AS total_transactions,
    SUM(amount) AS total_amount,
    SUM(CASE WHEN isFraud = 1 THEN 1 ELSE 0 END) AS fraud_count
FROM FACT_TRANSACTIONS
GROUP BY type;

SELECT *
FROM OLAP_FRAUD_BY_TYPE;

SELECT
    COUNT(DISTINCT type) AS distinct_types
FROM FACT_TRANSACTIONS;


--------------------------------------------------------------------------------
-- OLAP 3. CUBE Analysis
--------------------------------------------------------------------------------
CREATE OR REPLACE VIEW OLAP_CUBE_ANALYSIS AS
SELECT
    r.risk_category,
    f.type,
    COUNT(*) AS total_transactions,
    SUM(f.amount) AS total_amount
FROM FACT_TRANSACTIONS f
JOIN DIM_RISK r
    ON f.client_id = r.client_id
GROUP BY CUBE (r.risk_category, f.type);

SELECT *
FROM OLAP_CUBE_ANALYSIS
ORDER BY risk_category, type;

SELECT *
FROM OLAP_CUBE_ANALYSIS
WHERE risk_category IS NULL
  AND type IS NULL;


--------------------------------------------------------------------------------
-- OLAP 4. ROLLUP Time Analysis
--------------------------------------------------------------------------------
CREATE OR REPLACE VIEW OLAP_ROLLUP_TIME AS
SELECT
    step,
    type,
    SUM(amount) AS total_amount
FROM FACT_TRANSACTIONS
GROUP BY ROLLUP (step, type);

SELECT *
FROM OLAP_ROLLUP_TIME
ORDER BY step, type;

SELECT *
FROM OLAP_ROLLUP_TIME
WHERE type IS NULL
ORDER BY step;


--------------------------------------------------------------------------------
-- 6. WINDOW FUNCTION VIEW
--------------------------------------------------------------------------------
-- Extensie analitică:
-- extrage primele 5 tranzacții ca valoare din interiorul fiecărui tip.
-- rn = row number (numărul rândului),  reprezintă poziția tranzacției în clasamentul valorilor din cadrul fiecărui tip de tranzacție.
--Am folosit funcția ROW_NUMBER() pentru a identifica top 5 cele mai mari tranzacții per tip.
--------------------------------------------------------------------------------
CREATE OR REPLACE VIEW V_TOP_TRANSACTIONS AS
SELECT
    client_id,
    step,
    type,
    amount,
    isFraud,
    isFlaggedFraud,
    rn
FROM (
    SELECT
        client_id,
        step,
        type,
        amount,
        isFraud,
        isFlaggedFraud,
        ROW_NUMBER() OVER (
            PARTITION BY type
            ORDER BY amount DESC, client_id
        ) AS rn
    FROM FACT_TRANSACTIONS
)
WHERE rn <= 5;

SELECT *
FROM V_TOP_TRANSACTIONS
ORDER BY type, rn;


--------------------------------------------------------------------------------
-- 7. INTEROGĂRI ANALITICE PENTRU DEMO
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Q1. Top clienți după suma tranzacțiilor suspecte
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
-- Q2. Clienți cu risc ridicat și tranzacții frauduloase
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
-- Q3. Matrice risc x tip tranzacție
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
-- Q4. Ponderea fraudelor în total tranzacții
--------------------------------------------------------------------------------
SELECT
    ROUND(100 * SUM(CASE WHEN isFraud = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS fraud_percentage,
    ROUND(100 * SUM(CASE WHEN isFlaggedFraud = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS flagged_percentage
FROM FACT_TRANSACTIONS;


--------------------------------------------------------------------------------
-- Q5. Corelare între profil financiar și risc
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
-- Q6. Distribuția sumelor pe risc și tip tranzacție
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
-- Q8. Analiza pe tipuri de tranzacții suspecte
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
-- 8. RAPORT FINAL: ROLLUP MULTIDIMENSIONAL
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
