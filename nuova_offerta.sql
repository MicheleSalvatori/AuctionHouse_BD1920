DELIMITER $$
CREATE PROCEDURE db_prova.nuova_offerta(IN CF VARCHAR(16), IN id VARCHAR(25),IN val_offerta VARCHAR(15), IN autoOfferta FLOAT, IN automatic BOOLEAN)
this_proc:BEGIN 
DECLARE cfMax VARCHAR(16);
DECLARE lastOffer FLOAT;

-- contrallo se l'id esiste
	IF NOT EXISTS (SELECT * from db_prova.oggetto WHERE oggetto.Id_oggetto = id and oggetto.Data_termine > NOW())
		THEN SIGNAL SQLSTATE '02000' SET MESSAGE_TEXT = "Oggetto non in asta";
	END IF;
	IF NOT EXISTS (SELECT * FROM db_prova.offerte WHERE offerte.Oggetto = id) THEN
    INSERT INTO  db_prova.offerte VALUES(CF, NOW(6), val_offerta, autoOfferta, id, automatic);
    LEAVE this_proc;
    END IF;
    
-- controllo se è stato l'ultimo a mettere l'offerta
	CALL db_prova.getLastCF(id, cfMax);
    IF (cfMax != CF and cfMax is not null) then 
		CALL db_prova.getLastOffer(id, lastOffer);
        -- controllo se il valore dell'offerta è maggiore del valore attuale dell'oggetto
        IF (lastOffer >= val_offerta) THEN SIGNAL SQLSTATE '02000' SET MESSAGE_TEXT = "Devi inserire un'offerta maggiore";
		END IF;
        IF (autoOfferta <= val_offerta and !automatic) THEN SIGNAL SQLSTATE '02000' SET MESSAGE_TEXT = "Se vuoi inserire una controfferta automatica, essa deve essere maggiore dell'offerta attuale";
		END IF;
        INSERT INTO  db_prova.offerte VALUES(CF, NOW(6), val_offerta, autoOfferta, id, automatic);
    ELSE SIGNAL SQLSTATE '02000' SET MESSAGE_TEXT = "La tua offerta è già la più alta";
	END IF;

END $$


DELIMITER ;
drop procedure db_prova.nuova_offerta;

call db_prova.nuova_offerta("SLVMHL98T07A123X", 5, 20, null, false);
select * from db_prova.offerte;
call db_prova.getLastCF(3, @cf);
select * from oggetto where Id_oggetto = 5;