CREATE OR REPLACE VIEW V_CLIENT_DEMOGRAPHICS_XLS AS
SELECT t.*
FROM TABLE(
    ExcelTable.getRows(
        ExcelTable.getFile('EXT_FILE_DS', 'bank_marketing.xlsx'),
        'Demographics',
        '"client_id" NUMBER,
         "age" NUMBER,
         "job" VARCHAR2(100),
         "marital" VARCHAR2(50),
         "education" VARCHAR2(50)',
        'A2'
    )
) t;

SELECT *
FROM V_CLIENT_DEMOGRAPHICS_XLS
WHERE ROWNUM <= 10;