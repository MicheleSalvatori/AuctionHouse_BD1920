DELIMITER $$

CREATE TRIGGER aste.check_valid_dataNascita BEFORE INSERT ON aste.utenti
	FOR EACH ROW

    BEGIN
		IF (NEW.Data_nascita > CURDATE()) THEN
			SIGNAL SQLSTATE '02000' SET MESSAGE_TEXT = 'Attenzione data di nascita non valida';

		END IF;

	END $$


CREATE TRIGGER aste.check_valid_dataScadenza BEFORE INSERT ON aste.utenti
	FOR EACH ROW

    BEGIN

		DECLARE anno VARCHAR(4);
        DECLARE mese VARCHAR(2);
        SET anno := substring(New.data_scadenza,1, 4);
        SET mese := substring(New.data_scadenza,6, 7);

        IF (anno < YEAR(CURDATE()) or (anno = YEAR(CURDATE()) and mese < MONTH(CURDATE()))) THEN
			SIGNAL SQLSTATE '02000' SET MESSAGE_TEXT = 'Attenzione data di scadenza carta non valida';

        END IF;


    END $$

	CREATE TRIGGER aste.check_exist_tipo BEFORE INSERT ON aste.oggetto
			FOR EACH ROW
			BEGIN
				DECLARE temp_int INT;
		        SELECT count(*) INTO temp_int FROM aste.tipo_oggetto WHERE Nome_Oggetto = NEW.Tipo;
		        IF (temp_int = 0) THEN
		        SIGNAL SQLSTATE '02000' SET MESSAGE_TEXT = "Tipo oggetto non presente nel database";
		        END IF;
			END $$

	CREATE TRIGGER aste.check_scadenza_asta BEFORE INSERT ON aste.oggetto
			FOR EACH ROW
		    BEGIN
		    DECLARE h INT;

				SELECT TIMESTAMPDIFF(SECOND,NOW(), NEW.Data_termine) INTO h;
		        IF (h < 24*60*60 OR h>24*7*60*60)
		        THEN SIGNAL SQLSTATE '02000' SET MESSAGE_TEXT = "Attenzione: l'asta deve durare almeno 1 GIORNO e massimo 7 GIORNI";
		        END IF;
			END $$
