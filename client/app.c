#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <mysql/mysql.h>
#include <unistd.h>

#include "defines.h"

#define fflush(stdin) while ((getchar()) != '\n')
#define true 1
#define false 0

MYSQL *conn;
MYSQL *login;
char u[255];
char p[255];
char c;
int cmd1 = 0;
char query[255];


void finish_with_error(MYSQL *con, char *err) {
	fprintf(stderr, "%s error: %s\n", err, mysql_error(con));
	mysql_close(con);
	exit(1);
}



void input_wait() {
	char c;
	printf("\nINFO: Premi invio per continuare: \n");
	while (c = getchar() != '\n'){}
}

void run_sql_query (char *query) {
	printf("QUERY: %s \n",query);
	if(mysql_query(conn,query)) {
		finish_with_error(conn, "Query");
	} else {
		
		input_wait();
	}
}



void login_procedure () {

	char nome_cat[25];
	int livello;


	printf("\n---- LOGIN_prova ----\n\n");
	printf("> Inserisci l'username: ");
	scanf("%s",u);
	printf("> Inserisci la password: ");
	scanf("%s",p);
	printf("\n\n");

	conn = mysql_init(NULL);
	login = mysql_real_connect(conn, "localhost",u,NULL, "auction_house", 3306, NULL, 0);		// ho messo momentaneamente la password NULL

		if (login == NULL) {
		fprintf(stderr, "%s\n", mysql_error(conn));
		mysql_close(conn);
		exit(1);

	} else {
		printf ("\n ---- Connessione Riuscita ----\n");


		printf("Inserisci nome della categoria: ");
		scanf("%s", nome_cat);
		fflush(stdin);
		printf("Inserisci livello [1/2/3]: ");
		scanf("%d", &livello);
		fflush(stdin);

		snprintf(query, 1000, "call inserisci_categoria('%s', '%d')", nome_cat, livello);
		run_sql_query(query);
	}

	mysql_close(conn);
	exit(0);
}



int main (int argc, char *argv[]) {
	while (1) {
		printf("--- Client_prova ---\n\n");
		printf("  1) Login\n");
		printf("  99) Termina\n\n");
		printf("> Inserisci un Comando: ");
		scanf ("%i",&cmd1);
		fflush(stdin);
		if (cmd1 == 1) {
			login_procedure();
		} else if (cmd1 == 99) {
			printf("\nINFO: Uscita...Bye\n");
			exit(0);
		} 
	}
}