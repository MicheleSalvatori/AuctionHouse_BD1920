DELIMITER $$
DROP Function IF EXISTS db_prova.checkAutoOfferta;
CREATE FUNCTION db_prova.checkAutoOfferta (CF VARCHAR(16), id VARCHAR(25),  valore FLOAT)
RETURNS BOOLEAN
BEGIN 
	IF EXISTS (SELECT * FROM db_prova.offerte WHERE CF_Utente != CF and Oggetto = id and Max_val_controfferta > valore)
	THEN RETURN TRUE;
    ELSE RETURN FALSE;
    END IF;
END $$
DELIMITER ;

select db_prova.checkAutoOfferta ("SLVMHL98T07A123X", 1, 6009);
select NOW(), timestampadd(SECOND, 1, NOW());