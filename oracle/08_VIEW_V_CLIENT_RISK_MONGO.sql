CREATE OR REPLACE VIEW V_CLIENT_RISK_MONGO AS
WITH json_doc AS (
    SELECT get_restheart_data_media(
        'http://localhost:8081/client_risk',
        'admin:secret'
    ) AS doc
    FROM dual
)
SELECT
    client_id,
    risk_score,
    currency,
    status
FROM JSON_TABLE(
    (SELECT doc FROM json_doc),
    '$[*]'
    COLUMNS (
        client_id   NUMBER        PATH '$.client_id',
        risk_score  NUMBER        PATH '$.risk_score',
        currency    VARCHAR2(10)  PATH '$.currency',
        status      VARCHAR2(30)  PATH '$.status'
    )
);

SELECT *
FROM V_CLIENT_RISK_MONGO
WHERE ROWNUM <= 10;