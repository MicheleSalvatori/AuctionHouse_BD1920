GRANT EXECUTE ON PROCEDURE db_prova.inserisci_utente to 'login'@'localhost';
FLUSH PRIVILEGES;


select * from db_prova.utenti;
delete from db_prova.utenti where CF_Utente LIKE "S%";

CREATE USER 'login'@'localhost' IDENTIFIED BY 'loginUser';
GRANT EXECUTE ON PROCEDURE db_prova.login TO 'login'@'localhost';	
GRANT EXECUTE ON PROCEDURE db_prova.inserisci_utente TO 'login'@'localhost';

CREATE USER 'user'@'localhost' IDENTIFIED BY 'userPsw';
GRANT EXECUTE ON PROCEDURE db_prova.visualizza_aste_aperte TO 'user'@'localhost';
GRANT EXECUTE ON PROCEDURE db_prova.visualizza_cat_1 TO 'user'@'localhost';


CREATE USER 'admin'@'localhost' IDENTIFIED BY 'admin';
GRANT EXECUTE ON PROCEDURE db_prova.inserisci_oggetto TO 'admin'@'localhost';
GRANT EXECUTE ON PROCEDURE db_prova.visualizza_aste_aperte TO 'admin'@'localhost';
GRANT EXECUTE ON PROCEDURE db_prova.visualizza_cat_3 TO 'admin'@'localhost';
GRANT EXECUTE ON PROCEDURE db_prova.inserisci_categoria TO 'admin'@'localhost';
GRANT EXECUTE ON PROCEDURE db_prova.nuovo_admin TO 'admin'@'localhost';
GRANT EXECUTE ON PROCEDURE db_prova.visualizza_oggetti TO 'admin'@'localhost';
GRANT EXECUTE ON PROCEDURE db_prova.inserisci_Tipo TO 'admin'@'localhost';


SHOW GRANTS FOR 'admin'@'localhost';
REVOKE EXECUTE ON PROCEDURE db_prova.inserisci_categoria FROM 'admin'@'localhost';


SELECT addtime("2020/05/08 12:53:35", "00:12:01:");


