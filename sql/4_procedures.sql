-- Procedura autoOfferta
-- --------------------
DELIMITER $$
CREATE PROCEDURE aste.autoOfferta(IN CF VARCHAR(16), IN id VARCHAR(25), IN valore FLOAT)
BEGIN
	DECLARE result BOOLEAN DEFAULT FALSE;
    DECLARE cfMax VARCHAR(16);
    DECLARE lastCF VARCHAR(16);
    DECLARE maxAutoOffer FLOAT;
    DECLARE newOffer FLOAT;
    SET lastCF = CF;
    SET newOffer = valore;
    SELECT aste.checkAutoOfferta(CF, id, valore) INTO result;

    loop_label: LOOP
        IF (result) THEN
			call aste.getMaxCF(lastCF, id, newOffer, cfMax);
            SET newOffer = newOffer + 0.50;
			call aste.getMAXVALUE(cfMax, id, maxAutoOffer);
			call aste.nuova_offerta(cfMax, id, newOffer, maxAutoOffer, TRUE);
            SET lastCF = cfMax;
			SELECT aste.checkAutoOfferta(lastCF, id, newOffer) INTO result;
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
CREATE FUNCTION aste.checkAutoOfferta(CF VARCHAR(16), id VARCHAR(25),  valore FLOAT) RETURNS tinyint(1)
BEGIN
	IF EXISTS (SELECT * FROM aste.offerte WHERE CF_Utente != CF and Oggetto = id and Max_val_controfferta > valore)
	THEN RETURN TRUE;
    ELSE RETURN FALSE;
    END IF;
END$$

DELIMITER ;


-- -----------------------------------------------------
-- procedure collega_categorie
-- -----------------------------------------------------

DELIMITER $$
CREATE PROCEDURE aste.collega_categorie (IN Nome_categoria VARCHAR(25), IN Nome_sub_categoria VARCHAR(25))
BEGIN
    DECLARE temp_1, temp_2 INT;

    SELECT COUNT(*) FROM aste.catIndex WHERE catIndex.Categoria = Nome_categoria and catIndex.SubCategoria = Nome_sub_categoria INTO temp_1;

    if temp_1 = 0 then
    INSERT INTO aste.catIndex VALUES (Nome_categoria, Nome_sub_categoria);
    end if;
END$$

DELIMITER ;


-- -----------------------------------------------------
-- procedure getCF
-- -----------------------------------------------------

DELIMITER $$
CREATE PROCEDURE aste.getCF (IN usr VARCHAR(25), OUT cf VARCHAR(16))
SELECT CF_Utente INTO cf FROM aste.utenti WHERE utenti.username = usr$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure getMAXVALUE
-- -----------------------------------------------------

DELIMITER $$
CREATE PROCEDURE aste.getMAXVALUE(IN CF VARCHAR(16), IN id VARCHAR(25), OUT controfferta FLOAT)
SELECT Max_val_controfferta INTO controfferta FROM aste.offerte WHERE CF_Utente = CF and Oggetto = id and Insert_time = (Select distinct MAX(Insert_time) from aste.offerte where CF_Utente = CF and Oggetto = id and Max_val_controfferta is not null)$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure getMaxCF
-- -----------------------------------------------------

DELIMITER $$
CREATE PROCEDURE aste.getMaxCF(CF VARCHAR(16), id VARCHAR(25),  valore FLOAT, OUT CFMAX VARCHAR(16))
BEGIN
	SELECT CF_Utente INTO CFMAX FROM aste.offerte WHERE Insert_time = (SELECT DISTINCT MAX(Insert_time) FROM aste.offerte WHERE offerte.Oggetto = id and CF_Utente != CF);
END$$

DELIMITER ;


-- -----------------------------------------------------
-- procedure getWinner
-- -----------------------------------------------------

DELIMITER $$
CREATE PROCEDURE aste.getWinner(IN id VARCHAR(25), OUT cf VARCHAR(16), OUT prezzoVendita FLOAT)
SELECT Valore, CF_Utente INTO prezzoVendita, cf FROM aste.offerte
WHERE offerte.Oggetto = id and Insert_time = (SELECT DISTINCT MAX(Insert_time) FROM aste.offerte WHERE offerte.Oggetto = id)$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure inserisci_Tipo
-- -----------------------------------------------------

DELIMITER $$
CREATE PROCEDURE aste.inserisci_Tipo (IN Nome_categoria VARCHAR(25), IN Nome_Oggetto VARCHAR(25), IN Descrizione VARCHAR(255))
BEGIN
		IF (SELECT NOT EXISTS (SELECT *
			   FROM aste.categoria
			   WHERE Livello = "3" and categoria.Nome_Categoria = Nome_Categoria))
		THEN
        SIGNAL SQLSTATE '02000' SET MESSAGE_TEXT = 'Attenzione categoria non di livello 3 non esistente';
		ELSE INSERT INTO aste.tipo_oggetto VALUES (Nome_categoria, Nome_Oggetto, Descrizione);
        END IF;
END$$

DELIMITER ;


-- -----------------------------------------------------
-- procedure inserisci_categoria
-- -----------------------------------------------------

DELIMITER $$
CREATE PROCEDURE aste.inserisci_categoria (IN Nome_cat_1 VARCHAR(25), IN Nome_cat_2 VARCHAR(25), IN Nome_cat_3 VARCHAR(25))
BEGIN
	DECLARE temp_1 INT;
    DECLARE temp_2 INT;
    DECLARE temp_3 INT;

    SELECT COUNT(*)
    FROM aste.categoria
    WHERE categoria.Nome_Categoria = Nome_cat_1 and categoria.Livello = 1
    INTO temp_1;

    SELECT COUNT(*)
    FROM aste.categoria
    WHERE categoria.Nome_Categoria = Nome_cat_2 and categoria.Livello = 2
    INTO temp_2;

    SELECT COUNT(*)
    FROM aste.categoria
    WHERE categoria.Nome_Categoria = Nome_cat_3 and categoria.Livello = 3
    INTO temp_3;

    #select temp_1, temp_2, temp_3 AS '** DEBUG:';
    IF temp_1 = 0 then INSERT INTO aste.categoria VALUES  (Nome_cat_1, 1);
    END IF;
    IF temp_2 = 0 then INSERT INTO aste.categoria VALUES (Nome_cat_2, 2);
    END IF;
    IF temp_3 = 0 then INSERT INTO aste.categoria VALUES (Nome_cat_3, 3);
	END IF;

    CALL aste.collega_categorie(Nome_cat_1, Nome_cat_2);
    CALL aste.collega_categorie(Nome_cat_2, Nome_cat_3);

END$$

DELIMITER ;


-- -----------------------------------------------------
-- procedure inserisci_utente
-- -----------------------------------------------------

DELIMITER $$
CREATE PROCEDURE aste.inserisci_utente (IN CF_Utente CHAR(16), IN Nome VARCHAR(15),
	IN Cognome VARCHAR(15), IN Data_nascita	DATE, IN Città_nascita VARCHAR(15), IN Indirizzo_consegna VARCHAR(45), IN Città VARCHAR(10), IN numero_carta VARCHAR(22),
	IN data_scadenza VARCHAR(7), IN Nome_intestatario VARCHAR(15), IN Cognome_intestatario VARCHAR(15), IN CVV VARCHAR(4), IN Password VARCHAR(50), IN username VARCHAR(25))
INSERT INTO aste.utenti VALUES(CF_Utente, Nome, Cognome, Data_nascita, Città_nascita, Indirizzo_consegna,
     Città, numero_carta, data_scadenza, Nome_intestatario, Cognome_intestatario, CVV, md5(Password), username, DEFAULT)$$

DELIMITER ;


-- -----------------------------------------------------
-- procedure listAggiudicati
-- -----------------------------------------------------

DELIMITER $$
CREATE PROCEDURE aste.listAggiudicati(IN cfUtente VARCHAR(16))
SELECT Oggetto AS "ID", CAST(Prezzo_vendita AS CHAR) AS "Saldo" FROM aste.aggiudicati WHERE Utente = cfUtente$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure listInteressati
-- -----------------------------------------------------

DELIMITER $$
CREATE PROCEDURE aste.listInteressati(IN cfUtente VARCHAR(16))
SELECT Oggetto AS "ID", Tipo AS "Oggetto" from aste.offerte JOIN aste.oggetto WHERE offerte.Oggetto = oggetto.Id_oggetto
AND Oggetto IN (SELECT Id_oggetto from aste.oggetto Where Data_termine >= NOW())
AND CF_Utente = cfUtente
GROUP BY Oggetto, Tipo$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure login
-- -----------------------------------------------------

DELIMITER $$
CREATE PROCEDURE aste.login(IN var_username varchar(45), in var_pass varchar(45), out var_role LONG)
BEGIN
	DECLARE temp_role LONG;

    SELECT ruolo from aste.utenti
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
CREATE PROCEDURE aste.nuova_offerta(IN CF VARCHAR(16), IN id VARCHAR(25),IN val_offerta VARCHAR(15), IN autoOfferta FLOAT, IN automatic BOOLEAN)
this_proc:BEGIN
DECLARE cfMax VARCHAR(16);
DECLARE lastOffer FLOAT;

-- Controllo se l'id esiste
	IF NOT EXISTS (SELECT * from aste.oggetto WHERE oggetto.Id_oggetto = id and oggetto.Data_termine > NOW())
		THEN SIGNAL SQLSTATE '02000' SET MESSAGE_TEXT = "Oggetto non in asta";
	END IF;
-- Controllo granularità offerte
	IF ( (MOD(val_offerta, 0.50))>0)
    THEN SIGNAL SQLSTATE '02000' SET MESSAGE_TEXT = "La granularita\' di incremento delle offerte e\' di multipli di 50 centesimi di euro";
    END IF;
-- Controllo se non ci sono ancora offerte sull'oggetto
	IF NOT EXISTS (SELECT * FROM aste.offerte WHERE offerte.Oggetto = id) THEN
		IF (val_offerta > (SELECT Prezzo_base FROM aste.oggetto WHERE Id_oggetto = id)) THEN
    INSERT INTO  aste.offerte VALUES(CF, NOW(6), val_offerta, autoOfferta, upper(id), automatic);
    LEAVE this_proc;
		ELSE SIGNAL SQLSTATE '02000' SET MESSAGE_TEXT = "Devi inserire un\'offerta maggiore";
		END IF;
  END IF;

-- controllo se è stato l'ultimo a mettere l'offerta
	CALL aste.getLastCF(id, cfMax);
    IF (cfMax != CF and cfMax is not null) then
		CALL aste.getLastOffer(id, lastOffer);
        -- controllo se il valore dell'offerta è maggiore del valore attuale dell'oggetto
        IF (lastOffer >= val_offerta) THEN SIGNAL SQLSTATE '02000' SET MESSAGE_TEXT = "Devi inserire un'offerta maggiore";
		END IF;
        IF (autoOfferta <= val_offerta and !automatic) THEN SIGNAL SQLSTATE '02000' SET MESSAGE_TEXT = "Se vuoi inserire una controfferta automatica, essa deve essere maggiore dell\'offerta attuale";
		END IF;
        INSERT INTO  aste.offerte VALUES(CF, NOW(6), val_offerta, autoOfferta, upper(id), automatic);
    ELSE SIGNAL SQLSTATE '02000' SET MESSAGE_TEXT = "La tua offerta e\' gia\' la piu\' alta";
	END IF;

END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure nuovo_admin
-- -----------------------------------------------------

DELIMITER $$
CREATE PROCEDURE aste.nuovo_admin(IN usr VARCHAR(255))
BEGIN
		DECLARE temp INT;
		SELECT ruolo FROM aste.utenti WHERE utenti.username = usr INTO temp;
		IF temp = 0 THEN UPDATE aste.utenti SET ruolo = 1 WHERE utenti.username = usr;
		ELSEIF temp is NULL THEN SIGNAL SQLSTATE '02000' SET message_text = "Nessun utente compatibile trovato";
        ELSEIF temp = 1 THEN SIGNAL SQLSTATE '02000' SET message_text = "L'utente selezionato e\' gia\' un amministratore";
		END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure reportID
-- -----------------------------------------------------

DELIMITER $$
CREATE PROCEDURE aste.reportID(IN id VARCHAR(25))
BEGIN
	IF (SELECT NOT EXISTS (SELECT Id_oggetto FROM aste.oggetto WHERE Id_oggetto = id))
    THEN SIGNAL SQLSTATE '02000' SET MESSAGE_TEXT = "Oggetto non presente nel database";
    END IF;

	SELECT CF_Utente AS "Utente", DATE_FORMAT(Insert_time, "%Y-%m-%d %H:%i:%s") AS "Data inserimento",
	CAST(Valore AS CHAR)AS "Valore offerta",(SELECT IF(automatic, "Si", "No")) AS "Automatica"
	FROM aste.offerte WHERE offerte.Oggetto = id
	ORDER BY offerte.Insert_time DESC;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure visualizza_aste_aperte
-- -----------------------------------------------------

DELIMITER $$
CREATE PROCEDURE aste.visualizza_aste_aperte()
BEGIN
SELECT Id_oggetto as ID, Tipo as Nome, Colore, Dimensioni, Condizione, CAST(Prezzo_base AS CHAR)as "Prezzo Iniziale",
CAST((SELECT Valore from aste.offerte Where Oggetto = Id_oggetto and Valore = (SELECT DISTINCT MAX(Valore) FROM aste.offerte WHERE Oggetto = Id_oggetto)) AS CHAR) as "Prezzo Attuale",
TIME_FORMAT(SEC_TO_TIME(TIMESTAMPDIFF(SECOND,NOW(), Data_termine)), "%T") as "Tempo rimanente",
CAST((SELECT COUNT(*) FROM aste.offerte WHERE offerte.Oggetto = ID) AS CHAR) AS "N.Offerte"

	FROM aste.oggetto
	WHERE Data_termine >= NOW();
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure visualizza_cat_3
-- -----------------------------------------------------

DELIMITER $$
CREATE PROCEDURE aste.visualizza_cat_3()
SELECT CC.Categoria as C1, CC.SubCategoria as C2, CCC.SubCategoria as C3
FROM aste.catIndex as CC JOIN aste.catIndex as CCC
	 ON (CC.SubCategoria = CCC.Categoria)
WHERE CC.Categoria IN (SELECT Nome_Categoria
			 FROM aste.categoria
			 WHERE Livello = "1" )  and CC.SubCategoria IN (SELECT Nome_Categoria
															FROM aste.categoria
															WHERE Livello = "2")  and CCC.SubCategoria IN (SELECT Nome_Categoria
																										   FROM aste.categoria
																								         	WHERE Livello = "3")$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure visualizza_oggetti
-- -----------------------------------------------------

DELIMITER $$
CREATE PROCEDURE aste.visualizza_oggetti()
SELECT Nome_oggetto as "Oggetto",  Descrizione_oggetto as "Descrizione" FROM aste.tipo_oggetto$$

DELIMITER ;
-- -----------------------------------------------------
-- procedure inserisci_oggetto
-- -----------------------------------------------------
DELIMITER $$
CREATE PROCEDURE aste.inserisci_oggetto(IN id VARCHAR(25), IN colore VARCHAR(25), IN dimensioni VARCHAR(50), IN prezzo FLOAT, IN condizione INT, IN tipo VARCHAR(25), IN scadenza VARCHAR(9))
BEGIN
	DECLARE categoria VARCHAR(25);
    DECLARE finale_scadenza DATETIME;
    IF (condizione <1 OR condizione>5) THEN SIGNAL SQLSTATE '02000' SET MESSAGE_TEXT = "Condizione non accettabile";
    ELSE
    SELECT Nome_categoria FROM aste.tipo_oggetto WHERE Nome_Oggetto = tipo INTO categoria;
    SET finale_scadenza = addtime(NOW(), time_format(scadenza, "%T"));
	INSERT INTO aste.oggetto VALUES (upper(id), colore, dimensioni, prezzo, condizione, finale_scadenza, upper(tipo), categoria);
	END IF;
END $$
DELIMITER ;

-- -----------------------------------------------------
-- procedure startEvent
-- -----------------------------------------------------
DELIMITER $$
CREATE PROCEDURE aste.startEvent ()
BEGIN
	SET GLOBAL event_scheduler = ON;
END $$
DELIMITER ;


-- -----------------------------------------------------
-- procedure getLastCF
-- -----------------------------------------------------
DELIMITER $$
CREATE PROCEDURE aste.getLastCF(IN id VARCHAR(25), OUT lastCF VARCHAR(16))
SELECT CF_Utente INTO lastCF from aste.offerte WHERE Oggetto = id and Valore = (SELECT DISTINCT MAX(Valore) FROM aste.offerte WHERE oggetto = id)$$

DELIMITER ;


-- -----------------------------------------------------
-- procedure getLastOffer
-- -----------------------------------------------------
DELIMITER $$
CREATE PROCEDURE aste.getLastOffer(IN id VARCHAR(25), OUT lastOffer FLOAT)
SELECT Valore INTO lastOffer FROM aste.offerte WHERE offerte.Oggetto = id and Insert_time = (SELECT DISTINCT MAX(Insert_time) FROM aste.offerte WHERE offerte.Oggetto = id)$$
DELIMITER ;
