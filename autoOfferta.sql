DELIMITER $$
CREATE PROCEDURE autoOfferta (IN CF VARCHAR(16), IN id VARCHAR(25), IN valore FLOAT)
BEGIN
	DECLARE result BOOLEAN DEFAULT FALSE;
    DECLARE cfMax VARCHAR(16);
    DECLARE maxAutoOffer FLOAT;
    DECLARE newOffer FLOAT;
    SET newOffer = valore;
    SELECT db_prova.checkAutoOfferta(CF, id, valore) INTO result;
	
    loop_label: LOOP
        IF (result) THEN
			SET newOffer = newOffer + 0.50;
			call db_prova.getMaxCF(CF, id, valore, cfMax);
			call db_prova.getMAXVALUE(cfMax, id, maxAutoOffer);
			call db_prova.nuova_offerta(cfMax, id, newOffer, maxAutoOffer);
			SELECT db_prova.checkAutoOfferta(cfMax, id, newOffer);
			ITERATE loop_label;
        ELSE LEAVE loop_label;
        END IF;
        END LOOP;
END $$

DELIMITER ;
select * from offerte;
drop procedure db_prova.autoOfferta;
call db_prova.autoOfferta("SLVMHL98T07A123X", 1, 155);
call db_prova.nuova_offerta("SLVMHL98T07A123X", 1, 155, null);