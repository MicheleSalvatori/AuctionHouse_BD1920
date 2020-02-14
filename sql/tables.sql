######## CREAO DATABASE ##########
CREATE DATABASE auction_house CHARACTER SET utf8 COLLATE utf8_general_ci;


# Tables


CREATE TABLE auction_house.utenti (
  CF_Utente CHAR(16) PRIMARY KEY, 
  Nome VARCHAR(15) NOT NULL, 
  Cognome VARCHAR(15) NOT NULL, 
  Data_nascita DATE NOT NULL,
  Città_nascita VARCHAR(15) NOT NULL, 
  Indirizzo_consegna VARCHAR(45), NOT NULL, 
  CAP VARCHAR(10) NOT NULL, 
  numero_carta VARCHAR(22) NOT NULL, 				# non tutte hanno lo stesso numero, min 13 max 16 
  data_scadenza DATE NOT NULL, 
  Nome_intestatario VARCHAR(15) NOT NULL, 
  Cognome_intestatario VARCHAR(15) NOT NULL, 
  CVV VARCHAR(4) NOT NULL, 							# anche questo dipende dal tipo di carta
  Password VARCHAR(15) NOT NULL
  PRIMARY KEY (CF_Utente));

## aggiungere username?? 

CREATE TABLE auction_house.offerte(		
CF_Utente CHAR(16), 
datatime_stamp DATETIME, 
valore VARCHAR(15) NOT NULL, 
max_controfferta VARCHAR(15) NULL, 
PRIMARY KEY (CF_Utente, datatime_stamp), 
FOREIGN KEY (CF_Utente) REFERENCES auction_house.utenti(CF_Utente)) ON DELETE CASCADE ON UPDATE CASCADE;
# manca id_oggetto



## categoria 


CREATE TABLE auction_house.categoria(
Nome_Categoria varchar(25) PRIMARY KEY, 
livello ENUM("1","2","3"));




