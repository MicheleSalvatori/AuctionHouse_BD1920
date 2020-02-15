######## CREAO DATABASE ##########
CREATE DATABASE auction_house CHARACTER SET utf8 COLLATE utf8_general_ci;



# Tables


CREATE TABLE auction_house.utenti (
  CF_Utente CHAR(16) PRIMARY KEY, 
  Nome VARCHAR(15) NOT NULL, 
  Cognome VARCHAR(15) NOT NULL, 
  Data_nascita DATE NOT NULL,
  Città_nascita VARCHAR(15) NOT NULL, 
  Indirizzo_consegna VARCHAR(45) NOT NULL, 
  CAP VARCHAR(10) NOT NULL, 
  numero_carta VARCHAR(22) NOT NULL, 				# non tutte hanno lo stesso numero, min 13 max 16 
  data_scadenza DATE NOT NULL, 
  Nome_intestatario VARCHAR(15) NOT NULL, 
  Cognome_intestatario VARCHAR(15) NOT NULL, 
  CVV VARCHAR(4) NOT NULL, 							# anche questo dipende dal tipo di carta
  Password VARCHAR(15) NOT NULL
  );

## aggiungere username?? 

CREATE TABLE auction_house.offerte(		
CF_Utente CHAR(16), 
datatime_stamp DATETIME, 						## provare type TIMESTAMP default current_timestamp()
valore VARCHAR(15) NOT NULL, 
max_controfferta VARCHAR(15) NULL, 
PRIMARY KEY (CF_Utente, datatime_stamp));
# manca id_oggetto



## categoria 


CREATE TABLE auction_house.categoria(
Nome_Categoria varchar(25) PRIMARY KEY, 
livello ENUM("1","2","3"));


#categoria superiore/inferiore

CREATE TABLE auction_house.catIndex(
  Categoria varchar(25) NOT NULL,
  SubCategoria varchar(25) NOT NULL,
  PRIMARY KEY (Categoria,SubCategoria),
  FOREIGN KEY (Categoria) REFERENCES auction_house.categoria (Nome_Categoria),
  FOREIGN KEY (SubCategoria) REFERENCES auction_house.categoria (Nome_Categoria));

CREATE TABLE tipo_oggetto(
Nome_Categoria VARCHAR(25), 
Nome_Oggetto VARCHAR(25), 
Dimensioni VARCHAR(25) NOT NULL,
Descrizione_oggetto TEXT NOT NULL,
PRIMARY KEY (Nome_Categoria, Nome_Oggetto));





ALTER TABLE auction_house.offerte ADD CONSTRAINT offerte_ibfk_1 FOREIGN KEY (CF_Utente) REFERENCES auction_house.utenti(CF_Utente) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE auction_house.tipo_oggetto ADD CONSTRAINT tipo_FK FOREIGN KEY (Nome_Categoria) REFERENCES auction_house.categoria(Nome_Categoria) ON DELETE CASCADE ON UPDATE CASCADE;

CREATE TABLE auction_house.oggetto(
id_oggetto varchar(25), 
colore VARCHAR(15),
prezzo_base DECIMAL(15,2) NOT NULL, 
condizione ENUM("Nuovo", "Come nuovo", "Buone condizioni", "Usurato", "Non funzionante") NOT NULL, 
data_termine DATETIME NOT NULL, 
prezzo_attuale DECIMAL(15,2) NOT NULL, 
tipo VARCHAR(25),
categoria VARCHAR(25),
PRIMARY KEY (id_oggetto));

ALTER TABLE auction_house.oggetto ADD CONSTRAINT oggetto_FK FOREIGN KEY (categoria, tipo) REFERENCES auction_house.tipo_oggetto(Nome_Categoria, Nome_Oggetto) ON DELETE CASCADE ON UPDATE CASCADE;
