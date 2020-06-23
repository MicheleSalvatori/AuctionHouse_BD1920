CREATE VIEW db_prova.lastOffer AS
SELECT Valore, Oggetto as O1 from db_prova.offerte WHERE Valore = (Select distinct MAX(Valore) from db_prova.offerte WHERE Oggetto = O1); 

DROP VIEW db_prova.lastOffer;
select * from db_prova.lastOffer;
