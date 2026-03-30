DROP TABLE IF EXISTS customers.transactions;

CREATE TABLE customers.transactions (
    client_id         INT,
    step              INT,
    type              VARCHAR(20),
    amount            NUMERIC(15,2),
    nameOrig          VARCHAR(50),
    oldbalanceOrg     NUMERIC(15,2),
    newbalanceOrig    NUMERIC(15,2),
    nameDest          VARCHAR(50),
    oldbalanceDest    NUMERIC(15,2),
    newbalanceDest    NUMERIC(15,2),
    isFraud           INT,
    isFlaggedFraud    INT
);

SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_schema = 'customers'
  AND table_name = 'transactions';

SELECT * from customers.transactions;