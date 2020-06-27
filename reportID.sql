DELIMITER $$
CREATE PROCEDURE db_prova.reportID (IN id VARCHAR(25))
BEGIN
	IF (SELECT NOT EXISTS (SELECT Id_oggetto FROM db_prova.oggetto WHERE Id_oggetto = id))
    THEN SIGNAL SQLSTATE '02000' SET MESSAGE_TEXT = "Oggetto non presente nel database";
    END IF;
    
	SELECT CF_Utente AS "Utente", DATE_FORMAT(Insert_time, "%Y-%m-%d %H:%i:%s") AS "Data inserimento",
	CAST(Valore AS CHAR)AS "Valore offerta",(SELECT IF(automatic, "Si", "No")) AS "Automatica" 
	FROM db_prova.offerte WHERE offerte.Oggetto = id
	ORDER BY offerte.Insert_time DESC;
END $$

DELIMITER ;


drop procedure db_prova.reportID;
call db_prova.reportID(A145);
select * from offerte;
call visualizza_aste_aperte();

