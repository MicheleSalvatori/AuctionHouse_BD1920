CREATE PROCEDURE auction_house.inserisci_utente(IN CF_Utente CHAR(16), IN Nome VARCHAR(15), 
	IN Cognome VARCHAR(15), IN Data_nascita	DATE, IN Città_nascita VARCHAR(15), IN Indirizzo_consegna VARCHAR(45), IN Città VARCHAR(10), IN numero_carta VARCHAR(22), 
	IN data_scadenza VARCHAR(7), IN Nome_intestatario VARCHAR(15), IN Cognome_intestatario VARCHAR(15), IN CVV VARCHAR(4), IN Password VARCHAR(15), IN username VARCHAR(25))
    
    INSERT INTO auction_house.utenti VALUES(CF_Utente, Nome, Cognome, Data_nascita, Città_nascita, Indirizzo_consegna,
     Città, numero_carta, data_scadenza, Nome_intestatario, Cognome_intestatario, CVV, Password, username);



CREATE PROCEDURE auction_house.inserisci_categoria(IN Nome_categoria VARCHAR (25), IN Livello INT)
	INSERT INTO auction_house.categoria VALUES(Nome_categoria, Livello);


CREATE PROCEDURE auction_house.collega_categorie (IN Nome_categoria VARCHAR(25), IN Nome_sub_categoria VARCHAR(25))
	INSERT INTO auction_house.catIndex VALUES (Nome_categoria, Nome_sub_categoria);



CREATE PROCEDURE auction_house.inserisci_Tipo (IN Nome_categoria VARCHAR(25), IN Nome_Oggetto VARCHAR(25), IN Dimensioni VARCHAR(25), IN Descrizione TEXT)
	INSERT INTO auction_house.tipo_oggetto (Nome_categoria, Nome_Oggetto, Dimensioni, Descrizione);

# trigger categoria è livello 3 


CREATE PROCEDURE auction_house.visualizza_cat_1()
	SELECT Nome_Categoria
    FROM auction_house.categoria
    WHERE Livello = "1";


CREATE PROCEDURE auction_house.visualizza_cat_2()

	SELECT catIndex.Categoria, catIndex.SubCategoria
	FROM auction_house.categoria JOIN auction_house.catIndex ON (SubCategoria = Nome_Categoria)
	WHERE catIndex.Categoria IN (SELECT Nome_Categoria
								FROM auction_house.categoria
								WHERE Livello = "1")
                                
	 AND catIndex.SubCategoria IN (SELECT Nome_Categoria 
									  FROM auction_house.categoria
									  WHERE Livello = "2") ;

## procedura visualizza oggetti in cat 3 (input nome cat)

CREATE PROCEDURE auction_house.visualizza_cat_3()

	SELECT CC.Categoria as C1, CC.SubCategoria as C2, CCC.SubCategoria as C3
FROM auction_house.catIndex as CC JOIN auction_house.catIndex as CCC 
	 ON (CC.SubCategoria = CCC.Categoria)
WHERE CC.Categoria IN (SELECT Nome_Categoria
			 FROM auction_house.categoria
			 WHERE Livello = "1" )  and CC.SubCategoria IN (SELECT Nome_Categoria 
															FROM auction_house.categoria
															WHERE Livello = "2")  and CCC.SubCategoria IN (SELECT Nome_Categoria 
																										   FROM auction_house.categoria
																								         	WHERE Livello = "3") ;


CREATE PROCEDURE auction_house.inserisci_oggetto(IN id VARCHAR(25), IN colore VARCHAR(15), IN prezzo DECIMAL(15,2), IN condizione VARCHAR(30), 
	IN Data_termine DATETIME, IN tipo VARCHAR(25), IN Categoria VARCHAR(25))
	
	INSERT INTO auction_house.oggetti VALUES (id, colore, prezzo, condizione, Data_termine, prezzo, tipo, Categoria);


CREATE PROCEDURE auction_house.visualizza_aste_aperte ()
	SELECT Id_oggetto as ID, Tipo as Nome, Colore, Condizione, Prezzo_base as "Prezzo Iniziale", Prezzo_attuale as "Prezzo Attuale", TIME_FORMAT(SEC_TO_TIME(TIMESTAMPDIFF(SECOND,"2020-02-18 15:00:00", "2020-02-19 16:00:00")), "%T") as "Tempo rimanente"
	FROM auction_house.oggetto 
	WHERE Data_termine >= NOW();