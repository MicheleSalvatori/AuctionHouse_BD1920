-- drop procedure db_prova.login;
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