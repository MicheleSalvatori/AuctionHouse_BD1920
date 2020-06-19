DELIMITER $$
-- DROP Function IF EXISTS db_prova.getCFMAX;
CREATE FUNCTION db_prova.getCFMAX (CF VARCHAR(16), id VARCHAR(25),  valore FLOAT)
RETURNS VARCHAR(16)
BEGIN 
DECLARE cfAutoOfferta VARCHAR(16);
DECLARE maxAutoOfferta FLOAT;
	IF EXISTS (SELECT * FROM db_prova.offerte WHERE CF_Utente != CF and Oggetto = id and Max_val_controfferta > valore and Insert_time = (Select distinct MAX(Insert_time) from db_prova.max_controfferta where CF_Utente != CF)) 
	THEN SELECT CF_Utente INTO cfAutoOfferta FROM db_prova.offerte WHERE CF_Utente != CF and Oggetto = id and Max_val_controfferta > valore and Insert_time = (Select distinct MAX(Insert_time) from db_prova.max_controfferta where CF_Utente != CF);
    RETURN cfAutoOfferta;
    END IF;
END $$
DELIMITER ;

select db_prova.getCFMAX("SLVMHL98T07A123X", 1, 306);