## LOGIN USER
CREATE USER 'login'@'localhost' IDENTIFIED BY 'loginUser';
GRANT EXECUTE ON PROCEDURE auction_house.login TO 'login'@'localhost';
GRANT EXECUTE ON PROCEDURE auction_house.inserisci_utente TO 'login'@'localhost';

## USER
CREATE USER 'user'@'localhost' IDENTIFIED BY 'userPsw';
GRANT EXECUTE ON PROCEDURE auction_house.visualizza_aste_aperte TO 'user'@'localhost';
GRANT EXECUTE ON PROCEDURE auction_house.getCF TO 'user'@'localhost';
GRANT EXECUTE ON PROCEDURE auction_house.visualizza_cat_3 TO 'user'@'localhost';
GRANT EXECUTE ON PROCEDURE auction_house.autoOfferta TO 'user'@'localhost';
GRANT EXECUTE ON PROCEDURE auction_house.listInteressati TO 'user'@'localhost';
GRANT EXECUTE ON PROCEDURE auction_house.listAggiudicati TO 'user'@'localhost';
GRANT EXECUTE ON PROCEDURE auction_house.nuova_offerta TO 'user'@'localhost';

##ADMIN
CREATE USER 'admin'@'localhost' IDENTIFIED BY 'adminPsw';
GRANT EXECUTE ON PROCEDURE auction_house.inserisci_oggetto TO 'admin'@'localhost';
GRANT EXECUTE ON PROCEDURE auction_house.visualizza_aste_aperte TO 'admin'@'localhost';
GRANT EXECUTE ON PROCEDURE auction_house.visualizza_cat_3 TO 'admin'@'localhost';
GRANT EXECUTE ON PROCEDURE auction_house.inserisci_categoria TO 'admin'@'localhost';
GRANT EXECUTE ON PROCEDURE auction_house.nuovo_admin TO 'admin'@'localhost';
GRANT EXECUTE ON PROCEDURE auction_house.visualizza_oggetti TO 'admin'@'localhost';
GRANT EXECUTE ON PROCEDURE auction_house.inserisci_Tipo TO 'admin'@'localhost';
GRANT EXECUTE ON PROCEDURE auction_house.reportID TO 'admin'@'localhost';

FLUSH PRIVILEGES;
