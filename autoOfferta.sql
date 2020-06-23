DELIMITER $$
CREATE PROCEDURE autoOfferta (IN CF VARCHAR(16), IN id VARCHAR(25), IN valore FLOAT)
BEGIN
	DECLARE result BOOLEAN DEFAULT FALSE;
    DECLARE cfMax VARCHAR(16);
    DECLARE lastCF VARCHAR(16);
    DECLARE maxAutoOffer FLOAT;
    DECLARE newOffer FLOAT;
    SET lastCF = CF;
    SET newOffer = valore;
    SELECT db_prova.checkAutoOfferta(CF, id, valore) INTO result;
	
    loop_label: LOOP
        IF (result) THEN
			call db_prova.getMaxCF(lastCF, id, newOffer, cfMax);
            SET newOffer = newOffer + 0.50;
			call db_prova.getMAXVALUE(cfMax, id, maxAutoOffer);
			call db_prova.nuova_offerta(cfMax, id, newOffer, maxAutoOffer, TRUE);
            SET lastCF = cfMax;
			SELECT db_prova.checkAutoOfferta(lastCF, id, newOffer) INTO result;
			ITERATE loop_label;
        ELSE LEAVE loop_label;
        END IF;
        END LOOP;
END $$
DELIMITER ;

select * from offerte;
drop procedure db_prova.autoOfferta;
call db_prova.autoOfferta("SLVMHL98T07A123X", 1, 155);
call db_prova.nuova_offerta("SLVMHL98T07A123X", 3, 155, null, FALSE);
delete from db_prova.offerte where Valore >150 and CF_Utente ="SLVMHL98T07A123X";
ALTER TABLE db_prova.offerte ADD COLUMN automatic BOOLEAN NOT NULL DEFAULT FALSE;
