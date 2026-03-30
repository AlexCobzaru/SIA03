CREATE OR REPLACE VIEW V_CLIENT_PROFILE_XLS AS
SELECT
    d."client_id" AS client_id,
    d."age" AS age,
    d."job" AS job,
    d."marital" AS marital,
    d."education" AS education,
    f."balance" AS balance,
    f."housing" AS housing,
    f."loan" AS loan
FROM V_CLIENT_DEMOGRAPHICS_XLS d
JOIN V_CLIENT_FINANCIALS_XLS f
  ON d."client_id" = f."client_id";

SELECT *
FROM V_CLIENT_PROFILE_XLS
WHERE ROWNUM <= 10;