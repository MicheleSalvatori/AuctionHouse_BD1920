CREATE DEFINER=`root`@`localhost` PROCEDURE `inserisci_oggetto`(IN id VARCHAR(25), IN colore VARCHAR(25), IN prezzo VARCHAR(15), IN condizione INT, IN tipo VARCHAR(25), IN scadenza VARCHAR(9))
BEGIN 
	DECLARE categoria VARCHAR(25);
    DECLARE finale_scadenza DATETIME;
    IF (condizione <1 OR condizione>5) THEN SIGNAL SQLSTATE '02000' SET MESSAGE_TEXT = "Condizione non accettabile";
    ELSE
    SELECT Nome_categoria FROM db_prova.tipo_oggetto WHERE Nome_Oggetto = tipo INTO categoria;
    SET finale_scadenza = addtime(NOW(), time_format(scadenza, "%T"));
	INSERT INTO db_prova.oggetto VALUES (upper(id), colore, prezzo, condizione, finale_scadenza, prezzo, upper(tipo), categoria);
	END IF;
END