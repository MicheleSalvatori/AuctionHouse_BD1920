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

void nuova_asta(MYSQL *conn){
	clearScreen("nuova_asta");

}

void ins_categoria(MYSQL *conn, char *s){
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[3];

	char nome_cat_1[25], nome_cat_2[25], nome_cat_3[25];

	if (!setup_prepared_stmt(&prepared_stmt, "call prova(?,?,?)",conn)){
		print_stmt_error(prepared_stmt, "Impossibile inizializzare statement per inserire categoria\n");
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
