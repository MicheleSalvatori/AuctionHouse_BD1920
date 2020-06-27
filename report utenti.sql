CREATE PROCEDURE db_prova.listAggiudicati (IN cfUtente VARCHAR(16))
SELECT Oggetto AS "ID", CAST(Prezzo_vendita AS CHAR) AS "Saldo" FROM db_prova.aggiudicati WHERE Utente = cfUtente;

CREATE PROCEDURE db_prova.listInteressati (IN cfUtente VARCHAR(16))
SELECT Oggetto AS "ID", Tipo AS "Oggetto" from db_prova.offerte JOIN db_prova.oggetto WHERE offerte.Oggetto = oggetto.Id_oggetto
AND Oggetto IN (SELECT Id_oggetto from db_prova.oggetto Where Data_termine >= NOW())
AND CF_Utente = cfUtente
GROUP BY Oggetto, Tipo;



select * from offerte;
call visualizza_aste_aperte();
drop procedure db_prova.listAggiudicati;
drop procedure db_prova.listInteressati;
call db_prova.listInteressati ("SLVMHL98T07A123X");
call db_prova.listAggiudicati ("SLVMHL98T07A123X");
