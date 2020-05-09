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

void run_as_admin(MYSQL *conn, char *s){

	if (mysql_change_user(conn,"admin", "admin", "db_prova")){
		fprintf(stderr, "mysql_change_user() failed\n");
		exit(EXIT_FAILURE);
	}

	char header[256];
	sprintf(header, "Admin: %s", s);
	
	while(true){
		clearScreen(header);
		printf("1) Visulizza aste aperte\n");
		printf("2) Inserisci nuova asta\n");
		printf("3) Inserisci Oggetto\n");
		printf("4) Crea nuova categoria\n");
		printf("99) Logout\n");
		printf("Inserisci un comando -> ");
		scanf("%i", &cmd);
		fflush(stdin);

		if (cmd == 1){
			visualizza_aste_aperte(conn, header);
			input_wait();
			continue;
		}

		if (cmd == 2){
			nuova_asta(conn);
			input_wait();
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