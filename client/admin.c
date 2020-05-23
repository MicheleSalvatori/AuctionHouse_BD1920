#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <mysql/mysql.h>
#include <unistd.h>

#include "defines.h"

#define fflush(stdin) while ((getchar()) != '\n')
#define true 1
#define false 0
int cmd;
// TODO in qualsiasi azione che si vuole fare inserire opzione quit per uscire e tornare al menu (se si è entrati per sbaglio ad esempio)

void visualizza_oggetti(MYSQL* conn){
	MYSQL_STMT *prepared_stmt;
	int status;

	if(!setup_prepared_stmt(&prepared_stmt, "call visualizza_oggetti()", conn)){
		print_stmt_error(prepared_stmt, "Impossibilie inizializzare procedura per visualizzare gli oggetti già presenti");
		goto err;
	}
	if (mysql_stmt_execute(prepared_stmt)!=0){
		print_stmt_error(prepared_stmt, "Impossibile eseguire procedura visualizza oggetti");
		goto err;
	}
	// results
	do{
		if (conn->server_status & SERVER_PS_OUT_PARAMS){
			goto next;
		}

		else{
			dump_result_set(conn, prepared_stmt, "Oggetti");
		}

		next:
		status = mysql_stmt_next_result(prepared_stmt);
		if (status > 0)
			finish_with_stmt_error(conn, prepared_stmt, "Unexpected condition", true);

	} while (status == 0);
	mysql_stmt_close(prepared_stmt);

	err:
	mysql_stmt_close(prepared_stmt);
	return;

}

void crea_asta(MYSQL *conn){				// TODO non ritorna la stringa dio paperirino -> IDEA: inglobare get_cat_3 nella procedura inserisci_oggetto
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[2];
	char nome[26], cat[25];

	clearScreen("Apertura asta");
	visualizza_oggetti(conn);

	if (!setup_prepared_stmt(&prepared_stmt, "call get_cat_3(?,?)", conn)){
	print_stmt_error(prepared_stmt, "Impossibile inizializzare procedura get_cat_3");
	goto err;
	}

	memset(param, 0, sizeof(param));
	printf("Nome oggetto: ");
	scanf("%s\n", nome );
	fflush(stdin);
	param[0].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[0].buffer = nome;
	param[0].buffer_length = strlen(nome);

	param[1].buffer_type = MYSQL_TYPE_VAR_STRING; // OUT
	param[1].buffer = cat;
	param[1].buffer_length = sizeof(cat);

	if (mysql_stmt_bind_param(prepared_stmt, param)!=0){
		print_stmt_error(prepared_stmt, "Imposibbile inizializzare parametri per get_cat_3");
		goto err;
	}

	if (mysql_stmt_execute(prepared_stmt)!=0){
		print_stmt_error(prepared_stmt, "Impossibile eseguire procedura get_cat_3");
		goto err;
	}

	memset(param, 0, sizeof(param));
		param[0].buffer_type = MYSQL_TYPE_VAR_STRING; // OUT
		param[0].buffer = cat;
		param[0].buffer_length = sizeof(cat);

	if(mysql_stmt_bind_result(prepared_stmt, param)) {
		print_stmt_error(prepared_stmt, "Could not retrieve output parameter");
		goto err;
	}
	if(mysql_stmt_fetch(prepared_stmt)) {
		print_stmt_error(prepared_stmt, "Could not buffer results");
		goto err;
	}

	printf("%s\n", cat);
	input_wait("");
	mysql_stmt_close(prepared_stmt);
	return;

err:
mysql_stmt_close(prepared_stmt);
return;
}

void nuova_asta(MYSQL *conn){
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[4];
	int status;
	char nome[25], dimensioni[25], descrizione[255], categoria[25], risposta[5];

	clearScreen("Nuova asta");
	visualizza_oggetti(conn);
	printf("L'oggetto da inserire è presente in questa lista? [SI/NO] -> ");
	scanf("%s", risposta);
	fflush(stdin);

	// if(!strcasecmp(risposta, "quit")){
	// 	goto err;}

	if(!strcasecmp(risposta, "no")){
		clearScreen("Creazione oggetto");

		visualizza_cat_3(conn);

		if (!setup_prepared_stmt(&prepared_stmt, "call inserisci_Tipo(?,?,?,?)", conn)){
		print_stmt_error(prepared_stmt, "Impossibile inizializzare procedura inserimento tipo oggetto");
		goto err;
		}

		printf("Nome oggetto: ");
		scanf("%[^\n]", nome);
		fflush(stdin);
		printf("Dimensioni: ");
		scanf("%[^\n]", dimensioni);
		fflush(stdin);
		printf("Descrizione: ");
		scanf("%[^\n]", descrizione);
		fflush(stdin);
		printf("Categoria 3: ");
		scanf("%[^\n]", categoria);
		fflush(stdin);


		memset(param, 0, sizeof(param));
		param[0].buffer_type = MYSQL_TYPE_VAR_STRING;
		param[0].buffer = categoria;
		param[0].buffer_length = strlen(categoria);
		param[1].buffer_type = MYSQL_TYPE_VAR_STRING;
		param[1].buffer = nome;
		param[1].buffer_length = strlen(nome);
		param[2].buffer_type = MYSQL_TYPE_VAR_STRING;
		param[2].buffer = dimensioni;
		param[2].buffer_length = strlen(dimensioni);
		param[3].buffer_type = MYSQL_TYPE_VAR_STRING;
		param[3].buffer = descrizione;
		param[3].buffer_length = strlen(descrizione);

		if (mysql_stmt_bind_param(prepared_stmt, param)!=0){
			print_stmt_error(prepared_stmt, "Imposibbile inizializzare parametri per inseriemento nuovo oggetto");
			goto err;
		}

		if (mysql_stmt_execute(prepared_stmt)!=0){
			print_stmt_error(prepared_stmt, "Impossibile eseguire procedura inseriemento nuovo oggetto");
			goto err;
		} else{
			printf("Oggetto aggiunto correttamente\n");
			mysql_stmt_close(prepared_stmt);
		}
	}

	else if (!strcasecmp(risposta, "si")){
		crea_asta(conn);
	}

	return;
	err:
	mysql_stmt_close(prepared_stmt);
	return;

}

void ins_categoria(MYSQL *conn, char *s){
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[3];


	char nome_cat_1[25], nome_cat_2[25], nome_cat_3[25];

	if (!setup_prepared_stmt(&prepared_stmt, "call inserisci_categoria(?,?,?)",conn)){
		print_stmt_error(prepared_stmt, "Impossibile inizializzare la procedura per inserire categoria");
	}
	clearScreen(s);

	visualizza_cat_3(conn);
	printf("Categoria Livello 1: ");
	scanf("%[^\n]", nome_cat_1);
	fflush(stdin);

	printf("Categoria Livello 2: ");
	scanf("%[^\n]", nome_cat_2);
	fflush(stdin);
// TODO: aggiustare procedure inserisci_categoria in procedures.sql
	printf("Categoria Livello 3: ");
	scanf("%[^\n]", nome_cat_3);
	fflush(stdin);

	printf("\nRiepilogo dati: %s->%s->%s", nome_cat_1, nome_cat_2, nome_cat_3);
	input_wait("Premi invio per confermare...");

	// controlli su input //TODO non funzionano tanto -> Valutare uso funzione getInput di Pellegrini
	if (nome_cat_1 == " " || nome_cat_2 == " " || nome_cat_3 == " "){
		printf("Devi inserire valori validi\n");
		goto err;
	}

	memset(param, 0, sizeof(param));
	param[0].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[0].buffer = nome_cat_1;
	param[0].buffer_length = strlen(nome_cat_1);

	param[1].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[1].buffer = nome_cat_2;
	param[1].buffer_length = strlen(nome_cat_2);

	param[2].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[2].buffer = nome_cat_3;
	param[2].buffer_length = strlen(nome_cat_3);

	if (mysql_stmt_bind_param(prepared_stmt, param)!=0){
		print_stmt_error(prepared_stmt, "Imposibbile inizializzare parametri per la nuova categoria");
		goto err;
	}

	if (mysql_stmt_execute(prepared_stmt)!=0){
		print_stmt_error(prepared_stmt, "Impossibile eseguire procedura nuova categoria");
		goto err;
	} else{
		printf("Categoria aggiunta correttamente\n");
	}

	mysql_stmt_close(prepared_stmt);
	return;

	err:
	mysql_stmt_close(prepared_stmt);
	return;
}

void ins_admin(MYSQL *conn){
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[1];
	char username[255];


	if (!setup_prepared_stmt(&prepared_stmt, "call nuovo_admin(?)", conn)){
		print_stmt_error(prepared_stmt, "Impossibile nominare un nuovo amministratore");
		goto err;
	}

	clearScreen("Nuovo amministratore");
	printf("Username del nuovo amministratore: ");
	scanf("%[^\n]", username);
	fflush(stdin);

	// controllo input
	if (username == ""){
		printf("Non hai inserito alcun username\n");
		input_wait("");
		goto err;
	}

	memset(param, 0, sizeof(param));
	param[0].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[0].buffer = username;
	param[0].buffer_length = strlen(username);

	if (mysql_stmt_bind_param(prepared_stmt, param)!=0){
		print_stmt_error(prepared_stmt, "Impossibile inizializzare i parametri per il nuovo amministratore");
		goto err;
	}

	if (mysql_stmt_execute(prepared_stmt)!=0) {
		print_stmt_error(prepared_stmt, "Impossibile eseguire procedura nuovo amministratore");
		goto err;
	}else{
		printf("Amministratore aggiunto correttamente\n" );
		mysql_stmt_close(prepared_stmt);
		return;
	}

	err:
	mysql_stmt_close(prepared_stmt);
	return;
}




void run_as_admin(MYSQL *conn, char *s){

	if (mysql_change_user(conn,"admin", "admin", "db_prova")){
		fprintf(stderr, "mysql_change_user() failed\n");
		exit(EXIT_FAILURE);
	}

	// printf("size: %d\n", strlen(s) );
	char header[strlen(s)+1];
	sprintf(header, "Admin: %s", s);

	while(true){
		clearScreen(header);
		printf("1) Visulizza aste aperte\n");
		printf("2) Inserisci nuova asta\n");
		printf("3) Inserisci Oggetto\n");
		printf("4) Crea nuova categoria\n");
		printf("5) Nuovo amminastrore\n");
		printf("99) Logout\n");
		printf("Inserisci un comando -> ");
		scanf("%i", &cmd);
		fflush(stdin);

		if (cmd == 1){
			visualizza_aste_aperte(conn, header);
			input_wait("Premi un tasto per continuare...");
			continue;
		}

		if (cmd == 2){
			nuova_asta(conn);
			input_wait("Premi un tasto per continuare...");
			continue;
		}

		if (cmd == 4){
			ins_categoria(conn, header);
			input_wait("Premi un tasto per continuare...");
			continue;
		}

		if (cmd == 5){
			ins_admin(conn);
			input_wait("Premi un tasto per continuare...");
			continue;
		}

		if (cmd == 99){
			break;
		}

		else{
			printf("\n-- Comando non presente\n\n");
			input_wait();
		}
	}

}
