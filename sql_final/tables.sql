######## CREAO DATABASE ##########

DROP DATABASE IF EXISTS aste;
CREATE DATABASE aste CHARACTER SET utf8 COLLATE utf8_general_ci;
SET GLOBAL lc_time_names = 'it_CH';



## UTENTI

CREATE TABLE aste.utenti (
  CF_Utente CHAR(16) PRIMARY KEY,
  Nome VARCHAR(15) NOT NULL,
  Cognome VARCHAR(15) NOT NULL,
  Data_nascita DATE NOT NULL,
  Città_nascita VARCHAR(15) NOT NULL,
  Indirizzo_consegna VARCHAR(45) NOT NULL,
  Città VARCHAR(15) NOT NULL,
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

CREATE TABLE aste.offerte(
  CF_Utente CHAR(16),
  Insert_time DATETIME(6) NOT NULL,
  Valore FLOAT NOT NULL,
  Max_val_controfferta FLOAT NULL DEFAULT NULL,
  Oggetto VARCHAR(25) NOT NULL,
  automatic TINYINT(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (CF_Utente, Insert_time));


CREATE TABLE aste.aggiudicati(
  Oggetto VARCHAR(25),
  Utente CHAR(16) NOT NULL,
  Prezzo_vendita FLOAT NOT NULL,
  PRIMARY KEY (Oggetto)
  );


## CATEGORIE


CREATE TABLE aste.categoria(
  Nome_Categoria varchar(25),
  Livello ENUM("1","2","3"),
  PRIMARY KEY (Nome_Categoria)
);


CREATE TABLE aste.catIndex(
  Categoria varchar(25) NOT NULL,
  SubCategoria varchar(25) NOT NULL,
  PRIMARY KEY (Categoria,SubCategoria)
  );

## OGGETTI

CREATE TABLE aste.tipo_oggetto(
  Nome_Categoria VARCHAR(25),
  Nome_Oggetto VARCHAR(25),
  Dimensioni VARCHAR(25) NOT NULL,
  Descrizione_oggetto VARCHAR(255) NOT NULL,
  PRIMARY KEY (Nome_Categoria, Nome_Oggetto)
);


CREATE TABLE aste.oggetto(
  Id_oggetto VARCHAR(25),
  Colore VARCHAR(15),
  Prezzo_base FLOAT NOT NULL,
  Condizione ENUM("Nuovo", "Come nuovo", "Buone condizioni", "Usurato", "Non funzionante") NOT NULL,
  Data_termine DATETIME NOT NULL,
  Tipo VARCHAR(25),
  Categoria VARCHAR(25),
  PRIMARY KEY (id_oggetto));



ALTER TABLE aste.offerte ADD CONSTRAINT offerte_FK_1 FOREIGN KEY (CF_Utente) REFERENCES aste.utenti(CF_Utente) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE aste.offerte ADD CONSTRAINT offerte_FK_2 FOREIGN KEY (Oggetto) REFERENCES aste.oggetto(Id_oggetto) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE aste.tipo_oggetto ADD CONSTRAINT tipo_FK FOREIGN KEY (Nome_Categoria) REFERENCES aste.categoria(Nome_Categoria) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE aste.oggetto ADD CONSTRAINT oggetto_FK FOREIGN KEY (Categoria, Tipo) REFERENCES aste.tipo_oggetto(Nome_Categoria, Nome_Oggetto) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE aste.aggiudicati ADD CONSTRAINT aggiudicati_FK_1 FOREIGN KEY (Oggetto) REFERENCES aste.oggetto(Id_oggetto) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE aste.aggiudicati ADD CONSTRAINT aggiudicati_FK_2 FOREIGN KEY (Utente) REFERENCES aste.utenti(CF_Utente) ON UPDATE CASCADE;
ALTER TABLE aste.catIndex ADD CONSTRAINT catIndex_FK FOREIGN KEY (Categoria) REFERENCES aste.categoria(Nome_Categoria) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE aste.catIndex ADD CONSTRAINT catIndex_FK_2 FOREIGN KEY (SubCategoria) REFERENCES aste.categoria(Nome_Categoria) ON DELETE CASCADE ON UPDATE CASCADE;
