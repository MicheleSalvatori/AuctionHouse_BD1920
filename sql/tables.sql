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
  username VARCHAR(50) NOT NULL UNIQUE,
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
  Descrizione_oggetto VARCHAR(255) NOT NULL,
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

-- TODO cambiare soldi in float


ALTER TABLE db_prova.offerte ADD CONSTRAINT offerte_FK_1 FOREIGN KEY (CF_Utente) REFERENCES db_prova.utenti(CF_Utente) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE db_prova.offerte ADD CONSTRAINT offerte_FK_2 FOREIGN KEY (Oggetto) REFERENCES db_prova.oggetto(Id_oggetto) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE db_prova.tipo_oggetto ADD CONSTRAINT tipo_FK FOREIGN KEY (Nome_Categoria) REFERENCES db_prova.categoria(Nome_Categoria) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE db_prova.oggetto ADD CONSTRAINT oggetto_FK FOREIGN KEY (categoria, tipo) REFERENCES db_prova.tipo_oggetto(Nome_Categoria, Nome_Oggetto) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE db_prova.aggiudicati ADD CONSTRAINT aggiudicati_FK_1 FOREIGN KEY (Oggetto) REFERENCES db_prova.oggetto(Id_oggetto) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE db_prova.aggiudicati ADD CONSTRAINT aggiudicati_FK_2 FOREIGN KEY (Utente) REFERENCES db_prova.utenti(CF_Utente) ON UPDATE CASCADE;
ALTER TABLE db_prova.catIndex ADD CONSTRAINT catIndex_FK FOREIGN KEY (Categoria) REFERENCES db_prova.categoria(Nome_Categoria) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE db_prova.catIndex ADD CONSTRAINT catIndex_FK_2 FOREIGN KEY (SubCategoria) REFERENCES db_prova.categoria(Nome_Categoria) ON DELETE CASCADE ON UPDATE CASCADE;
