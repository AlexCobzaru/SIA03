DROP ROLE IF EXISTS authenticator;
DROP ROLE IF EXISTS web_anon;

-- rol anonim pentru API
CREATE ROLE web_anon NOLOGIN;

GRANT USAGE ON SCHEMA customers TO web_anon;
GRANT SELECT ON customers.transactions TO web_anon;

-- rolul folosit de PostgREST la conectare
CREATE ROLE authenticator NOINHERIT LOGIN PASSWORD 'authenticator';
GRANT web_anon TO authenticator;

SELECT rolname
FROM pg_roles
WHERE rolname IN ('web_anon', 'authenticator');

SELECT grantee, table_schema, table_name, privilege_type
FROM information_schema.role_table_grants
WHERE table_schema = 'customers'
  AND table_name = 'transactions';