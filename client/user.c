#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <mysql/mysql.h>
#include <unistd.h>

#include "defines.h"

#define fflush(stdin) while ((getchar()) != '\n')
#define true 1
#define false 0
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





void run_as_user(MYSQL *conn, char *s){

	if (mysql_change_user(conn,"user", "userPsw", "db_prova")){
		fprintf(stderr, "mysql_change_user() failed\n");
		exit(EXIT_FAILURE);
	}

	
	while(true){
		clearScreen(s);
		printf("1) Visulizza aste aperte\n");
		printf("99) Logout\n");
		printf("Inserisci un comando -> ");
		scanf("%i", &cmd);
		fflush(stdin);

		if (cmd == 1){
			clearScreen(s);
			visualizza_aste_aperte(conn, s);
			input_wait();
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
}