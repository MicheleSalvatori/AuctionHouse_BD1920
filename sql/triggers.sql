DELIMITER $$

CREATE TRIGGER db_prova.check_valid_dataNascita BEFORE INSERT ON db_prova.utenti
	FOR EACH ROW

    BEGIN
		IF (NEW.Data_nascita > CURDATE()) THEN
			SIGNAL SQLSTATE '02000' SET MESSAGE_TEXT = 'Attenzione data di nascita non valida';

            #SET NEW.Data_nascita = curdate();
		END IF;

	END $$


CREATE TRIGGER db_prova.check_valid_dataScadenza BEFORE INSERT ON db_prova.utenti
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
