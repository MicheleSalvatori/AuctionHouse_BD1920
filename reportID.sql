
CREATE PROCEDURE db_prova.reportID (IN id VARCHAR(25))
SELECT CF_Utente AS "Utente", DATE_FORMAT(Insert_time, "%Y-%m-%d %H:%i:%s") AS "Data inserimento",
 Valore AS "Valore offerta", Max_val_controfferta AS"Controfferta", (SELECT IF(automatic, "Si", "No")) AS "Automatica" 
FROM db_prova.offerte WHERE offerte.Oggetto = id
ORDER BY offerte.Insert_time DESC;


drop procedure db_prova.reportID;
call db_prova.reportID(3);
select * from offerte;
call visualizza_aste_aperte();

