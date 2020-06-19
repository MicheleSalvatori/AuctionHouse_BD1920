call db_prova.visualizza_aste_aperte();
drop procedure visualizza_aste_aperte;

DELIMITER $$
CREATE PROCEDURE `visualizza_aste_aperte`()
SELECT Id_oggetto as ID, Tipo as Nome, Colore, Condizione, Prezzo_base as "Prezzo Iniziale", Prezzo_attuale as "Prezzo Attuale", TIME_FORMAT(SEC_TO_TIME(TIMESTAMPDIFF(SECOND,NOW(), Data_termine)), "%T") as "Tempo rimanente"
							,(SELECT COUNT(*) FROM db_prova.offerte
							WHERE offerte.Oggetto = ID) AS "#Offerte"
	FROM db_prova.oggetto 
	WHERE Data_termine >= NOW();
    $$
    
    
    
    

SELECT Id_oggetto as ID, (SELECT COUNT(*) FROM db_prova.offerte
							WHERE offerte.Oggetto = ID) AS "#Offerte"
	FROM db_prova.oggetto 
	WHERE Data_termine >= NOW();
    
