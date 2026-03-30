- to open the postgREST connection in CMD use in path:
cd C:\Proiect_SIA03\postgREST
postgrest tutorial.conf

   - Test adress: 
   http://localhost:3000/transactions

- to open mongod in terminal:
mongod

- to open restheart using config:
"C:\Proiect_SIA03\support\restheart\restheart-windows-amd64.exe" -o "C:\Proiect_SIA03\support\restheart\conf-override.conf"

open ords:
cd C:\Proiect_SIA03\support\ords-latest\bin
ords --config C:\Proiect_SIA03\ORDS\ords-config serve

   - Test adress: 
   in browser: http://localhost:8080/ords/

verificare Enpointuri
http://localhost:8080/ords/fdbo/fraud_risk/
http://localhost:8080/ords/fdbo/fraud_type/
http://localhost:8080/ords/fdbo/cube_analysis/
http://localhost:8080/ords/fdbo/rollup_time/

open apex app:
http://localhost:8080/ords/apex_admin (creare workspace)
http://localhost:8080/ords/apex (creare si vizualizare aplicatii, logare ca developer)
