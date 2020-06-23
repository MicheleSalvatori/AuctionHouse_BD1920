DELIMITER $$
CREATE PROCEDURE db_prova.visualizza_aste_aperte()
BEGIN 
SELECT Id_oggetto as ID, Tipo as Nome, Colore, Condizione, Prezzo_base as "Prezzo Iniziale", 
(SELECT Valore from db_prova.offerte Where Oggetto = Id_oggetto and Valore = (SELECT DISTINCT MAX(Valore) FROM db_prova.offerte WHERE Oggetto = Id_oggetto)) as "Prezzo Attuale",
TIME_FORMAT(SEC_TO_TIME(TIMESTAMPDIFF(SECOND,NOW(), Data_termine)), "%T") as "Tempo rimanente",
(SELECT COUNT(*) FROM db_prova.offerte WHERE offerte.Oggetto = ID) AS "N.Offerte"

	FROM db_prova.oggetto 
	WHERE Data_termine >= NOW();
END $$
DELIMITER ;
