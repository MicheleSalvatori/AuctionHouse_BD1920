CREATE PROCEDURE db_prova.getWinner (IN id VARCHAR(25), OUT cf VARCHAR(16), OUT prezzoVendita FLOAT)
SELECT Valore, CF_Utente INTO prezzoVendita, cf FROM db_prova.offerte 
WHERE offerte.Oggetto = id and Insert_time = (SELECT DISTINCT MAX(Insert_time) FROM db_prova.offerte WHERE offerte.Oggetto = id);



select * from offerte where Oggetto = 1;
drop procedure db_prova.getWinner;
call db_prova.getWinner(1, @cf, @valore);
select @cf, @valore;
select @v;

SELECT * FROM db_prova.offerte WHERE Oggetto = 1 ORDER BY Valore DESC LIMIT 1;