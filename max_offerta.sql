DELIMITER $$
CREATE PROCEDURE db_prova.autoOfferta (IN CF VARCHAR(16), IN id VARCHAR(25), IN valore FLOAT)
BEGIN 
DECLARE cfAutoOfferta VARCHAR(16);
DECLARE maxAutoOfferta FLOAT;
	IF EXISTS (SELECT * FROM db_prova.max_controfferta WHERE max_controfferta.CF_Utente != CF and max_controfferta.Max_val_controfferta >= valore and max_controfferta.Oggetto = id)
    THEN 
    SELECT CF_Utente INTO cfAutoOfferta FROM db_prova.max_controfferta WHERE max_controfferta.CF_Utente != CF and max_controfferta.Max_val_controfferta >= valore and max_controfferta.Oggetto = id and Insert_time = (Select distinct MAX(Insert_time) from db_prova.max_controfferta where CF_Utente != CF);
    END IF;
    IF (cfAutoOfferta is not null) THEN
    SELECT Max_val_controfferta INTO maxAutoOfferta FROM db_prova.max_controfferta WHERE max_controfferta.CF_Utente = cfAutoOfferta and max_controfferta.Max_val_controfferta >= valore and max_controfferta.Oggetto = id and Insert_time = (Select distinct MAX(Insert_time) from db_prova.max_controfferta where CF_Utente != CF);
    -- call db_prova.inserisci_offerta(cfAutoOfferta, valore, id, maxAutoOfferta);
   END IF;
    Select cfAutoOfferta, maxAutoOfferta;
END $$
DELIMITER ;

DROP PROCEDURE db_prova.autoOfferta;
call db_prova.autoOfferta("SLVMHL98T07A123X", 1, 302.50);

-- sel-- ect MAX(Insert_time) from db_prova.offerte where


Select distinct MAX(Insert_time) from db_prova.max_controfferta where CF_Utente != "SLVMHL98T07A123X";