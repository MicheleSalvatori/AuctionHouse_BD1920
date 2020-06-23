CREATE PROCEDURE db_prova.getLastCF (IN id VARCHAR(25), OUT lastCF VARCHAR(16))
SELECT CF_Utente INTO lastCF from db_prova.offerte WHERE Oggetto = id and Valore = (SELECT DISTINCT MAX(Valore) FROM db_prova.offerte WHERE oggetto = id);

call getLastCF(1, @cf);
select @cf;
select * from db_prova.offerte;
drop procedure db_prova.getLastCF;