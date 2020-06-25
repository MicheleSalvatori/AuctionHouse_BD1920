#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <mysql/mysql.h>
#include <unistd.h>

#include "defines.h"

#define fflush(stdin) while ((getchar()) != '\n')
#define true 1
#define false 0
#define CF_SIZE 16
int cmd, status;


void visualizza_cat_3(MYSQL* conn){
	MYSQL_STMT *prepared_stmt;
	int status;

	if (!setup_prepared_stmt(&prepared_stmt, "call visualizza_cat_3()", conn)){
		finish_with_stmt_error(conn, prepared_stmt, "Impossibile visualizzare le categorie\n", false);
	}

	if (mysql_stmt_execute(prepared_stmt)!= 0){
		print_stmt_error(prepared_stmt, "Errore durante la visualizzazione delle categorie");
		goto out;
	}

// RESULTS
	do{
		if (conn->server_status & SERVER_PS_OUT_PARAMS){
			goto next;
		}

		else{
			dump_result_set(conn, prepared_stmt, "Categorie");
		}
		// more results? -1 = no, >0 = error, 0 = yes (keep looking)
	 	next:
		status = mysql_stmt_next_result(prepared_stmt);
		if (status > 0)
			finish_with_stmt_error(conn, prepared_stmt, "Unexpected condition", true);

	} while (status == 0);


	out:
	mysql_stmt_close(prepared_stmt);
}

void visualizza_aste_aperte(MYSQL* conn, char *s){
	MYSQL_STMT *prepared_stmt;
	int status;

	clearScreen(s);
	if (!setup_prepared_stmt(&prepared_stmt, "call visualizza_aste_aperte", conn)){
		printf("ERRORE\n");
		finish_with_stmt_error(conn, prepared_stmt, "Impossibile visualizzare aste aperte\n", false);

	}

	if (mysql_stmt_execute(prepared_stmt)!=0){
		print_stmt_error(prepared_stmt, "Errore durante la visualizzazione delle aste aperte");
		goto out;
	}

	do{
		if (conn->server_status & SERVER_PS_OUT_PARAMS){
			goto next;
		}

		else{
			dump_result_set(conn, prepared_stmt, "Aste:");
		}
		// more results? -1 = no, >0 = error, 0 = yes (keep looking)
	    next:
		status = mysql_stmt_next_result(prepared_stmt);
		if (status > 0)
			finish_with_stmt_error(conn, prepared_stmt, "Unexpected condition", true);

	} while (status == 0);


	out:
	mysql_stmt_close(prepared_stmt);
}


void nuova_offerta(MYSQL *conn, char *s){
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[5];
	char id[25];
	float valore;
	float controfferta;
	my_bool automatic = 0;


	if (!setup_prepared_stmt(&prepared_stmt, "call nuova_offerta(?,?,?,?,?)",conn)){
		print_stmt_error(prepared_stmt, "Impossibile inizializzare la procedura per inserire una nuova offerta");
	}
	clearScreen(s);

	printf("Inserisci ID dell'oggetto interessato: ");;
	scanf("%[^\n]", id);
	fflush(stdin);
	if (!strcasecmp(id, "quit")) goto err;

	printf("Inserisci valore offerta: ");
	scanf("%f", &valore);
	fflush(stdin);

	printf("Inserisci valore per una controfferta automatica [0 = no]: ");
	scanf("%f", &controfferta);
	fflush(stdin);

	printf("\nRiepilogo dati: %s-> %f-> %f", id, valore, controfferta);
	input_wait("Premi invio per confermare...");


	memset(param, 0, sizeof(param));
	param[0].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[0].buffer = s;
	param[0].buffer_length = strlen(s);

	param[2].buffer_type = MYSQL_TYPE_FLOAT;
	param[2].buffer = &valore;
	param[2].buffer_length = sizeof(valore);

	param[1].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[1].buffer = id;
	param[1].buffer_length = strlen(id);

	if ( controfferta == 0){
		param[3].buffer_type = MYSQL_TYPE_NULL;
		param[3].buffer = NULL;
		param[3].buffer_length = sizeof(controfferta);
	}else{
		param[3].buffer_type = MYSQL_TYPE_FLOAT;
		param[3].buffer = &controfferta;
		param[3].buffer_length = sizeof(controfferta);
	}

	param[4].buffer_type = MYSQL_TYPE_TINY;
	param[4].buffer = (char*)&automatic;
	param[4].buffer_length = sizeof(automatic);


	if (mysql_stmt_bind_param(prepared_stmt, param)!=0){
		print_stmt_error(prepared_stmt, "Imposibbile inizializzare parametri per la nuova offerta");
		goto err;
	}

	if (mysql_stmt_execute(prepared_stmt)!=0){
		print_stmt_error(prepared_stmt, "Impossibile eseguire procedura nuova offerta");
		goto err;
	} else{
		printf("Offerta aggiunta correttamente\n");
		mysql_stmt_close(prepared_stmt);
	}

// controfferta automatica

	if (!setup_prepared_stmt(&prepared_stmt, "call autoOfferta(?,?,?)",conn)){
		print_stmt_error(prepared_stmt, "Impossibile inizializzare la procedura per il controllo della controfferta");
	}
	param[0].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[0].buffer = s;
	param[0].buffer_length = strlen(s);

	param[2].buffer_type = MYSQL_TYPE_FLOAT;
	param[2].buffer = &valore;
	param[2].buffer_length = sizeof(valore);

	param[1].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[1].buffer = id;
	param[1].buffer_length = strlen(id);

	if (mysql_stmt_bind_param(prepared_stmt, param)!=0){
		print_stmt_error(prepared_stmt, "Imposibbile inizializzare parametri per il controllo della controfferta");
		goto err;
	}

	if (mysql_stmt_execute(prepared_stmt)!=0){
		print_stmt_error(prepared_stmt, "Impossibile eseguire procedura per il controllo della controfferta");
		goto err;
	} else{
		input_wait("Controllo sistema controfferta...\n");
		mysql_stmt_close(prepared_stmt);
	}

	err:
	mysql_stmt_close(prepared_stmt);
	return;
}




void run_as_user(MYSQL *conn, char *s){
MYSQL_STMT *prepared_stmt;
MYSQL_BIND param[2];
char cf[17];

	if (mysql_change_user(conn,"user", "userPsw", "db_prova")){
		fprintf(stderr, "mysql_change_user() failed\n");
		exit(EXIT_FAILURE);
	}
	if (!setup_prepared_stmt(&prepared_stmt, "call getCF(?,?)",conn)){
		print_stmt_error(prepared_stmt, "Impossibile inizializzare la procedura per inserire una nuova offerta");
	}

	memset(param, 0, sizeof(param));
	param[0].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[0].buffer = s;
	param[0].buffer_length = strlen(s);

	param[1].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[1].buffer = (char*)cf;
	param[1].buffer_length = 17;

	if (mysql_stmt_bind_param(prepared_stmt, param)!=0){
		print_stmt_error(prepared_stmt, "Imposibbile ottenere codice fiscale utente");
		goto err;
	}

	if (mysql_stmt_execute(prepared_stmt)!=0){
		print_stmt_error(prepared_stmt, "Impossibile eseguire procedura per ottenere codice fiscale");
		goto err;
	}

	memset(param, 0, sizeof(param));
	param[0].buffer_type = MYSQL_TYPE_VAR_STRING; // OUT
	param[0].buffer = (char*)cf;
	param[0].buffer_length = 17;

	if(mysql_stmt_bind_result(prepared_stmt, param)) {
		print_stmt_error(prepared_stmt, "Could not retrieve output parameter");
		goto err;
	}
	if(mysql_stmt_fetch(prepared_stmt)) {
		print_stmt_error(prepared_stmt, "Could not buffer results");
		goto err;
	}
	mysql_stmt_close(prepared_stmt);
	printf("CF: %s\n", cf);

	while(true){
		clearScreen(s);
		printf("1) Visulizza aste aperte\n");
		printf("2) Nuova offerta\n");
		printf("99) Logout\n");
		printf("Inserisci un comando -> ");
		scanf("%i", &cmd);
		fflush(stdin);

		if (cmd == 1){
			// clearScreen(s);
			// visualizza_aste_aperte(conn, s);
			// print_sql_query(conn, "call visualizza_aste_aperte()");
			input_wait("");
			continue;
		}
		if (cmd == 2){
			clearScreen(s);
			nuova_offerta(conn, cf);
			input_wait("Premi un tanto per continuare");
			continue;
		}
		if (cmd == 99){
			break;
		}
		else {
			printf("\n-- Comando non presente --\n");
			input_wait();
		}
	}

	err:
	mysql_stmt_close(prepared_stmt);
}
