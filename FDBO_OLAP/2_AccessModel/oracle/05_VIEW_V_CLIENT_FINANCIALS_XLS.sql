CREATE OR REPLACE VIEW V_CLIENT_FINANCIALS_XLS AS
SELECT t.*
FROM TABLE(
    ExcelTable.getRows(
        ExcelTable.getFile('EXT_FILE_DS', 'bank_marketing.xlsx'),
        'Financials',
        '"client_id" NUMBER,
         "balance" NUMBER,
         "housing" VARCHAR2(10),
         "loan" VARCHAR2(10)',
        'A2'
    )
) t;

SELECT *
FROM V_CLIENT_FINANCIALS_XLS
WHERE ROWNUM <= 10;