DELIMITER $$
CREATE PROCEDURE db_prova.getMaxCF(CF VARCHAR(16), id VARCHAR(25),  valore FLOAT, OUT CFMAX VARCHAR(16))
BEGIN 
	SELECT CF_Utente INTO CFMAX FROM db_prova.offerte WHERE Insert_time = (SELECT DISTINCT MAX(Insert_time) FROM db_prova.offerte WHERE offerte.Oggetto = id and CF_Utente != CF);
END $$
DELIMITER ;

drop procedure db_prova.getMaxCF;
call db_prova.getMaxCF("SLVMHL98T07A123M", 1, 157.5, @cf);
SELECT @cf;
select * from db_prova.offerte;

-- SELECT MICROSECOND(SELECT Insert_time FROM db_prova.offerte WHERE Valore = 157.5)
(SELECT DISTINCT MAX(Valore) FROM db_prova.offerte WHERE CF_Utente != "SLVMHL98T07A123M" and Oggetto = 1 and Max_val_controfferta > 157.5);


ALTER TABLE db_prova.offerte MODIFY Insert_time DATETIME(6);
select * from db_prova.offerte;