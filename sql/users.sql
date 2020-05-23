# utente utilizzato per login
CREATE USER 'login'@'localhost' IDENTIFIED BY 'loginUser';
GRANT EXECUTE ON PROCEDURE db_prova.login TO 'login'@'localhost';

# utente
CREATE USER 'user'@'localhost' IDENTIFIED BY 'userPsw';
GRANT EXECUTE ON PROCEDURE db_prova.visualizza_aste_aperte TO 'user'@'localhost';
GRANT EXECUTE ON PROCEDURE db_prova.visualizza_cat_1 TO 'user'@'localhost';

#admin
CREATE USER 'admin'@'localhost' IDENTIFIED BY 'admin';
GRANT EXECUTE ON PROCEDURE db_prova.inserisci_oggetto TO 'admin'@'localhost';
GRANT EXECUTE ON PROCEDURE db_prova.visualizza_aste_aperte TO 'admin'@'localhost';
GRANT EXECUTE ON PROCEDURE db_prova.visualizza_cat_3 TO 'admin'@'localhost';
GRANT EXECUTE ON PROCEDURE db_prova.inserisci_categoria TO 'admin'@'localhost';
GRANT EXECUTE ON PROCEDURE db_prova.nuovo_admin TO 'admin'@'localhost';
GRANT EXECUTE ON PROCEDURE db_prova.visualizza_oggetti TO 'admin'@'localhost'
