-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
-- -----------------------------------------------------
-- Schema db_prova
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema db_prova
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `db_prova` DEFAULT CHARACTER SET utf8 ;
USE `db_prova` ;

-- -----------------------------------------------------
-- Table `db_prova`.`categoria`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `db_prova`.`categoria` (
  `Nome_Categoria` VARCHAR(25) NOT NULL,
  `Livello` ENUM('1', '2', '3') NOT NULL,
  PRIMARY KEY (`Nome_Categoria`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `db_prova`.`tipo_oggetto`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `db_prova`.`tipo_oggetto` (
  `Nome_Categoria` VARCHAR(25) NOT NULL,
  `Nome_Oggetto` VARCHAR(25) NOT NULL,
  `Dimensioni` VARCHAR(25) NOT NULL,
  `Descrizione_oggetto` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`Nome_Categoria`, `Nome_Oggetto`),
  CONSTRAINT `tipo_FK`
    FOREIGN KEY (`Nome_Categoria`)
    REFERENCES `db_prova`.`categoria` (`Nome_Categoria`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `db_prova`.`oggetto`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `db_prova`.`oggetto` (
  `Id_oggetto` VARCHAR(25) NOT NULL,
  `Colore` VARCHAR(15) NULL DEFAULT NULL,
  `Prezzo_base` FLOAT NOT NULL,
  `Condizione` ENUM('Nuovo', 'Come nuovo', 'Buone condizioni', 'Usurato', 'Non funzionante') NOT NULL,
  `Data_termine` DATETIME NOT NULL,
  `Tipo` VARCHAR(25) NULL DEFAULT NULL,
  `Categoria` VARCHAR(25) NULL DEFAULT NULL,
  PRIMARY KEY (`Id_oggetto`),
  INDEX `oggetto_FK` (`Categoria` ASC, `Tipo` ASC),
  CONSTRAINT `oggetto_FK`
    FOREIGN KEY (`Categoria` , `Tipo`)
    REFERENCES `db_prova`.`tipo_oggetto` (`Nome_Categoria` , `Nome_Oggetto`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `db_prova`.`utenti`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `db_prova`.`utenti` (
  `CF_Utente` CHAR(16) NOT NULL,
  `Nome` VARCHAR(15) NOT NULL,
  `Cognome` VARCHAR(15) NOT NULL,
  `Data_nascita` DATE NOT NULL,
  `Città_nascita` VARCHAR(15) NOT NULL,
  `Indirizzo_consegna` VARCHAR(45) NOT NULL,
  `Città` VARCHAR(10) NOT NULL,
  `numero_carta` VARCHAR(22) NOT NULL,
  `data_scadenza` VARCHAR(7) NOT NULL,
  `Nome_intestatario` VARCHAR(15) NOT NULL,
  `Cognome_intestatario` VARCHAR(15) NOT NULL,
  `CVV` VARCHAR(4) NOT NULL,
  `Password` VARCHAR(50) NOT NULL,
  `username` VARCHAR(25) NOT NULL,
  `ruolo` INT(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`CF_Utente`),
  UNIQUE INDEX `username` (`username` ASC))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `db_prova`.`aggiudicati`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `db_prova`.`aggiudicati` (
  `Oggetto` VARCHAR(25) NOT NULL,
  `Utente` CHAR(16) NOT NULL,
  `Prezzo_vendita` FLOAT NOT NULL,
  PRIMARY KEY (`Oggetto`),
  INDEX `aggiudicati_FK_2` (`Utente` ASC),
  CONSTRAINT `aggiudicati_FK_1`
    FOREIGN KEY (`Oggetto`)
    REFERENCES `db_prova`.`oggetto` (`Id_oggetto`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `aggiudicati_FK_2`
    FOREIGN KEY (`Utente`)
    REFERENCES `db_prova`.`utenti` (`CF_Utente`)
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `db_prova`.`catIndex`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `db_prova`.`catIndex` (
  `Categoria` VARCHAR(25) NOT NULL,
  `SubCategoria` VARCHAR(25) NOT NULL,
  PRIMARY KEY (`Categoria`, `SubCategoria`),
  INDEX `catIndex_FK_2` (`SubCategoria` ASC),
  CONSTRAINT `catIndex_FK`
    FOREIGN KEY (`Categoria`)
    REFERENCES `db_prova`.`categoria` (`Nome_Categoria`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `catIndex_FK_2`
    FOREIGN KEY (`SubCategoria`)
    REFERENCES `db_prova`.`categoria` (`Nome_Categoria`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `db_prova`.`offerte`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `db_prova`.`offerte` (
  `CF_Utente` CHAR(16) NOT NULL,
  `Insert_time` DATETIME(6) NOT NULL,
  `Valore` FLOAT NOT NULL,
  `Max_val_controfferta` FLOAT NULL DEFAULT NULL,
  `Oggetto` VARCHAR(25) NOT NULL,
  `automatic` TINYINT(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`CF_Utente`, `Insert_time`),
  INDEX `offerte_FK_2` (`Oggetto` ASC),
  CONSTRAINT `offerte_FK_1`
    FOREIGN KEY (`CF_Utente`)
    REFERENCES `db_prova`.`utenti` (`CF_Utente`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `offerte_FK_2`
    FOREIGN KEY (`Oggetto`)
    REFERENCES `db_prova`.`oggetto` (`Id_oggetto`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `db_prova`.`provaEvento`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `db_prova`.`provaEvento` (
  `id` VARCHAR(15) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;

USE `db_prova` ;

-- -----------------------------------------------------
-- procedure autoOfferta
-- -----------------------------------------------------

DELIMITER $$
USE `db_prova`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `autoOfferta`(IN CF VARCHAR(16), IN id VARCHAR(25), IN valore FLOAT)
BEGIN
	DECLARE result BOOLEAN DEFAULT FALSE;
    DECLARE cfMax VARCHAR(16);
    DECLARE lastCF VARCHAR(16);
    DECLARE maxAutoOffer FLOAT;
    DECLARE newOffer FLOAT;
    SET lastCF = CF;
    SET newOffer = valore;
    SELECT db_prova.checkAutoOfferta(CF, id, valore) INTO result;

    loop_label: LOOP
        IF (result) THEN
			call db_prova.getMaxCF(lastCF, id, newOffer, cfMax);
            SET newOffer = newOffer + 0.50;
			call db_prova.getMAXVALUE(cfMax, id, maxAutoOffer);
			call db_prova.nuova_offerta(cfMax, id, newOffer, maxAutoOffer, TRUE);
            SET lastCF = cfMax;
			SELECT db_prova.checkAutoOfferta(lastCF, id, newOffer) INTO result;
			ITERATE loop_label;
        ELSE LEAVE loop_label;
        END IF;
        END LOOP;
END$$

DELIMITER ;

DELIMITER $$
USE `db_prova`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `checkAutoOfferta`(CF VARCHAR(16), id VARCHAR(25),  valore FLOAT) RETURNS tinyint(1)
BEGIN
	IF EXISTS (SELECT * FROM db_prova.offerte WHERE CF_Utente != CF and Oggetto = id and Max_val_controfferta > valore)
	THEN RETURN TRUE;
    ELSE RETURN FALSE;
    END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure collega_categorie
-- -----------------------------------------------------

DELIMITER $$
USE `db_prova`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `collega_categorie`(IN Nome_categoria VARCHAR(25), IN Nome_sub_categoria VARCHAR(25))
BEGIN
    DECLARE temp_1, temp_2 INT;

    SELECT COUNT(*) FROM db_prova.catIndex WHERE catIndex.Categoria = Nome_categoria and catIndex.SubCategoria = Nome_sub_categoria INTO temp_1;

    if temp_1 = 0 then
    INSERT INTO db_prova.catIndex VALUES (Nome_categoria, Nome_sub_categoria);
    end if;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure getCF
-- -----------------------------------------------------

DELIMITER $$
USE `db_prova`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `getCF`(IN usr VARCHAR(25), OUT cf VARCHAR(16))
SELECT CF_Utente INTO cf FROM db_prova.utenti WHERE utenti.username = usr$$

DELIMITER ;

-- -----------------------------------------------------
-- function getCFMAX
-- -----------------------------------------------------

DELIMITER $$
USE `db_prova`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `getCFMAX`(CF VARCHAR(16), id VARCHAR(25),  valore FLOAT) RETURNS varchar(16) CHARSET utf8
BEGIN
DECLARE cfAutoOfferta VARCHAR(16);
DECLARE maxAutoOfferta FLOAT;
	IF EXISTS (SELECT * FROM db_prova.offerte WHERE CF_Utente != CF and Oggetto = id and Max_val_controfferta > valore and Insert_time = (Select distinct MAX(Insert_time) from db_prova.max_controfferta where CF_Utente != CF))
	THEN SELECT CF_Utente INTO cfAutoOfferta FROM db_prova.offerte WHERE CF_Utente != CF and Oggetto = id and Max_val_controfferta > valore and Insert_time = (Select distinct MAX(Insert_time) from db_prova.max_controfferta where CF_Utente != CF);
    RETURN cfAutoOfferta;
    END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure getLastCF
-- -----------------------------------------------------

DELIMITER $$
USE `db_prova`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `getLastCF`(IN id VARCHAR(25), OUT lastCF VARCHAR(16))
SELECT CF_Utente INTO lastCF from db_prova.offerte WHERE Oggetto = id and Valore = (SELECT DISTINCT MAX(Valore) FROM db_prova.offerte WHERE oggetto = id)$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure getLastOffer
-- -----------------------------------------------------

DELIMITER $$
USE `db_prova`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `getLastOffer`(IN id VARCHAR(25), OUT lastOffer FLOAT)
SELECT Valore INTO lastOffer FROM db_prova.offerte WHERE offerte.Oggetto = id and Insert_time = (SELECT DISTINCT MAX(Insert_time) FROM db_prova.offerte WHERE offerte.Oggetto = id)$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure getMAXVALUE
-- -----------------------------------------------------

DELIMITER $$
USE `db_prova`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `getMAXVALUE`(IN CF VARCHAR(16), IN id VARCHAR(25), OUT controfferta FLOAT)
SELECT Max_val_controfferta INTO controfferta FROM db_prova.offerte WHERE CF_Utente = CF and Oggetto = id and Insert_time = (Select distinct MAX(Insert_time) from db_prova.offerte where CF_Utente = CF and Oggetto = id and Max_val_controfferta is not null)$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure getMaxCF
-- -----------------------------------------------------

DELIMITER $$
USE `db_prova`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `getMaxCF`(CF VARCHAR(16), id VARCHAR(25),  valore FLOAT, OUT CFMAX VARCHAR(16))
BEGIN
	SELECT CF_Utente INTO CFMAX FROM db_prova.offerte WHERE Insert_time = (SELECT DISTINCT MAX(Insert_time) FROM db_prova.offerte WHERE offerte.Oggetto = id and CF_Utente != CF);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure getWinner
-- -----------------------------------------------------

DELIMITER $$
USE `db_prova`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `getWinner`(IN id VARCHAR(25), OUT cf VARCHAR(16), OUT prezzoVendita FLOAT)
SELECT Valore, CF_Utente INTO prezzoVendita, cf FROM db_prova.offerte
WHERE offerte.Oggetto = id and Insert_time = (SELECT DISTINCT MAX(Insert_time) FROM db_prova.offerte WHERE offerte.Oggetto = id)$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure inserisci_Tipo
-- -----------------------------------------------------

DELIMITER $$
USE `db_prova`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `inserisci_Tipo`(IN Nome_categoria VARCHAR(25), IN Nome_Oggetto VARCHAR(25), IN Dimensioni VARCHAR(25), IN Descrizione VARCHAR(255))
BEGIN
		IF (SELECT NOT EXISTS (SELECT *
			   FROM db_prova.categoria
			   WHERE Livello = "3" and categoria.Nome_Categoria = Nome_Categoria))
		THEN
        SIGNAL SQLSTATE '02000' SET MESSAGE_TEXT = 'Attenzione categoria non di livello 3 non esistente';
		ELSE INSERT INTO db_prova.tipo_oggetto VALUES (Nome_categoria, Nome_Oggetto, Dimensioni, Descrizione);
        END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure inserisci_categoria
-- -----------------------------------------------------

DELIMITER $$
USE `db_prova`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `inserisci_categoria`(IN Nome_cat_1 VARCHAR(25), IN Nome_cat_2 VARCHAR(25), IN Nome_cat_3 VARCHAR(25))
BEGIN
	DECLARE temp_1 INT;
    DECLARE temp_2 INT;
    DECLARE temp_3 INT;

    SELECT COUNT(*)
    FROM db_prova.categoria
    WHERE categoria.Nome_Categoria = Nome_cat_1 and categoria.Livello = 1
    INTO temp_1;

    SELECT COUNT(*)
    FROM db_prova.categoria
    WHERE categoria.Nome_Categoria = Nome_cat_2 and categoria.Livello = 2
    INTO temp_2;

    SELECT COUNT(*)
    FROM db_prova.categoria
    WHERE categoria.Nome_Categoria = Nome_cat_3 and categoria.Livello = 3
    INTO temp_3;

    #select temp_1, temp_2, temp_3 AS '** DEBUG:';
    IF temp_1 = 0 then INSERT INTO db_prova.categoria VALUES  (Nome_cat_1, 1);
    END IF;
    IF temp_2 = 0 then INSERT INTO db_prova.categoria VALUES (Nome_cat_2, 2);
    END IF;
    IF temp_3 = 0 then INSERT INTO db_prova.categoria VALUES (Nome_cat_3, 3);
	END IF;

    CALL db_prova.collega_categorie(Nome_cat_1, Nome_cat_2);
    CALL db_prova.collega_categorie(Nome_cat_2, Nome_cat_3);

END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure inserisci_offerta
-- -----------------------------------------------------

DELIMITER $$
USE `db_prova`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `inserisci_offerta`(IN CF VARCHAR(16), IN val_offerta FLOAT, IN id VARCHAR(25), IN autoOfferta FLOAT)
BEGIN
	IF EXISTS (SELECT * FROM db_prova.aste_aperte WHERE aste_aperte.ID = id)
		THEN IF EXISTS (SELECT * FROM db_prova.aste_aperte WHERE val_offerta > aste_aperte.PREZZO and aste_aperte.ID = id)
			THEN IF (autoOfferta = 0) THEN INSERT INTO  db_prova.offerte VALUES(CF, NOW(), val_offerta, DEFAULT, id);
            ELSE
            INSERT INTO  db_prova.offerte VALUES(CF, NOW(), val_offerta, autoOfferta, id);
            END IF;
            UPDATE db_prova.oggetto SET oggetto.Prezzo_attuale = val_offerta WHERE oggetto.Id_oggetto = id;
		ELSE SIGNAL SQLSTATE '02000' SET MESSAGE_TEXT = "Prezzo basso";
		END IF;
	ELSE SIGNAL SQLSTATE '02000' SET MESSAGE_TEXT = "Oggetto non presente";
    END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure inserisci_offerta_2
-- -----------------------------------------------------

DELIMITER $$
USE `db_prova`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `inserisci_offerta_2`(IN CF VARCHAR(16), IN val_offerta VARCHAR(15), IN id VARCHAR(25), IN autoOfferta FLOAT)
BEGIN
DECLARE result BOOLEAN DEFAULT FALSE;
DECLARE cfMax VARCHAR(16);
DECLARE controfferta FLOAT;
-- controllo se è stato l'ultimo a mettere l'offerta
	IF EXISTS (SELECT * FROM db_prova.aste_aperte WHERE aste_aperte.ID = id)
		THEN IF EXISTS (SELECT * FROM db_prova.offerte WHERE val_offerta > Valore and Oggetto = id)
			THEN INSERT INTO  db_prova.offerte VALUES(CF, NOW(), val_offerta, autoOfferta, id);
            UPDATE db_prova.oggetto SET oggetto.Prezzo_attuale = val_offerta WHERE oggetto.Id_oggetto = id;
		ELSE SIGNAL SQLSTATE '02000' SET MESSAGE_TEXT = "Prezzo basso";
		END IF;
	ELSE SIGNAL SQLSTATE '02000' SET MESSAGE_TEXT = "Oggetto non presente";
    END IF;

    SELECT db_prova.checkAutoOfferta(CF, id, val_offerta) INTO result;

	loop_label: LOOP
        IF (result) THEN
			call getCFMAX(CF, id, val_offerta, cfMax);
            call getMAXVALUE(cfMax, id, controfferta);
            INSERT INTO  db_prova.offerte VALUES(cfMax, TIMESTAMPADD(SECOND, 1,NOW()), val_offerta+0.50, controfferta, id);
            UPDATE db_prova.oggetto SET oggetto.Prezzo_attuale = val_offerta+0.50 WHERE oggetto.Id_oggetto = id;
			SELECT db_prova.checkAutoOfferta(cfMax, id, val_offerta) INTO result;
            ITERATE loop_label;
		ELSE LEAVE loop_label;
        END IF;
        END LOOP;

END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure inserisci_utente
-- -----------------------------------------------------

DELIMITER $$
USE `db_prova`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `inserisci_utente`(IN CF_Utente CHAR(16), IN Nome VARCHAR(15),
	IN Cognome VARCHAR(15), IN Data_nascita	DATE, IN Città_nascita VARCHAR(15), IN Indirizzo_consegna VARCHAR(45), IN Città VARCHAR(10), IN numero_carta VARCHAR(22),
	IN data_scadenza VARCHAR(7), IN Nome_intestatario VARCHAR(15), IN Cognome_intestatario VARCHAR(15), IN CVV VARCHAR(4), IN Password VARCHAR(50), IN username VARCHAR(25))
INSERT INTO db_prova.utenti VALUES(CF_Utente, Nome, Cognome, Data_nascita, Città_nascita, Indirizzo_consegna,
     Città, numero_carta, data_scadenza, Nome_intestatario, Cognome_intestatario, CVV, md5(Password), username, DEFAULT)$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure listAggiudicati
-- -----------------------------------------------------

DELIMITER $$
USE `db_prova`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `listAggiudicati`(IN cfUtente VARCHAR(16))
SELECT Oggetto AS "ID", CAST(Prezzo_vendita AS CHAR) AS "Saldo" FROM db_prova.aggiudicati WHERE Utente = cfUtente$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure listInteressati
-- -----------------------------------------------------

DELIMITER $$
USE `db_prova`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `listInteressati`(IN cfUtente VARCHAR(16))
SELECT Oggetto AS "ID", Tipo AS "Oggetto" from db_prova.offerte JOIN db_prova.oggetto WHERE offerte.Oggetto = oggetto.Id_oggetto
AND Oggetto IN (SELECT Id_oggetto from db_prova.oggetto Where Data_termine >= NOW())
AND CF_Utente = cfUtente
GROUP BY Oggetto, Tipo$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure login
-- -----------------------------------------------------

DELIMITER $$
USE `db_prova`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `login`(IN var_username varchar(45), in var_pass varchar(45), out var_role LONG)
BEGIN
	DECLARE temp_role LONG;

    SELECT ruolo from db_prova.utenti
		WHERE utenti.username = var_username
		and utenti.password = md5(var_pass)
        into temp_role;

		if temp_role = 1 then
		set var_role = 1;
		elseif temp_role = 0 then
		set var_role = 0;
		else
		set var_role = 99;
		end if;

END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure nuova_offerta
-- -----------------------------------------------------

DELIMITER $$
USE `db_prova`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `nuova_offerta`(IN CF VARCHAR(16), IN id VARCHAR(25),IN val_offerta VARCHAR(15), IN autoOfferta FLOAT, IN automatic BOOLEAN)
this_proc:BEGIN
DECLARE cfMax VARCHAR(16);
DECLARE lastOffer FLOAT;

-- Controllo se l'id esiste
	IF NOT EXISTS (SELECT * from db_prova.oggetto WHERE oggetto.Id_oggetto = id and oggetto.Data_termine > NOW())
		THEN SIGNAL SQLSTATE '02000' SET MESSAGE_TEXT = "Oggetto non in asta";
	END IF;
-- Controllo granularità offerte
	IF ( (MOD(val_offerta, 0.50))>0)
    THEN SIGNAL SQLSTATE '02000' SET MESSAGE_TEXT = "La granularita\' di incremento delle offerte e\' di multipli di 50 centesimi di euro";
    END IF;
-- Controllo se non ci sono ancora offerte sull'oggetto
	IF NOT EXISTS (SELECT * FROM db_prova.offerte WHERE offerte.Oggetto = id) THEN
    INSERT INTO  db_prova.offerte VALUES(CF, NOW(6), val_offerta, autoOfferta, id, automatic);
    LEAVE this_proc;
    END IF;

-- controllo se è stato l'ultimo a mettere l'offerta
	CALL db_prova.getLastCF(id, cfMax);
    IF (cfMax != CF and cfMax is not null) then
		CALL db_prova.getLastOffer(id, lastOffer);
        -- controllo se il valore dell'offerta è maggiore del valore attuale dell'oggetto
        IF (lastOffer >= val_offerta) THEN SIGNAL SQLSTATE '02000' SET MESSAGE_TEXT = "Devi inserire un'offerta maggiore";
		END IF;
        IF (autoOfferta <= val_offerta and !automatic) THEN SIGNAL SQLSTATE '02000' SET MESSAGE_TEXT = "Se vuoi inserire una controfferta automatica, essa deve essere maggiore dell\'offerta attuale";
		END IF;
        INSERT INTO  db_prova.offerte VALUES(CF, NOW(6), val_offerta, autoOfferta, id, automatic);
    ELSE SIGNAL SQLSTATE '02000' SET MESSAGE_TEXT = "La tua offerta e\' gia\' la piu\' alta";
	END IF;

END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure nuovo_admin
-- -----------------------------------------------------

DELIMITER $$
USE `db_prova`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `nuovo_admin`(IN usr VARCHAR(255))
BEGIN
		DECLARE temp INT;
		SELECT ruolo FROM db_prova.utenti WHERE utenti.username = usr INTO temp;
		IF temp = 0 THEN UPDATE db_prova.utenti SET ruolo = 1 WHERE utenti.username = usr;
		ELSEIF temp is NULL THEN SIGNAL SQLSTATE '45002' SET message_text = "Nessun utente compatibile trovato";
        ELSEIF temp = 1 THEN SIGNAL SQLSTATE '45002' SET message_text = "L'utente selezionato e' gia' un amministratore";
		END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure reportID
-- -----------------------------------------------------

DELIMITER $$
USE `db_prova`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `reportID`(IN id VARCHAR(25))
BEGIN
	IF (SELECT NOT EXISTS (SELECT Id_oggetto FROM db_prova.oggetto WHERE Id_oggetto = id))
    THEN SIGNAL SQLSTATE '02000' SET MESSAGE_TEXT = "Oggetto non presente nel database";
    END IF;

	SELECT CF_Utente AS "Utente", DATE_FORMAT(Insert_time, "%Y-%m-%d %H:%i:%s") AS "Data inserimento",
	CAST(Valore AS CHAR)AS "Valore offerta",(SELECT IF(automatic, "Si", "No")) AS "Automatica"
	FROM db_prova.offerte WHERE offerte.Oggetto = id
	ORDER BY offerte.Insert_time DESC;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure visualizza_aste_aperte
-- -----------------------------------------------------

DELIMITER $$
USE `db_prova`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `visualizza_aste_aperte`()
BEGIN
SELECT Id_oggetto as ID, Tipo as Nome, Colore, Condizione, CAST(Prezzo_base AS CHAR)as "Prezzo Iniziale",
CAST((SELECT Valore from db_prova.offerte Where Oggetto = Id_oggetto and Valore = (SELECT DISTINCT MAX(Valore) FROM db_prova.offerte WHERE Oggetto = Id_oggetto)) AS CHAR) as "Prezzo Attuale",
TIME_FORMAT(SEC_TO_TIME(TIMESTAMPDIFF(SECOND,NOW(), Data_termine)), "%T") as "Tempo rimanente",
CAST((SELECT COUNT(*) FROM db_prova.offerte WHERE offerte.Oggetto = ID) AS CHAR) AS "N.Offerte"

	FROM db_prova.oggetto
	WHERE Data_termine >= NOW();
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure visualizza_cat_1
-- -----------------------------------------------------

DELIMITER $$
USE `db_prova`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `visualizza_cat_1`()
SELECT Nome_Categoria
    FROM db_prova.categoria
    WHERE Livello = "1"$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure visualizza_cat_2
-- -----------------------------------------------------

DELIMITER $$
USE `db_prova`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `visualizza_cat_2`()
SELECT catIndex.Categoria, catIndex.SubCategoria
	FROM db_prova.categoria JOIN db_prova.catIndex ON (SubCategoria = Nome_Categoria)
	WHERE catIndex.Categoria IN (SELECT Nome_Categoria
								FROM db_prova.categoria
								WHERE Livello = "1")

	 AND catIndex.SubCategoria IN (SELECT Nome_Categoria
									  FROM db_prova.categoria
									  WHERE Livello = "2")$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure visualizza_cat_3
-- -----------------------------------------------------

DELIMITER $$
USE `db_prova`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `visualizza_cat_3`()
SELECT CC.Categoria as C1, CC.SubCategoria as C2, CCC.SubCategoria as C3
FROM db_prova.catIndex as CC JOIN db_prova.catIndex as CCC
	 ON (CC.SubCategoria = CCC.Categoria)
WHERE CC.Categoria IN (SELECT Nome_Categoria
			 FROM db_prova.categoria
			 WHERE Livello = "1" )  and CC.SubCategoria IN (SELECT Nome_Categoria
															FROM db_prova.categoria
															WHERE Livello = "2")  and CCC.SubCategoria IN (SELECT Nome_Categoria
																										   FROM db_prova.categoria
																								         	WHERE Livello = "3")$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure visualizza_oggetti
-- -----------------------------------------------------

DELIMITER $$
USE `db_prova`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `visualizza_oggetti`()
SELECT Nome_oggetto as "Oggetto", Dimensioni, Descrizione_oggetto as "Descrizione" FROM db_prova.tipo_oggetto$$

DELIMITER ;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
USE `db_prova`;

DELIMITER $$
USE `db_prova`$$
CREATE
DEFINER=`root`@`localhost`
TRIGGER `db_prova`.`check_exist_tipo`
BEFORE INSERT ON `db_prova`.`oggetto`
FOR EACH ROW
BEGIN
		DECLARE temp_int INT;
        SELECT count(*) FROM db_prova.tipo_oggetto WHERE Nome_Oggetto = NEW.Tipo INTO temp_int;
        IF (temp_int = 0) THEN
        SIGNAL SQLSTATE '02000' SET MESSAGE_TEXT = "Tipo oggetto non presente nel database";
        END IF;
	END$$

USE `db_prova`$$
CREATE
DEFINER=`root`@`localhost`
TRIGGER `db_prova`.`check_scadenza_asta`
BEFORE INSERT ON `db_prova`.`oggetto`
FOR EACH ROW
BEGIN
    DECLARE h INT;

		SELECT TIMESTAMPDIFF(SECOND,NOW(), NEW.Data_termine) INTO h;
        IF (h < 24*60*60 OR h>24*7*60*60)
        THEN SIGNAL SQLSTATE '02000' SET MESSAGE_TEXT = "Attenzione: l'asta deve durare almeno 1 GIORNO e massimo 7 GIORNI";
        END IF;
	END$$

USE `db_prova`$$
CREATE
DEFINER=`root`@`localhost`
TRIGGER `db_prova`.`check_valid_dataNascita`
BEFORE INSERT ON `db_prova`.`utenti`
FOR EACH ROW
BEGIN
		IF (NEW.Data_nascita > CURDATE()) THEN
			SIGNAL SQLSTATE '02000' SET MESSAGE_TEXT = 'Attenzione data di nascita non valida';

            #SET NEW.Data_nascita = curdate();
		END IF;

	END$$

USE `db_prova`$$
CREATE
DEFINER=`root`@`localhost`
TRIGGER `db_prova`.`check_valid_dataScadenza`
BEFORE INSERT ON `db_prova`.`utenti`
FOR EACH ROW
BEGIN

		DECLARE anno VARCHAR(4);
        DECLARE mese VARCHAR(2);
        SET anno := substring(New.data_scadenza,1, 4);
        SET mese := substring(New.data_scadenza,6, 7);

        IF (anno < YEAR(CURDATE()) or (anno = YEAR(CURDATE()) and mese < MONTH(CURDATE()))) THEN
			SIGNAL SQLSTATE '02000' SET MESSAGE_TEXT = 'Attenzione data di scadenza carta non valida';

        END IF;


    END$$


DELIMITER ;
