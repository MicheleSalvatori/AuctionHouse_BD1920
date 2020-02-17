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


void print_stmt_error (MYSQL_STMT *stmt, char *message)
{
	fprintf (stderr, "%s\n", message);
	if (stmt != NULL) {
		fprintf (stderr, "Error %u (%s): %s\n",
			mysql_stmt_errno (stmt),
			mysql_stmt_sqlstate(stmt),
			mysql_stmt_error (stmt));
	}
}


void print_error(MYSQL *conn, char *message)
{
	fprintf (stderr, "%s\n", message);
	if (conn != NULL) {
		#if MYSQL_VERSION_ID >= 40101
		fprintf (stderr, "Error %u (%s): %s\n",
		mysql_errno (conn), mysql_sqlstate(conn), mysql_error (conn));
		#else
		fprintf (stderr, "Error %u: %s\n",
		mysql_errno (conn), mysql_error (conn));
		#endif
	}
}

void finish_with_stmt_error(MYSQL *conn, MYSQL_STMT *stmt, char *message, bool close_stmt)
{
	print_stmt_error(stmt, message);
	if(close_stmt) 	mysql_stmt_close(stmt);
	mysql_close(conn);
	exit(EXIT_FAILURE);        
}

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

void query_metodo_1(){

	char nome_cat[25];
	int livello;
	printf("---- Nuova Categoria ----\n\n\n");
	printf("Inserisci nome della categoria: ");
	scanf("%s", nome_cat);
	fflush(stdin);
	printf("Inserisci livello [1/2/3]: ");
	scanf("%d", &livello);
	fflush(stdin);

	snprintf(query, 1000, "call inserisci_categoria('%s', '%d')", nome_cat, livello);
	run_sql_query(query);
}

bool setup_prepared_stmt(MYSQL_STMT **stmt, char *statement, MYSQL *conn)
{
	my_bool update_length = true;

	*stmt = mysql_stmt_init(conn);
	if (*stmt == NULL)
	{
		print_error(conn, "Could not initialize statement handler");
		return false;
	}

	if (mysql_stmt_prepare (*stmt, statement, strlen(statement)) != 0) {
		print_stmt_error(*stmt, "Could not prepare statement");
		return false;
	}

	mysql_stmt_attr_set(*stmt, STMT_ATTR_UPDATE_MAX_LENGTH, &update_length);

	return true;
}

void query_prepared_stm(){
	printf("\033[2J\033[H");		// pulisce terminale e posiziona il cursore in alto a sinistra
									// http://ascii-table.com/ansi-escape-sequences.php
	char nome_cat[25];				// 033 = \ in octal numbers, [2J = erase display, [H posizione cursore
	int livello;

	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[2];

	if(!setup_prepared_stmt(&prepared_stmt, "call inserisci_categoria(?,?)", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize exam list statement\n", false);
	}
	printf("---- Nuova Categoria ----\n\n");	
	printf("Inserisci nome della categoria: ");
	scanf("%s", nome_cat);
	fflush(stdin);
	printf("Inserisci livello [1/2/3]: ");
	scanf("%d", &livello);
	fflush(stdin);


	// Prepare parameters
	memset(param, 0, sizeof(param));
	
	param[0].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[0].buffer = nome_cat;
	param[0].buffer_length = strlen(nome_cat);

	param[1].buffer_type = MYSQL_TYPE_LONG;
	param[1].buffer = &livello;
	//param[0].buffer_length = strlen(livello);
	

	if (mysql_stmt_bind_param(prepared_stmt, param) != 0) {
		finish_with_stmt_error(conn, prepared_stmt, "Could not bind parameters for exam list\n", true);
	}

	// Run procedure
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		print_stmt_error (prepared_stmt, "An error occurred while registering the exam.");
	} else {
		printf("Categoria inserita correttamente...\n");
	}

	mysql_stmt_close(prepared_stmt);

	input_wait();

}


void login_procedure () {

	
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


		query_prepared_stm(); 
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
		switch(cmd1){

			case 1:
				login_procedure();
				break;

			case 2:
				printf("\nINFO: Uscita...Bye\n");
				exit(0);
		}
	}
	
}