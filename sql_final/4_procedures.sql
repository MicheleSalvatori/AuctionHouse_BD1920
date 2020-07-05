-- Procedura autoOfferta
-- --------------------
DELIMITER $$
CREATE PROCEDURE auction_house.autoOfferta(IN CF VARCHAR(16), IN id VARCHAR(25), IN valore FLOAT)
BEGIN
	DECLARE result BOOLEAN DEFAULT FALSE;
    DECLARE cfMax VARCHAR(16);
    DECLARE lastCF VARCHAR(16);
    DECLARE maxAutoOffer FLOAT;
    DECLARE newOffer FLOAT;
    SET lastCF = CF;
    SET newOffer = valore;
    SELECT auction_house.checkAutoOfferta(CF, id, valore) INTO result;

    loop_label: LOOP
        IF (result) THEN
			call auction_house.getMaxCF(lastCF, id, newOffer, cfMax);
            SET newOffer = newOffer + 0.50;
			call auction_house.getMAXVALUE(cfMax, id, maxAutoOffer);
			call auction_house.nuova_offerta(cfMax, id, newOffer, maxAutoOffer, TRUE);
            SET lastCF = cfMax;
			SELECT auction_house.checkAutoOfferta(lastCF, id, newOffer) INTO result;
			ITERATE loop_label;
        ELSE LEAVE loop_label;
        END IF;
        END LOOP;
END$$

DELIMITER ;

-- --------------------
-- FUNCTION checkAutoOfferta
-- -----------------------
DELIMITER $$
CREATE FUNCTION auction_house.checkAutoOfferta(CF VARCHAR(16), id VARCHAR(25),  valore FLOAT) RETURNS tinyint(1)
BEGIN
	IF EXISTS (SELECT * FROM auction_house.Offerta WHERE CF_Utente != CF and Id_oggetto = id and Max_val_controfferta > valore)
	THEN RETURN TRUE;
    ELSE RETURN FALSE;
    END IF;
END$$

DELIMITER ;


-- -----------------------------------------------------
-- procedure collega_categorie
-- -----------------------------------------------------

DELIMITER $$
CREATE PROCEDURE auction_house.collega_categorie (IN Nome_categoria VARCHAR(25), IN Nome_sub_categoria VARCHAR(25))
BEGIN
    DECLARE temp_1, temp_2 INT;

    SELECT COUNT(*) FROM auction_house.catIndex WHERE catIndex.SuperCat = Nome_categoria and catIndex.SubCat = Nome_sub_categoria INTO temp_1;

    if temp_1 = 0 then
    INSERT INTO auction_house.catIndex VALUES (Nome_categoria, Nome_sub_categoria);
    end if;
END$$

DELIMITER ;


-- -----------------------------------------------------
-- procedure getCF
-- -----------------------------------------------------

DELIMITER $$
CREATE PROCEDURE auction_house.getCF (IN usr VARCHAR(25), OUT cf VARCHAR(16))
SELECT CF_Utente INTO cf FROM auction_house.Utente WHERE Utente.username = usr$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure getMAXVALUE
-- -----------------------------------------------------

DELIMITER $$
CREATE PROCEDURE auction_house.getMAXVALUE(IN CF VARCHAR(16), IN id VARCHAR(25), OUT controfferta FLOAT)
SELECT Max_val_controfferta INTO controfferta FROM auction_house.Offerta WHERE CF_Utente = CF and Id_oggetto = id and Insert_time = (Select distinct MAX(Insert_time) from auction_house.Offerta where CF_Utente = CF and Id_oggetto = id and Max_val_controfferta is not null)$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure getMaxCF
-- -----------------------------------------------------

DELIMITER $$
CREATE PROCEDURE auction_house.getMaxCF(CF VARCHAR(16), id VARCHAR(25),  valore FLOAT, OUT CFMAX VARCHAR(16))
BEGIN
	SELECT CF_Utente INTO CFMAX FROM auction_house.Offerta WHERE Insert_time = (SELECT DISTINCT MAX(Insert_time) FROM auction_house.Offerta WHERE offerte.Id_oggetto = id and CF_Utente != CF);
END$$

DELIMITER ;


-- -----------------------------------------------------
-- procedure getWinner
-- -----------------------------------------------------

DELIMITER $$
CREATE PROCEDURE auction_house.getWinner(IN id VARCHAR(25), OUT cf VARCHAR(16), OUT prezzoVendita FLOAT)
SELECT Valore, CF_Utente INTO prezzoVendita, cf FROM auction_house.Offerta
WHERE Offerta.Id_oggetto = id and Insert_time = (SELECT DISTINCT MAX(Insert_time) FROM auction_house.Offerta WHERE Offerta.Id_oggetto = id)$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure inserisci_Tipo
-- -----------------------------------------------------

DELIMITER $$
CREATE PROCEDURE auction_house.inserisci_Tipo (IN Nome_categoria VARCHAR(25), IN Nome_Oggetto VARCHAR(25), IN Descrizione VARCHAR(255))
BEGIN
		IF (SELECT NOT EXISTS (SELECT *
			   FROM auction_house.Categoria
			   WHERE Livello = "3" and Categoria.Nome_Categoria = Nome_Categoria))
		THEN
        SIGNAL SQLSTATE '02000' SET MESSAGE_TEXT = 'Attenzione categoria non di livello 3 non esistente';
		ELSE INSERT INTO auction_house.Tipo_oggetto VALUES (Nome_categoria, Nome_Oggetto, Descrizione);
        END IF;
END$$

DELIMITER ;


-- -----------------------------------------------------
-- procedure inserisci_categoria
-- -----------------------------------------------------

DELIMITER $$
CREATE PROCEDURE auction_house.inserisci_categoria (IN Nome_cat_1 VARCHAR(25), IN Nome_cat_2 VARCHAR(25), IN Nome_cat_3 VARCHAR(25))
BEGIN
	DECLARE temp_1 INT;
    DECLARE temp_2 INT;
    DECLARE temp_3 INT;

    SELECT COUNT(*)
    FROM auction_house.Categoria
    WHERE Categoria.Nome_Categoria = Nome_cat_1 and Categoria.Livello = 1
    INTO temp_1;

    SELECT COUNT(*)
    FROM auction_house.Categoria
    WHERE Categoria.Nome_Categoria = Nome_cat_2 and Categoria.Livello = 2
    INTO temp_2;

    SELECT COUNT(*)
    FROM auction_house.Categoria
    WHERE Categoria.Nome_Categoria = Nome_cat_3 and Categoria.Livello = 3
    INTO temp_3;


    IF temp_1 = 0 then INSERT INTO auction_house.Categoria VALUES  (Nome_cat_1, 1);
    END IF;
    IF temp_2 = 0 then INSERT INTO auction_house.Categoria VALUES (Nome_cat_2, 2);
    END IF;
    IF temp_3 = 0 then INSERT INTO auction_house.Categoria VALUES (Nome_cat_3, 3);
	END IF;

    CALL auction_house.collega_categorie(Nome_cat_1, Nome_cat_2);
    CALL auction_house.collega_categorie(Nome_cat_2, Nome_cat_3);

END$$

DELIMITER ;


-- -----------------------------------------------------
-- procedure inserisci_utente
-- -----------------------------------------------------

DELIMITER $$
CREATE PROCEDURE auction_house.inserisci_utente (IN CF_Utente CHAR(16), IN Nome VARCHAR(15),
	IN Cognome VARCHAR(15), IN Data_nascita	DATE, IN Città_nascita VARCHAR(15), IN Indirizzo_consegna VARCHAR(45), IN Città VARCHAR(10), IN numero_carta VARCHAR(22),
	IN data_scadenza VARCHAR(7), IN Nome_intestatario VARCHAR(15), IN Cognome_intestatario VARCHAR(15), IN CVV VARCHAR(4), IN Password VARCHAR(50), IN username VARCHAR(25))
INSERT INTO auction_house.Utente VALUES(CF_Utente, Nome, Cognome, Data_nascita, Città_nascita, Indirizzo_consegna,
     Città, numero_carta, data_scadenza, Nome_intestatario, Cognome_intestatario, CVV, md5(Password), username, DEFAULT)$$

DELIMITER ;


-- -----------------------------------------------------
-- procedure listAggiudicati
-- -----------------------------------------------------

DELIMITER $$
CREATE PROCEDURE auction_house.listAggiudicati(IN cfUtente VARCHAR(16))
SELECT ID_O AS "ID", CAST(Prezzo_vendita AS CHAR) AS "Saldo" FROM auction_house.Aggiudicato WHERE CF_A = cfUtente$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure listInteressati
-- -----------------------------------------------------

DELIMITER $$
CREATE PROCEDURE auction_house.listInteressati(IN cfUtente VARCHAR(16))
SELECT Id_oggetto AS "ID", Tipo AS "Oggetto" from auction_house.Offerta JOIN auction_house.Oggetto WHERE Offerta.Id_oggetto = Oggetto.ID
AND Id_oggetto IN (SELECT ID from auction_house.Oggetto Where Data_termine >= NOW())
AND CF_Utente = cfUtente
GROUP BY Id_oggetto, Tipo$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure login
-- -----------------------------------------------------

DELIMITER $$
CREATE PROCEDURE auction_house.login(IN var_username varchar(45), in var_pass varchar(45), out var_role LONG)
BEGIN
	DECLARE temp_role LONG;

    SELECT ruolo from auction_house.Utente
		WHERE Utente.username = var_username
		and Utente.Password = md5(var_pass)
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
CREATE PROCEDURE auction_house.nuova_offerta(IN CF VARCHAR(16), IN id VARCHAR(25),IN val_offerta VARCHAR(15), IN autoOfferta FLOAT, IN automatic BOOLEAN)
this_proc:BEGIN
DECLARE cfMax VARCHAR(16);
DECLARE lastOffer FLOAT;

-- Controllo se l'id esiste
	IF NOT EXISTS (SELECT * from auction_house.Oggetto WHERE Oggetto.ID = id and Oggetto.Data_termine > NOW())
		THEN SIGNAL SQLSTATE '02000' SET MESSAGE_TEXT = "Oggetto non in asta";
	END IF;
-- Controllo granularità offerte
	IF ( (MOD(val_offerta, 0.50))>0)
    THEN SIGNAL SQLSTATE '02000' SET MESSAGE_TEXT = "La granularita\' di incremento delle offerte e\' di multipli di 50 centesimi di euro";
    END IF;
-- Controllo se non ci sono ancora offerte sull'oggetto
	IF NOT EXISTS (SELECT * FROM auction_house.Offerta WHERE Offerta.Id_oggetto = id) THEN
		IF (val_offerta > (SELECT Prezzo_base FROM auction_house.Oggetto WHERE ID = id)) THEN
    INSERT INTO  auction_house.Offerta VALUES(CF, NOW(6), val_offerta, autoOfferta, upper(id), automatic);
    LEAVE this_proc;
		ELSE SIGNAL SQLSTATE '02000' SET MESSAGE_TEXT = "Devi inserire un\'offerta maggiore";
		END IF;
  END IF;

-- controllo se è stato l'ultimo a mettere l'offerta
	CALL auction_house.getLastCF(id, cfMax);
    IF (cfMax != CF and cfMax is not null) then
		CALL auction_house.getLastOffer(id, lastOffer);
        -- controllo se il valore dell'offerta è maggiore del valore attuale dell'oggetto
        IF (lastOffer >= val_offerta) THEN SIGNAL SQLSTATE '02000' SET MESSAGE_TEXT = "Devi inserire un'offerta maggiore";
		END IF;
        IF (autoOfferta <= val_offerta and !automatic) THEN SIGNAL SQLSTATE '02000' SET MESSAGE_TEXT = "Se vuoi inserire una controfferta automatica, essa deve essere maggiore dell\'offerta attuale";
		END IF;
        INSERT INTO  auction_house.Offerta VALUES(CF, NOW(6), val_offerta, autoOfferta, upper(id), automatic);
    ELSE SIGNAL SQLSTATE '02000' SET MESSAGE_TEXT = "La tua offerta e\' gia\' la piu\' alta";
	END IF;

END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure nuovo_admin
-- -----------------------------------------------------

DELIMITER $$
CREATE PROCEDURE auction_house.nuovo_admin(IN usr VARCHAR(255))
BEGIN
		DECLARE temp INT;
		SELECT ruolo FROM auction_house.Utente WHERE Utente.username = usr INTO temp;
		IF temp = 0 THEN UPDATE auction_house.Utente SET ruolo = 1 WHERE Utente.username = usr;
		ELSEIF temp is NULL THEN SIGNAL SQLSTATE '02000' SET message_text = "Nessun utente compatibile trovato";
        ELSEIF temp = 1 THEN SIGNAL SQLSTATE '02000' SET message_text = "L'utente selezionato e\' gia\' un amministratore";
		END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure reportID
-- -----------------------------------------------------

DELIMITER $$
CREATE PROCEDURE auction_house.reportID(IN id VARCHAR(25))
BEGIN
	IF (SELECT NOT EXISTS (SELECT ID FROM auction_house.Oggetto WHERE ID = id))
    THEN SIGNAL SQLSTATE '02000' SET MESSAGE_TEXT = "Oggetto non presente nel database";
    END IF;

	SELECT CF_Utente AS "Utente", DATE_FORMAT(Insert_time, "%Y-%m-%d %H:%i:%s") AS "Data inserimento",
	CAST(Valore AS CHAR)AS "Valore offerta",(SELECT IF(automatic, "Si", "No")) AS "Automatica"
	FROM auction_house.Offerta WHERE Offerta.Id_oggetto = id
	ORDER BY Offerta.Insert_time DESC;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure visualizza_auction_house_aperte
-- -----------------------------------------------------

DELIMITER $$
CREATE PROCEDURE auction_house.visualizza_aste_aperte()
BEGIN
SELECT ID, Tipo as Nome, Colore, Dimensioni, Condizione, CAST(Prezzo_base AS CHAR)as "Prezzo Iniziale",
IFNULL(CAST((SELECT Valore from auction_house.Offerta Where Id_oggetto = ID and Valore = (SELECT DISTINCT MAX(Valore) FROM auction_house.Offerta WHERE Id_oggetto = ID)) AS CHAR), "Null") as "Prezzo Attuale",
TIME_FORMAT(SEC_TO_TIME(TIMESTAMPDIFF(SECOND,NOW(), Data_termine)), "%T") as "Tempo rimanente",
CAST((SELECT COUNT(*) FROM auction_house.Offerta WHERE Offerta.Id_oggetto = ID) AS CHAR) AS "N.Offerte"

	FROM auction_house.Oggetto
	WHERE Data_termine >= NOW();
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure visualizza_cat_3
-- -----------------------------------------------------

DELIMITER $$
CREATE PROCEDURE auction_house.visualizza_cat_3()
SELECT CC.SuperCat as C1, CC.SubCat as C2, CCC.SubCat as C3
FROM auction_house.catIndex as CC JOIN auction_house.catIndex as CCC
	 ON (CC.SubCat = CCC.SuperCat)
WHERE CC.SuperCat IN (SELECT Nome_Categoria
			 FROM auction_house.Categoria
			 WHERE Livello = "1" )  and CC.SubCat IN (SELECT Nome_Categoria
															FROM auction_house.Categoria
															WHERE Livello = "2")  and CCC.SubCat IN (SELECT Nome_Categoria
																										   FROM auction_house.Categoria
																								         	WHERE Livello = "3")$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure visualizza_oggetti
-- -----------------------------------------------------

DELIMITER $$
CREATE PROCEDURE auction_house.visualizza_oggetti()
SELECT Nome_oggetto as "Oggetto",  Descrizione_oggetto as "Descrizione" FROM auction_house.Tipo_oggetto$$

DELIMITER ;
-- -----------------------------------------------------
-- procedure inserisci_oggetto
-- -----------------------------------------------------
DELIMITER $$
CREATE PROCEDURE auction_house.inserisci_oggetto(IN id VARCHAR(25), IN colore VARCHAR(25), IN dimensioni VARCHAR(50), IN prezzo FLOAT, IN condizione INT, IN tipo VARCHAR(25), IN scadenza VARCHAR(9))
BEGIN
	DECLARE categoria VARCHAR(25);
    DECLARE finale_scadenza DATETIME;
    IF (condizione <1 OR condizione>5) THEN SIGNAL SQLSTATE '02000' SET MESSAGE_TEXT = "Condizione non accettabile";
    ELSE
    SELECT Nome_C FROM auction_house.Tipo_oggetto WHERE Nome_Oggetto = tipo INTO categoria;
    SET finale_scadenza = addtime(NOW(), time_format(scadenza, "%T"));
	INSERT INTO auction_house.Oggetto VALUES (upper(id), colore, dimensioni, prezzo, condizione, finale_scadenza, upper(tipo), categoria);
	END IF;
END $$
DELIMITER ;

-- -----------------------------------------------------
-- procedure startEvent
-- -----------------------------------------------------
DELIMITER $$
CREATE PROCEDURE auction_house.startEvent ()
BEGIN
	SET GLOBAL event_scheduler = ON;
END $$
DELIMITER ;


-- -----------------------------------------------------
-- procedure getLastCF
-- -----------------------------------------------------
DELIMITER $$
CREATE PROCEDURE auction_house.getLastCF(IN id VARCHAR(25), OUT lastCF VARCHAR(16))
SELECT CF_Utente INTO lastCF from auction_house.Offerta WHERE Id_oggetto = id and Valore = (SELECT DISTINCT MAX(Valore) FROM auction_house.Offerta WHERE Id_oggetto = id)$$

DELIMITER ;


-- -----------------------------------------------------
-- procedure getLastOffer
-- -----------------------------------------------------
DELIMITER $$
CREATE PROCEDURE auction_house.getLastOffer(IN id VARCHAR(25), OUT lastOffer FLOAT)
SELECT Valore INTO lastOffer FROM auction_house.Offerta WHERE Offerta.Id_oggetto = id and Insert_time = (SELECT DISTINCT MAX(Insert_time) FROM auction_house.Offerta WHERE Offerta.Id_oggetto = id)$$
DELIMITER ;
