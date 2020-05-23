CREATE PROCEDURE db_prova.inserisci_utente(IN CF_Utente CHAR(16), IN Nome VARCHAR(15),
	IN Cognome VARCHAR(15), IN Data_nascita	DATE, IN Città_nascita VARCHAR(15), IN Indirizzo_consegna VARCHAR(45), IN Città VARCHAR(10), IN numero_carta VARCHAR(22),
	IN data_scadenza VARCHAR(7), IN Nome_intestatario VARCHAR(15), IN Cognome_intestatario VARCHAR(15), IN CVV VARCHAR(4), IN Password VARCHAR(50), IN username VARCHAR(25))

    INSERT INTO db_prova.utenti VALUES(CF_Utente, Nome, Cognome, Data_nascita, Città_nascita, Indirizzo_consegna,
     Città, numero_carta, data_scadenza, Nome_intestatario, Cognome_intestatario, CVV, Password, username, DEFAULT);


DELIMITER $$
CREATE PROCEDURE db_prova.inserisci_categoria(IN Nome_categoria VARCHAR (25), IN Livello INT)
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

    if temp_1 = 0 then
    INSERT INTO db_prova.categoria VALUES  (Nome_cat_1, 1);
    elseif temp_2 = 0 then
    INSERT INTO db_prova.categoria VALUES (Nome_cat_2, 2);
    elseif temp_3 = 0 then
    INSERT INTO db_prova.categoria VALUES (Nome_cat_3, 3);

	end if;

    call db_prova.collega_categorie(Nome_cat_1, Nome_cat_2);
    call db_prova.collega_categorie(Nome_cat_2, Nome_cat_3);

END $$
DELIMITER ;


DELIMITER $$
CREATE PROCEDURE db_prova.collega_categorie (IN Nome_categoria VARCHAR(25), IN Nome_sub_categoria VARCHAR(25))
BEGIN
    DECLARE temp_1, temp_2 INT;

    SELECT COUNT(*) FROM db_prova.catIndex WHERE catIndex.Categoria = Nome_categoria and catIndex.SubCategoria = Nome_sub_categoria INTO temp_1;

    if temp_1 = 0 then
    INSERT INTO db_prova.catIndex VALUES (Nome_categoria, Nome_sub_categoria);
    end if;
END $$
DELIMITER ;


CREATE PROCEDURE db_prova.visualizza_oggetti()
	SELECT * FROM db_prova.tipo_oggetto;

DELIMITER $$
CREATE PROCEDURE db_prova.inserisci_Tipo (IN Nome_categoria VARCHAR(25), IN Nome_Oggetto VARCHAR(25), IN Dimensioni VARCHAR(25), IN Descrizione VARCHAR(255))
BEGIN
	IF (SELECT NOT EXISTS (SELECT *
			 FROM db_prova.categoria
			 WHERE Livello = "3" and categoria.Nome_Categoria = Nome_Categoria))
	THEN
			SIGNAL SQLSTATE '02000' SET MESSAGE_TEXT = 'Attenzione categoria non di livello 3';
	ELSE INSERT INTO db_prova.tipo_oggetto VALUES (Nome_categoria, Nome_Oggetto, Dimensioni, Descrizione);
			END IF;
END $$

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


CREATE PROCEDURE db_prova.inserisci_oggetto(IN id VARCHAR(25), IN colore VARCHAR(25), IN prezzo VARCHAR(15), IN condizione VARCHAR(30),
	IN Data_termine DATETIME, IN tipo VARCHAR(25), IN Categoria VARCHAR(25))

	INSERT INTO db_prova.oggetti VALUES (id, colore, prezzo, condizione, Data_termine, prezzo, tipo, Categoria);


CREATE PROCEDURE db_prova.visualizza_aste_aperte ()
	SELECT Id_oggetto as ID, Tipo as Nome, Colore, Condizione, Prezzo_base as "Prezzo Iniziale", Prezzo_attuale as "Prezzo Attuale", TIME_FORMAT(SEC_TO_TIME(TIMESTAMPDIFF(SECOND,NOW(), Data_termine)), "%T") as "Tempo rimanente"
	FROM db_prova.oggetto
	WHERE Data_termine >= NOW();

DELIMITER $$
CREATE PROCEDURE db_prova.nuovo_admin(IN usr VARCHAR(255))
	BEGIN
		DECLARE temp INT;
		SELECT COUNT(*) FROM db_prova.utenti WHERE utenti.username = usr AND utenti.ruolo = 0 INTO temp;
		IF temp <> 0 THEN UPDATE db_prova.utenti SET ruolo = 1 WHERE utenti.username = usr;
		ELSE SIGNAL SQLSTATE '45002' SET message_text = "Nessun utente compatibile trovato";
		END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE db_prova.login(IN var_username varchar(45), in var_pass varchar(45), out var_role LONG)
BEGIN
	DECLARE temp_role LONG;		-- variabile temp_role serve altrimenti var_role è sempre 0 e quindi ritorna sempre -> utente

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

END $$
