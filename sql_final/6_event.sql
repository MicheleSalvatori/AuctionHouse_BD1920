SET GLOBAL event_scheduler = ON;
DELIMITER $$

CREATE EVENT auction_house.endOffer
ON SCHEDULE EVERY 2 MINUTE
ON COMPLETION PRESERVE
	COMMENT 'Assegnazione aste terminate'
	DO
		BEGIN
						DECLARE id VARCHAR(15);
            DECLARE winnerCF VARCHAR(16);
            DECLARE winnerValue FLOAT;
						DECLARE cur cursor for select ID from auction_house.Oggetto WHERE Data_termine < NOW();
            open cur;
				read_loop: loop
					fetch cur into id;
                    IF EXISTS (SELECT * from auction_house.Offerta where Id_oggetto = id) THEN
                    CALL auction_house.getWinner(id, winnerCF, winnerValue);
                    INSERT INTO auction_house.Aggiudicato VALUES (id, winnerCF, winnerValue);
                    END IF;
				end loop;
			close cur;

    END$$
