CREATE PROCEDURE db_prova.getLastOffer (IN id VARCHAR(25), OUT lastOffer FLOAT)
SELECT Valore INTO lastOffer FROM db_prova.offerte WHERE offerte.Oggetto = id and Insert_time = (SELECT DISTINCT MAX(Insert_time) FROM db_prova.offerte WHERE offerte.Oggetto = id);

call db_prova.getLastOffer(4, @lastOffer);
select @lastOffer;