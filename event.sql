SET GLOBAL event_scheduler = ON;

DELIMITER $$

CREATE EVENT db_prova.endOffer
ON SCHEDULE EVERY 2 MINUTE
ON COMPLETION PRESERVE
	COMMENT 'Assegnazione aste finite'
	DO
		BEGIN
			DECLARE id VARCHAR(15);
            DECLARE winnerCF VARCHAR(16);
            DECLARE winnerValue FLOAT;
			DECLARE cur cursor for select Id_oggetto from db_prova.oggetto WHERE Data_termine < NOW();
            open cur;
				read_loop: loop
					fetch cur into id;
                    IF EXISTS (SELECT * from db_prova.offerte where Oggetto = id) THEN 
                    CALL db_prova.getWinner(id, winnerCF, winnerValue);
                    INSERT INTO db_prova.provaEvento VALUES (id);
                    INSERT INTO db_prova.aggiudicati VALUES (id, winnerCF, winnerValue);
                    END IF;
				end loop;
			close cur;
		
        END$$
        
        
DELIMITER ;

drop event db_prova.endOffer;
SHOW PROCESSLIST;
select * from provaEvento;
select * from aggiudicati;
select * from offerte where Oggetto = 3;
call visualizza_aste_aperte();
delete from db_prova.provaEvento Where id != "aaap";
select * from db_prova.oggetto where oggetto.Data_termine < NOW();
CREATE TABLE db_prova.provaEvento (id VARCHAR(15) primary key);
DROP TABLE db_prova.provaEvento;
select * from oggetto;