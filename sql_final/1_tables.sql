######## CREAO DATABASE ##########

DROP DATABASE IF EXISTS auction_house;
CREATE DATABASE auction_house CHARACTER SET utf8 COLLATE utf8_general_ci;
SET GLOBAL lc_time_names = 'it_CH';



## UTENTI

CREATE TABLE auction_house.Utente (
  CF CHAR(16) PRIMARY KEY,
  Nome VARCHAR(15) NOT NULL,
  Cognome VARCHAR(15) NOT NULL,
  Data_nascita DATE NOT NULL,
  Città_nascita VARCHAR(50) NOT NULL,
  Indirizzo_consegna VARCHAR(45) NOT NULL,
  Città VARCHAR(50) NOT NULL,
  numero_carta VARCHAR(22) NOT NULL,
  data_scadenza VARCHAR(7) NOT NULL,
  Nome_intestatario VARCHAR(15) NOT NULL,
  Cognome_intestatario VARCHAR(15) NOT NULL,
  CVV VARCHAR(4) NOT NULL,
  Password VARCHAR(50) NOT NULL,
  username VARCHAR(50) NOT NULL UNIQUE,
  ruolo INT NOT NULL DEFAULT 0
  );

## OFFERTE

CREATE TABLE auction_house.Offerta(
  CF_Utente CHAR(16),
  Insert_time DATETIME(6) NOT NULL,
  Valore FLOAT NOT NULL,
  Max_val_controfferta FLOAT NULL DEFAULT NULL,
  Id_oggetto VARCHAR(25) NOT NULL,
  automatic TINYINT(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (CF_Utente, Insert_time));


CREATE TABLE auction_house.Aggiudicato(
  ID_O VARCHAR(25),
  CF_A CHAR(16) NOT NULL,
  Prezzo_vendita FLOAT NOT NULL,
  PRIMARY KEY (ID_O)
  );


## CATEGORIE


CREATE TABLE auction_house.Categoria(
  Nome_Categoria varchar(25),
  Livello ENUM("1","2","3"),
  PRIMARY KEY (Nome_Categoria)
);


CREATE TABLE auction_house.catIndex(
  SuperCat varchar(25) NOT NULL,
  SubCat varchar(25) NOT NULL,
  PRIMARY KEY (SuperCat,SubCat)
  );

## OGGETTI

CREATE TABLE auction_house.Tipo_oggetto(
  Nome_C VARCHAR(25),
  Nome_Oggetto VARCHAR(25),
  Descrizione_oggetto VARCHAR(255) NOT NULL,
  PRIMARY KEY (Nome_C, Nome_Oggetto)
);


CREATE TABLE auction_house.Oggetto(
  ID VARCHAR(25),
  Colore VARCHAR(15),
  Dimensioni VARCHAR(50) NOT NULL,
  Prezzo_base FLOAT NOT NULL,
  Condizione ENUM("Nuovo", "Come nuovo", "Buone condizioni", "Usurato", "Non funzionante") NOT NULL,
  Data_termine DATETIME NOT NULL,
  Tipo VARCHAR(25),
  Categoria_O VARCHAR(25),
  PRIMARY KEY (ID));



ALTER TABLE auction_house.Offerta ADD CONSTRAINT offerte_FK_1 FOREIGN KEY (CF_Utente) REFERENCES auction_house.Utente(CF) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE auction_house.Offerta ADD CONSTRAINT offerte_FK_2 FOREIGN KEY (Id_oggetto) REFERENCES auction_house.Oggetto(ID) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE auction_house.Tipo_oggetto ADD CONSTRAINT tipo_FK FOREIGN KEY (Nome_C) REFERENCES auction_house.Categoria(Nome_Categoria) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE auction_house.Oggetto ADD CONSTRAINT oggetto_FK FOREIGN KEY (Categoria_O, Tipo) REFERENCES auction_house.Tipo_oggetto(Nome_C, Nome_Oggetto) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE auction_house.Aggiudicato ADD CONSTRAINT aggiudicati_FK_1 FOREIGN KEY (ID_O) REFERENCES auction_house.Oggetto(ID) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE auction_house.Aggiudicato ADD CONSTRAINT aggiudicati_FK_2 FOREIGN KEY (CF_A) REFERENCES auction_house.Utente(CF) ON UPDATE CASCADE;
ALTER TABLE auction_house.catIndex ADD CONSTRAINT catIndex_FK FOREIGN KEY (SuperCat) REFERENCES auction_house.Categoria(Nome_Categoria) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE auction_house.catIndex ADD CONSTRAINT catIndex_FK_2 FOREIGN KEY (SubCat) REFERENCES auction_house.Categoria(Nome_Categoria) ON DELETE CASCADE ON UPDATE CASCADE;
