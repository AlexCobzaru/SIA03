CREATE OR REPLACE VIEW V_TRANSACTION_STREAM_PG AS
SELECT *
FROM JSON_TABLE(
    HTTPURITYPE.createuri('http://localhost:3000/transactions').getclob(),
    '$[*]'
    COLUMNS (
        client_id NUMBER PATH '$.client_id',
        step NUMBER PATH '$.step',
        type VARCHAR2(20) PATH '$.type',
        amount NUMBER PATH '$.amount',
        nameOrig VARCHAR2(50) PATH '$.nameorig',
        nameDest VARCHAR2(50) PATH '$.namedest',
        oldbalanceOrg NUMBER PATH '$.oldbalanceorg',
        newbalanceOrig NUMBER PATH '$.newbalanceorig',
        oldbalanceDest NUMBER PATH '$.oldbalancedest',
        newbalanceDest NUMBER PATH '$.newbalancedest',
        isFraud NUMBER PATH '$.isfraud',
        isFlaggedFraud NUMBER PATH '$.isflaggedfraud'
    )
);

SELECT * 
FROM V_TRANSACTION_STREAM_PG
WHERE ROWNUM <= 10;

SELECT * 
FROM V_TRANSACTION_STREAM_PG
WHERE ROWNUM < 100;

SELECT * FROM V_TRANSACTION_STREAM_PG
WHERE amount <= 50000;