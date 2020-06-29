SET GLOBAL event_scheduler = ON;
DELIMITER $$

CREATE EVENT aste.endOffer
ON SCHEDULE EVERY 2 MINUTE
ON COMPLETION PRESERVE
	COMMENT 'Assegnazione aste terminate'
	DO
		BEGIN
			DECLARE id VARCHAR(15);
            DECLARE winnerCF VARCHAR(16);
            DECLARE winnerValue FLOAT;
			DECLARE cur cursor for select Id_oggetto from aste.oggetto WHERE Data_termine < NOW();
            open cur;
				read_loop: loop
					fetch cur into id;
                    IF EXISTS (SELECT * from aste.offerte where Oggetto = id) THEN
                    CALL aste.getWinner(id, winnerCF, winnerValue);
                    INSERT INTO aste.aggiudicati VALUES (id, winnerCF, winnerValue);
                    END IF;
				end loop;
			close cur;

    END$$
