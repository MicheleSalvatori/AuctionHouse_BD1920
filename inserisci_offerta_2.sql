DELIMITER $$
DROP PROCEDURE IF EXISTS db_prova.inserisci_offerta_2;
CREATE PROCEDURE `inserisci_offerta_2`(IN CF VARCHAR(16), IN val_offerta VARCHAR(15), IN id VARCHAR(25), IN autoOfferta FLOAT)
BEGIN 
DECLARE result BOOLEAN DEFAULT FALSE;
DECLARE cfMax VARCHAR(16);
	IF EXISTS (SELECT * FROM db_prova.aste_aperte WHERE aste_aperte.ID = id)
		THEN IF EXISTS (SELECT * FROM db_prova.aste_aperte WHERE val_offerta > aste_aperte.PREZZO and aste_aperte.ID = id)
			THEN INSERT INTO  db_prova.offerte VALUES(CF, NOW(), val_offerta, autoOfferta, id);
            UPDATE db_prova.oggetto SET oggetto.Prezzo_attuale = val_offerta WHERE oggetto.Id_oggetto = id;
		ELSE SIGNAL SQLSTATE '02000' SET MESSAGE_TEXT = "Prezzo basso";
		END IF;
	ELSE SIGNAL SQLSTATE '02000' SET MESSAGE_TEXT = "Oggetto non presente";
    END IF;
    
	SELECT db_prova.checkAutoOfferta(CF, id, val_offerta) INTO result ;
    WHILE result = 1 DO
		if (result)
		then 
        Select db_prova.getCFMAX(CF, id, val_offerta) into cfMax;
		end if;
        -- prendiamo cf di colui che ha l'offerta maggiore, ma bisogna passarlo alla funzione qui sotto
        SELECT db_prova.checkAutoOfferta(CF, id, val_offerta) INTO result ;
    END WHILE;
END$$
DELIMITER ;

call inserisci_offerta_2("SLVMHL98T07A123X", 410, 1, null);