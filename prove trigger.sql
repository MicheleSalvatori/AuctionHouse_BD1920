
-- Restituisce tabella con date_scadenza valide
SELECT annoTable.anno, annoTable.CF_Utente, annoTable.mese
FROM (SELECT substring(utenti.data_scadenza,1, 4) as anno, substring(utenti.data_scadenza, 6,7) as mese, CF_Utente
	 FROM auction_house.utenti) as annoTable
WHERE anno > year(curdate()) or (anno = year(curdate()) and mese >= month(curdate()))
;
     
--      
-- SELECT substring(utenti.data_scadenza,1, 4) as anno
-- 	 FROM auction_house.utenti
-- 	 WHERE CF_Utente = "SLVMHL98T07A123M";
--      

SELECT DAY(CURDATE());



CREATE PROCEDURE auction_house.inserisci_categoria(IN Nome_categoria VARCHAR (25), IN Livello INT)
	INSERT INTO auction_house.categoria VALUES(Nome_categoria, Livello);
