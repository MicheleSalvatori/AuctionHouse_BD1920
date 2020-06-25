CREATE PROCEDURE db_prova.getCF (IN usr VARCHAR(25), OUT cf VARCHAR(16))
SELECT CF_Utente INTO cf FROM db_prova.utenti WHERE utenti.username = usr;

call db_prova.getCF("michele.salvatori", @cf);
select @cf;
select * from offerte where Oggetto = 5 ORDER BY Insert_time DESC;

delete from db_prova.offerte WHere Oggetto = 5 and Valore > 28;