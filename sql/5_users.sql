## LOGIN USER
CREATE USER 'login'@'localhost' IDENTIFIED BY 'loginUser';
GRANT EXECUTE ON PROCEDURE aste.login TO 'login'@'localhost';
GRANT EXECUTE ON PROCEDURE aste.inserisci_utente TO 'login'@'localhost';

## USER
CREATE USER 'user'@'localhost' IDENTIFIED BY 'userPsw';
GRANT EXECUTE ON PROCEDURE aste.visualizza_aste_aperte TO 'user'@'localhost';
GRANT EXECUTE ON PROCEDURE aste.getCF TO 'user'@'localhost';
GRANT EXECUTE ON PROCEDURE aste.visualizza_cat_3 TO 'user'@'localhost';
GRANT EXECUTE ON PROCEDURE aste.autoOfferta TO 'user'@'localhost';
GRANT EXECUTE ON PROCEDURE aste.listInteressati TO 'user'@'localhost';
GRANT EXECUTE ON PROCEDURE aste.listAggiudicati TO 'user'@'localhost';
GRANT EXECUTE ON PROCEDURE aste.nuova_offerta TO 'user'@'localhost';

##ADMIN
CREATE USER 'admin'@'localhost' IDENTIFIED BY 'adminPsw';
GRANT EXECUTE ON PROCEDURE aste.inserisci_oggetto TO 'admin'@'localhost';
GRANT EXECUTE ON PROCEDURE aste.visualizza_aste_aperte TO 'admin'@'localhost';
GRANT EXECUTE ON PROCEDURE aste.visualizza_cat_3 TO 'admin'@'localhost';
GRANT EXECUTE ON PROCEDURE aste.inserisci_categoria TO 'admin'@'localhost';
GRANT EXECUTE ON PROCEDURE aste.nuovo_admin TO 'admin'@'localhost';
GRANT EXECUTE ON PROCEDURE aste.visualizza_oggetti TO 'admin'@'localhost';
GRANT EXECUTE ON PROCEDURE aste.inserisci_Tipo TO 'admin'@'localhost';
GRANT EXECUTE ON PROCEDURE aste.reportID TO 'admin'@'localhost';

FLUSH PRIVILEGES;
