######## CREAO DATABASE ##########

DROP DATABASE IF EXISTS db_prova;
CREATE DATABASE db_prova CHARACTER SET utf8 COLLATE utf8_general_ci;
SET GLOBAL lc_time_names = 'it_CH';



## UTENTI

CREATE TABLE db_prova.utenti (
  CF_Utente CHAR(16) PRIMARY KEY, 
  Nome VARCHAR(15) NOT NULL, 
  Cognome VARCHAR(15) NOT NULL, 
  Data_nascita DATE NOT NULL,
  Città_nascita VARCHAR(15) NOT NULL, 
  Indirizzo_consegna VARCHAR(45) NOT NULL, 
  Città VARCHAR(10) NOT NULL, 
  numero_carta VARCHAR(22) NOT NULL, 				# non tutte hanno lo stesso numero, min 13 max 16 
  data_scadenza VARCHAR(7) NOT NULL,        # YYYY/MM
  Nome_intestatario VARCHAR(15) NOT NULL, 
  Cognome_intestatario VARCHAR(15) NOT NULL, 
  CVV VARCHAR(4) NOT NULL, 							# anche questo dipende dal tipo di carta
  Password VARCHAR(50) NOT NULL,
  username VARCHAR(25) NOT NULL UNIQUE, 
  ruolo INT NOT NULL DEFAULT 0
  );

## OFFERTE

CREATE TABLE db_prova.offerte(		
  CF_Utente CHAR(16), 
  Insert_time DATETIME DEFAULT current_timestamp(),					
  Valore DECIMAL(15,2) NOT NULL, 
  Max_val_controfferta DECIMAL(15,2) NULL, 
  Oggetto VARCHAR(25) NOT NULL,
  PRIMARY KEY (CF_Utente, Insert_time));


CREATE TABLE db_prova.aggiudicati(
  Oggetto VARCHAR(25),
  Utente CHAR(16) NOT NULL, 
  Prezzo_vendita DECIMAL(15,2) NOT NULL,
  PRIMARY KEY (Oggetto)
  );


## CATEGORIE 


CREATE TABLE db_prova.categoria(
  Nome_Categoria varchar(25), 
  Livello ENUM("1","2","3"),
  PRIMARY KEY (Nome_Categoria)
);


CREATE TABLE db_prova.catIndex(
  Categoria varchar(25) NOT NULL,
  SubCategoria varchar(25) NOT NULL,
  PRIMARY KEY (Categoria,SubCategoria)
  );

## OGGETTI

CREATE TABLE db_prova.tipo_oggetto(
  Nome_Categoria VARCHAR(25), 
  Nome_Oggetto VARCHAR(25), 
  Dimensioni VARCHAR(25) NOT NULL,
  Descrizione_oggetto TEXT NOT NULL,
  PRIMARY KEY (Nome_Categoria, Nome_Oggetto)
);


CREATE TABLE db_prova.oggetto(
  Id_oggetto varchar(25), 
  Colore VARCHAR(15),
  Prezzo_base VARCHAR(15) NOT NULL, 
  Condizione ENUM("Nuovo", "Come nuovo", "Buone condizioni", "Usurato", "Non funzionante") NOT NULL, 
  Data_termine DATETIME NOT NULL, 
  Prezzo_attuale VARCHAR(15) NOT NULL, 
  Tipo VARCHAR(25),
  Categoria VARCHAR(25),
  PRIMARY KEY (id_oggetto));



ALTER TABLE db_prova.offerte ADD CONSTRAINT offerte_FK_1 FOREIGN KEY (CF_Utente) REFERENCES db_prova.utenti(CF_Utente) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE db_prova.offerte ADD CONSTRAINT offerte_FK_2 FOREIGN KEY (Oggetto) REFERENCES db_prova.oggetto(Id_oggetto) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE db_prova.tipo_oggetto ADD CONSTRAINT tipo_FK FOREIGN KEY (Nome_Categoria) REFERENCES db_prova.categoria(Nome_Categoria) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE db_prova.oggetto ADD CONSTRAINT oggetto_FK FOREIGN KEY (categoria, tipo) REFERENCES db_prova.tipo_oggetto(Nome_Categoria, Nome_Oggetto) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE db_prova.aggiudicati ADD CONSTRAINT aggiudicati_FK_1 FOREIGN KEY (Oggetto) REFERENCES db_prova.oggetto(Id_oggetto) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE db_prova.aggiudicati ADD CONSTRAINT aggiudicati_FK_2 FOREIGN KEY (Utente) REFERENCES db_prova.utenti(CF_Utente) ON UPDATE CASCADE;
ALTER TABLE db_prova.catIndex ADD CONSTRAINT catIndex_FK FOREIGN KEY (Categoria) REFERENCES db_prova.categoria(Nome_Categoria) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE db_prova.catIndex ADD CONSTRAINT catIndex_FK_2 FOREIGN KEY (SubCategoria) REFERENCES db_prova.categoria(Nome_Categoria) ON DELETE CASCADE ON UPDATE CASCADE;


CREATE PROCEDURE db_prova.inserisci_utente(IN CF_Utente CHAR(16), IN Nome VARCHAR(15), 
	IN Cognome VARCHAR(15), IN Data_nascita	DATE, IN Città_nascita VARCHAR(15), IN Indirizzo_consegna VARCHAR(45), IN Città VARCHAR(10), IN numero_carta VARCHAR(22), 
	IN data_scadenza VARCHAR(7), IN Nome_intestatario VARCHAR(15), IN Cognome_intestatario VARCHAR(15), IN CVV VARCHAR(4), IN Password VARCHAR(15), IN username VARCHAR(25))
    
    INSERT INTO db_prova.utenti VALUES(CF_Utente, Nome, Cognome, Data_nascita, Città_nascita, Indirizzo_consegna,
     Città, numero_carta, data_scadenza, Nome_intestatario, Cognome_intestatario, CVV, md5(Password), username);



CREATE PROCEDURE db_prova.inserisci_categoria(IN Nome_categoria VARCHAR (25), IN Livello INT)
	INSERT INTO db_prova.categoria VALUES(Nome_categoria, Livello);


CREATE PROCEDURE db_prova.collega_categorie (IN Nome_categoria VARCHAR(25), IN Nome_sub_categoria VARCHAR(25))
	INSERT INTO db_prova.catIndex VALUES (Nome_categoria, Nome_sub_categoria);



CREATE PROCEDURE db_prova.inserisci_Tipo (IN Nome_categoria VARCHAR(25), IN Nome_Oggetto VARCHAR(25), IN Dimensioni VARCHAR(25), IN Descrizione TEXT)
	INSERT INTO db_prova.tipo_oggetto VALUES (Nome_categoria, Nome_Oggetto, Dimensioni, Descrizione);

# trigger categoria è livello 3 


CREATE PROCEDURE db_prova.visualizza_cat_1()
	SELECT Nome_Categoria
    FROM db_prova.categoria
    WHERE Livello = "1";


CREATE PROCEDURE db_prova.visualizza_cat_2()

	SELECT catIndex.Categoria, catIndex.SubCategoria
	FROM db_prova.categoria JOIN db_prova.catIndex ON (SubCategoria = Nome_Categoria)
	WHERE catIndex.Categoria IN (SELECT Nome_Categoria
								FROM db_prova.categoria
								WHERE Livello = "1")
                                
	 AND catIndex.SubCategoria IN (SELECT Nome_Categoria 
									  FROM db_prova.categoria
									  WHERE Livello = "2") ;

## procedura visualizza oggetti in cat 3 (input nome cat)

CREATE PROCEDURE db_prova.visualizza_cat_3()

	SELECT CC.Categoria as C1, CC.SubCategoria as C2, CCC.SubCategoria as C3
FROM db_prova.catIndex as CC JOIN db_prova.catIndex as CCC 
	 ON (CC.SubCategoria = CCC.Categoria)
WHERE CC.Categoria IN (SELECT Nome_Categoria
			 FROM db_prova.categoria
			 WHERE Livello = "1" )  and CC.SubCategoria IN (SELECT Nome_Categoria 
															FROM db_prova.categoria
															WHERE Livello = "2")  and CCC.SubCategoria IN (SELECT Nome_Categoria 
																										   FROM db_prova.categoria
																								         	WHERE Livello = "3") ;


CREATE PROCEDURE db_prova.inserisci_oggetto(IN id VARCHAR(25), IN colore VARCHAR(15), IN prezzo DECIMAL(15,2), IN condizione VARCHAR(30), 
	IN Data_termine DATETIME, IN tipo VARCHAR(25), IN Categoria VARCHAR(25))
	
	INSERT INTO db_prova.oggetti VALUES (id, colore, prezzo, condizione, Data_termine, prezzo, tipo, Categoria);


CREATE PROCEDURE db_prova.visualizza_aste_aperte ()
	SELECT Id_oggetto as ID, Tipo as Nome, Colore, Condizione, Prezzo_base as "Prezzo Iniziale", Prezzo_attuale as "Prezzo Attuale", TIME_FORMAT(SEC_TO_TIME(TIMESTAMPDIFF(SECOND,"2020-02-18 15:00:00", "2020-02-19 16:00:00")), "%T") as "Tempo rimanente"
	FROM db_prova.oggetto 
	WHERE Data_termine >= NOW();
    
DELIMITER $$

CREATE TRIGGER db_prova.check_valid_dataNascita BEFORE INSERT ON db_prova.utenti
	FOR EACH ROW
	
    BEGIN
		IF (NEW.Data_nascita > CURDATE()) THEN
			SIGNAL SQLSTATE '02000' SET MESSAGE_TEXT = 'Attenzione data di nascita non valida';  
            
            #SET NEW.Data_nascita = curdate();
		END IF;
        
	END $$


CREATE TRIGGER db_prova.check_valid_dataScadenza BEFORE INSERT ON db_prova.utenti
	FOR EACH ROW

    BEGIN

		DECLARE anno VARCHAR(4);
        DECLARE mese VARCHAR(2);
        SET anno := substring(New.data_scadenza,1, 4);
        SET mese := substring(New.data_scadenza,6, 7);
        
        IF (anno < YEAR(CURDATE()) or (anno = YEAR(CURDATE()) and mese < MONTH(CURDATE()))) THEN
			SIGNAL SQLSTATE '02000' SET MESSAGE_TEXT = 'Attenzione data di scadenza carta non valida';
        
        END IF;
        
	
    END $$

    CREATE TRIGGER db_prova.level BEFORE INSERT ON db_prova.tipo_oggetto
	FOR EACH ROW 
	BEGIN
		IF (SELECT EXISTS (SELECT *
			   FROM db_prova.categoria
			   WHERE Livello != "3" and Nome_Categoria = NEW.Nome_Categoria))
		THEN
        SIGNAL SQLSTATE '02000' SET MESSAGE_TEXT = 'Attenzione categoria non di livello 3';
		
        END IF;
	
    END $$
    

    