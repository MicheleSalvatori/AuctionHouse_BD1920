SET GLOBAL event_scheduler = ON;

DELIMITER $$

CREATE EVENT auction_house.test
ON SCHEDULE EVERY 1 HOUR
ON COMPLETION PRESERVE
	COMMENT 'ciao'
	DO
		BEGIN
			INSERT INTO auction_house.prova VALUES (now());
		
        END$$
        
        
DELIMITER ;

drop event auction_house.test;