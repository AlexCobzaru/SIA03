DROP DIRECTORY ext_file_ds;

CREATE OR REPLACE DIRECTORY ext_file_ds AS 'C:\Proiect_SIA03\data';

GRANT READ, WRITE ON DIRECTORY ext_file_ds TO FDBO;

SELECT directory_name, directory_path
FROM all_directories
WHERE directory_name = 'EXT_FILE_DS';

SELECT *
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
)
WHERE ROWNUM <= 5;