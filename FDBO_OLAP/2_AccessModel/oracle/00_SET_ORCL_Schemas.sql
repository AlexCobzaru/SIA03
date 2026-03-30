-- 1. Ștergem userul dacă există (opțional, dar util la rerulare)
BEGIN
   EXECUTE IMMEDIATE 'DROP USER fdbo CASCADE';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -01918 THEN
         RAISE;
      END IF;
END;
/

-- 2. Creăm userul principal pentru proiect (mediatorul)
CREATE USER fdbo IDENTIFIED BY fdbo
DEFAULT TABLESPACE users
TEMPORARY TABLESPACE temp
QUOTA UNLIMITED ON users;

-- 3. Privilegii de bază
GRANT CONNECT, RESOURCE TO fdbo;

-- 4. Privilegii necesare pentru proiect FDB (foarte importante)
GRANT CREATE VIEW TO fdbo;
GRANT CREATE DATABASE LINK TO fdbo;
GRANT CREATE ANY DIRECTORY TO fdbo;

-- 5. Pentru acces HTTP (PostgREST + RESTHeart)
GRANT EXECUTE ON UTL_HTTP TO fdbo;

-- 6. Pentru manipulare CLOB (necesar la JSON)
GRANT EXECUTE ON DBMS_LOB TO fdbo;

-- 7. (opțional dar recomandat) pentru funcții auxiliare
GRANT EXECUTE ON DBMS_CRYPTO TO fdbo;

-- 8. Permitem acces HTTP extern (FOARTE IMPORTANT)
BEGIN
   DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE(
      host => '*',
      ace  => xs$ace_type(
                privilege_list => xs$name_list('http'),
                principal_name => 'FDBO',
                principal_type => xs_acl.ptype_db
             )
   );
END;
/