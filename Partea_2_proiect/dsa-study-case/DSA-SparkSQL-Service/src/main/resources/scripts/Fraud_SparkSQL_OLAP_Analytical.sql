------ Preparing ---------------------------------------------------------------
--- Fraud Monitoring SparkSQL Integration
--- DSA-SQL-JDBCService: PostgreSQL Data Source [Transactions]
--- DSA-DOC-XLSService: Excel Data Source [Client Profiles]
--- DSA-NoSQL-MongoDBService: MongoDB Data Source [Client Risk]
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- 1. Data Source Remote/External Views
-- REST endpoints are transformed into SparkSQL JSON views
--------------------------------------------------------------------------------

SELECT java_method(
    'org.spark.service.rest.RESTEnabledSQLService',
    'createJSONViewFromREST',
    'TRANSACTIONS_VIEW',
    'http://localhost:8090/DSA-SQL-JDBCService/rest/customers/TransactionsView'
);

SELECT java_method(
    'org.spark.service.rest.RESTEnabledSQLService',
    'createJSONViewFromREST',
    'CLIENT_PROFILE_VIEW',
    'http://localhost:8094/DSA-DOC-XLSService/rest/customers/ClientProfileView'
);

SELECT java_method(
    'org.spark.service.rest.RESTEnabledSQLService',
    'createJSONViewFromREST',
    'CLIENT_RISK_VIEW',
    'http://localhost:8093/DSA-NoSQL-MongoDBService/rest/locations/ClientRiskView'
);

--------------------------------------------------------------------------------
-- 2. Test Remote Views
--------------------------------------------------------------------------------

SELECT * FROM TRANSACTIONS_VIEW;
SELECT * FROM CLIENT_PROFILE_VIEW;
SELECT * FROM CLIENT_RISK_VIEW;

--------------------------------------------------------------------------------
-- 3. Flatten REST JSON Array Views
-- REST views are initially created as ARRAY<STRUCT<...>>, therefore explode(array)
-- is used to transform the JSON arrays into relational rows.
--------------------------------------------------------------------------------

DROP VIEW IF EXISTS TRANSACTIONS_FLAT_VIEW;
CREATE OR REPLACE VIEW TRANSACTIONS_FLAT_VIEW AS
SELECT
    x.clientId,
    x.step,
    x.type,
    x.amount,
    x.nameOrig,
    x.nameDest,
    x.isFraud,
    x.isFlaggedFraud
FROM TRANSACTIONS_VIEW
LATERAL VIEW explode(array) exploded_table AS x;

DROP VIEW IF EXISTS CLIENT_PROFILE_FLAT_VIEW;
CREATE OR REPLACE VIEW CLIENT_PROFILE_FLAT_VIEW AS
SELECT
    x.clientId,
    x.age,
    x.job,
    x.marital,
    x.education,
    x.balance,
    x.housing,
    x.loan
FROM CLIENT_PROFILE_VIEW
LATERAL VIEW explode(array) exploded_table AS x;

DROP VIEW IF EXISTS CLIENT_RISK_FLAT_VIEW;
CREATE OR REPLACE VIEW CLIENT_RISK_FLAT_VIEW AS
SELECT
    x.clientId,
    x.riskScore,
    x.currency,
    x.status
FROM CLIENT_RISK_VIEW
LATERAL VIEW explode(array) exploded_table AS x;

--------------------------------------------------------------------------------
-- 4. Test Flattened Views
--------------------------------------------------------------------------------

SELECT * FROM TRANSACTIONS_FLAT_VIEW;
SELECT * FROM CLIENT_PROFILE_FLAT_VIEW;
SELECT * FROM CLIENT_RISK_FLAT_VIEW;

--------------------------------------------------------------------------------
-- 5. Integrated Consolidation View
-- This view integrates the heterogeneous sources by clientId:
-- PostgreSQL transactions + Excel client profile + MongoDB risk information.
--------------------------------------------------------------------------------

DROP VIEW IF EXISTS CLIENT_TRANSACTION_RISK_VIEW;
CREATE OR REPLACE VIEW CLIENT_TRANSACTION_RISK_VIEW AS
SELECT
    concat(cast(t.clientId as string), '_', cast(t.step as string), '_', t.nameOrig, '_', t.nameDest) AS transactionKey,
    t.clientId,
    t.step,
    t.type,
    t.amount,
    t.nameOrig,
    t.nameDest,
    t.isFraud,
    t.isFlaggedFraud,

    p.age,
    p.job,
    p.marital,
    p.education,
    p.balance,
    p.housing,
    p.loan,

    r.riskScore,
    r.currency,
    r.status
FROM TRANSACTIONS_FLAT_VIEW t
LEFT JOIN CLIENT_PROFILE_FLAT_VIEW p
    ON t.clientId = p.clientId
LEFT JOIN CLIENT_RISK_FLAT_VIEW r
    ON t.clientId = r.clientId;

SELECT * FROM CLIENT_TRANSACTION_RISK_VIEW;

--------------------------------------------------------------------------------
-- 6. Analytical / OLAP Views
--------------------------------------------------------------------------------

DROP VIEW IF EXISTS OLAP_FRAUD_BY_TYPE_SPARK;
CREATE OR REPLACE VIEW OLAP_FRAUD_BY_TYPE_SPARK AS
SELECT
    type,
    COUNT(*) AS total_transactions,
    SUM(amount) AS total_amount,
    SUM(isFraud) AS fraud_count
FROM CLIENT_TRANSACTION_RISK_VIEW
GROUP BY type;

SELECT * FROM OLAP_FRAUD_BY_TYPE_SPARK;

--------------------------------------------------------------------------------

DROP VIEW IF EXISTS OLAP_FRAUD_BY_RISK_SPARK;
CREATE OR REPLACE VIEW OLAP_FRAUD_BY_RISK_SPARK AS
SELECT
    concat(status, '_', currency) AS riskKey,
    status,
    currency,
    COUNT(*) AS total_transactions,
    SUM(amount) AS total_amount,
    SUM(isFraud) AS fraud_count,
    AVG(riskScore) AS avg_risk_score
FROM CLIENT_TRANSACTION_RISK_VIEW
GROUP BY status, currency;

SELECT * FROM OLAP_FRAUD_BY_RISK_SPARK;

--------------------------------------------------------------------------------
-- 7. REST Test URLs for SparkSQL Views
--------------------------------------------------------------------------------
-- http://localhost:9990/DSA-SparkSQL-Service/rest/view/CLIENT_TRANSACTION_RISK_VIEW
-- http://localhost:9990/DSA-SparkSQL-Service/rest/view/OLAP_FRAUD_BY_TYPE_SPARK
-- http://localhost:9990/DSA-SparkSQL-Service/rest/view/OLAP_FRAUD_BY_RISK_SPARK
--------------------------------------------------------------------------------