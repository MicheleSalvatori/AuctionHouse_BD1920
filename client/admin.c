#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <mysql/mysql.h>
#include <unistd.h>

#include "defines.h"

#define fflush(stdin) while ((getchar()) != '\n')
#define true 1
#define false 0

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
	// RESULTS
	do{
		if (conn->server_status & SERVER_PS_OUT_PARAMS){
			goto next;
		}

		else{
			dump_result_set(conn, prepared_stmt, "");
		}

		next:
		status = mysql_stmt_next_result(prepared_stmt);
		if (status > 0)
			finish_with_stmt_error(conn, prepared_stmt, "Unexpected condition", true);

	} while (status == 0);

	err:
	mysql_stmt_close(prepared_stmt);
	return;

}

void crea_asta(MYSQL *conn){
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[6];
	MYSQL_TIME time_st;
	char id[25], colore[25], prezzo[15], tipo[25], data[9];
	int condizione;

	if (!setup_prepared_stmt(&prepared_stmt, "call inserisci_oggetto(?,?,?,?,?,?)", conn)){
	print_stmt_error(prepared_stmt, "Impossibile inizializzare procedura per inserire una nuova asta");
	goto err;
	}

	printf("Seleziona oggetto da inserire tra quelli elencati [nome]: ");
	scanf("%[^\n]", tipo);
	fflush(stdin);

	clearScreen("Nuova asta");
	memset(param, 0, sizeof(param));
	printf("ID [alfanumerico]: ");
	scanf("%[^\n]", id );
	fflush(stdin);
	printf("Colore: ");
	scanf("%[^\n]", colore);
	fflush(stdin);
	printf("Prezzo di partenza: ");
	scanf("%[^\n]", prezzo);
	fflush(stdin);
	clearScreen("Condizione oggetto");
	printf("Scegli la condizione dell'oggetto:\n1) Nuovo\t2) Come nuovo\t3) Buone condizioni\n4) Usurato\t5) Non funzionante\n-> ");
	scanf("%d", &condizione);
	fflush(stdin);

	time_st = getDate();

	sprintf(data, "%d:%02d",time_st.day * 24 + time_st.hour, time_st.minute);
	fflush(stdin);

	param[0].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[0].buffer = id;
	param[0].buffer_length = strlen(id);

	param[1].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[1].buffer = colore;
	param[1].buffer_length = strlen(colore);

	param[2].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[2].buffer = prezzo;
	param[2].buffer_length = strlen(prezzo);

	param[3].buffer_type = MYSQL_TYPE_LONG;
	param[3].buffer = &condizione;
	param[3].buffer_length = sizeof(condizione);

	param[4].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[4].buffer = tipo;
	param[4].buffer_length = strlen(tipo);

	param[5].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[5].buffer = data;
	param[5].buffer_length = strlen(data);

	if (mysql_stmt_bind_param(prepared_stmt, param)!=0){
		print_stmt_error(prepared_stmt, "Imposibbile inizializzare parametri per la nuova asta");
		goto err;
	}

	if (mysql_stmt_execute(prepared_stmt)!=0){
		print_stmt_error(prepared_stmt, "Impossibile eseguire procedura per creare nuova asta");
		goto err;
	}else {
		printf("Asta creata correttamente\n");
		input_wait("");
	}

	mysql_stmt_close(prepared_stmt);
	return;

err:
mysql_stmt_close(prepared_stmt);
return;
}

void nuova_asta(MYSQL *conn){
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[4];
	char nome[25], dimensioni[25], descrizione[255], categoria[25], risposta[5];

	clearScreen("Nuova asta");
	visualizza_oggetti(conn);
	printf("L'oggetto da inserire è presente in questa lista? [SI/NO/QUIT] -> ");
	scanf("%s", risposta);
	fflush(stdin);

	if(!strcasecmp(risposta, "quit")){
		return;
	}

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
	if (!strcasecmp(risposta, "si")){
		crea_asta(conn);
		return;
	}

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
	printf("Inserisci quit per tornare al menu precedente..\n");;
	printf("Categoria Livello 1: ");
	scanf("%[^\n]", nome_cat_1);
	fflush(stdin);
	if (!strcasecmp(nome_cat_1, "quit")) goto err;

	printf("Categoria Livello 2: ");
	scanf("%[^\n]", nome_cat_2);
	fflush(stdin);
	if (!strcasecmp(nome_cat_2, "quit")) goto err;

// TODO: aggiustare procedure inserisci_categoria in procedures.sql
	printf("Categoria Livello 3: ");
	scanf("%[^\n]", nome_cat_3);
	fflush(stdin);
	if (!strcasecmp(nome_cat_3, "quit")) goto err;

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
		mysql_stmt_close(prepared_stmt);
	}

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
	int cmd;
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
		printf("3) Crea nuova categoria\n");
		printf("4) Nuovo amminastrore\n");
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
			continue;
		}

		if (cmd == 3){
			ins_categoria(conn, header);
			input_wait("Premi un tasto per continuare...");
			continue;
		}

		if (cmd == 4){
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
