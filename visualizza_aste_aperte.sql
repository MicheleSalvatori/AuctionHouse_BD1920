CREATE DEFINER=`root`@`localhost` PROCEDURE `visualizza_aste_aperte`()
BEGIN 
SELECT Id_oggetto as ID, Tipo as Nome, Colore, Condizione, CAST(Prezzo_base AS CHAR)as "Prezzo Iniziale", 
CAST((SELECT Valore from db_prova.offerte Where Oggetto = Id_oggetto and Valore = (SELECT DISTINCT MAX(Valore) FROM db_prova.offerte WHERE Oggetto = Id_oggetto)) AS CHAR) as "Prezzo Attuale",
TIME_FORMAT(SEC_TO_TIME(TIMESTAMPDIFF(SECOND,NOW(), Data_termine)), "%T") as "Tempo rimanente",
CAST((SELECT COUNT(*) FROM db_prova.offerte WHERE offerte.Oggetto = ID) AS CHAR) AS "N.Offerte"

	FROM db_prova.oggetto 
	WHERE Data_termine >= NOW();
END