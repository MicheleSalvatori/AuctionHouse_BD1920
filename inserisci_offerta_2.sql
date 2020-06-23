DELIMITER $$
CREATE PROCEDURE `inserisci_offerta_2`(IN CF VARCHAR(16), IN val_offerta VARCHAR(15), IN id VARCHAR(25), IN autoOfferta FLOAT)
BEGIN 
DECLARE result BOOLEAN DEFAULT FALSE;
DECLARE cfMax VARCHAR(16);
DECLARE controfferta FLOAT;
-- controllo se è stato l'ultimo a mettere l'offerta
	IF EXISTS (SELECT * FROM db_prova.aste_aperte WHERE aste_aperte.ID = id)
		THEN IF EXISTS (SELECT * FROM db_prova.offerte WHERE val_offerta > Valore and Oggetto = id)
			THEN INSERT INTO  db_prova.offerte VALUES(CF, NOW(), val_offerta, autoOfferta, id);
            UPDATE db_prova.oggetto SET oggetto.Prezzo_attuale = val_offerta WHERE oggetto.Id_oggetto = id;
		ELSE SIGNAL SQLSTATE '02000' SET MESSAGE_TEXT = "Prezzo basso";
		END IF;
	ELSE SIGNAL SQLSTATE '02000' SET MESSAGE_TEXT = "Oggetto non presente";
    END IF;
    
    SELECT db_prova.checkAutoOfferta(CF, id, val_offerta) INTO result; 
    
	loop_label: LOOP
        IF (result) THEN
			call getCFMAX(CF, id, val_offerta, cfMax);
            call getMAXVALUE(cfMax, id, controfferta);
            INSERT INTO  db_prova.offerte VALUES(cfMax, TIMESTAMPADD(SECOND, 1,NOW()), val_offerta+0.50, controfferta, id);
            UPDATE db_prova.oggetto SET oggetto.Prezzo_attuale = val_offerta+0.50 WHERE oggetto.Id_oggetto = id;
			SELECT db_prova.checkAutoOfferta(cfMax, id, val_offerta) INTO result;
            ITERATE loop_label;
		ELSE LEAVE loop_label;
        END IF;
        END LOOP;

END$$
DELIMITER ;

-- dobbiamo prendere anche il valore massimo dell'offerta attuale, forse tramite l'utilizzo di una view più comodamente
-- mettere il loop in un'altra procedura?
-- ragionare bene con i valori delle offerte automatiche che si vanno ad inserire

drop procedure db_prova.inserisci_offerta_2;

call inserisci_offerta_2("SLVMHL98T07A123X", 155, 3, null);
select * from offerte;