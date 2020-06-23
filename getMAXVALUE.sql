CREATE PROCEDURE db_prova.getMAXVALUE (IN CF VARCHAR(16), IN id VARCHAR(25), OUT controfferta FLOAT)
SELECT Max_val_controfferta INTO controfferta FROM db_prova.offerte WHERE CF_Utente = CF and Oggetto = id and Insert_time = (Select distinct MAX(Insert_time) from db_prova.offerte where CF_Utente = CF and Oggetto = id and Max_val_controfferta is not null); 

drop procedure db_prova.getMAXVALUE;
call db_prova.getMAXVALUE("SLVMHL98T07A123M", 1, @controfferta);
select @controfferta;