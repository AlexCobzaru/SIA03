//Interogarea 1 — număr de tranzacții pe categorie de risc
SELECT risk_category, COUNT(*) AS total_transactions
FROM V_FRAUD_MONITORING
GROUP BY risk_category
ORDER BY total_transactions DESC;

//Interogarea 2 — sumă totală pe tip de tranzacție
SELECT type, ROUND(SUM(amount), 2) AS total_amount
FROM V_FRAUD_MONITORING
GROUP BY type
ORDER BY total_amount DESC;

//Interogarea 3 — tranzacții frauduloase pe status client
SELECT status, COUNT(*) AS fraud_count
FROM V_FRAUD_MONITORING
WHERE isFraud = 1
GROUP BY status
ORDER BY fraud_count DESC;

//Interogarea 4 — top clienți după valoarea tranzacțiilor suspecte
SELECT client_id, ROUND(SUM(amount), 2) AS suspicious_amount
FROM V_FRAUD_MONITORING
WHERE isFraud = 1 OR isFlaggedFraud = 1
GROUP BY client_id
ORDER BY suspicious_amount DESC;

//Interogarea 5 — analiză combinată risc + tip tranzacție
SELECT risk_category, type, COUNT(*) AS total_transactions
FROM V_FRAUD_MONITORING
GROUP BY risk_category, type
ORDER BY risk_category, total_transactions DESC;