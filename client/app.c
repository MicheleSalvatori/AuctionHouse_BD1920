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
int cmd1, cmd2;



int getRole(char* username, char* password){
	MYSQL_STMT *login_procedure;
	MYSQL_BIND param[3];
	int role;

	if(!setup_prepared_stmt(&login_procedure, "call login(?, ?, ?)", conn)) {
		print_stmt_error(login_procedure, "Unable to initialize login statement\n");
		goto failed;
	}

	memset(param, 0, sizeof(param));

	param[0].buffer_type = MYSQL_TYPE_VAR_STRING; // IN
	param[0].buffer = username;
	param[0].buffer_length = strlen(username);

	param[1].buffer_type = MYSQL_TYPE_VAR_STRING; // IN
	param[1].buffer = password;
	param[1].buffer_length = strlen(password);

	param[2].buffer_type = MYSQL_TYPE_LONG; // OUT
	param[2].buffer = &role;
	param[2].buffer_length = sizeof(role);

	if (mysql_stmt_bind_param(login_procedure, param) != 0) {
		print_stmt_error(login_procedure, "Could not bind parameters for login");
		goto err;
	}

	if (mysql_stmt_execute(login_procedure) != 0) {
		print_stmt_error(login_procedure, "Could not execute login procedure");
		goto err;
	}

	memset(param, 0, sizeof(param));
	param[0].buffer_type = MYSQL_TYPE_LONG; // OUT
	param[0].buffer = &role;
	param[0].buffer_length = sizeof(role);

	if(mysql_stmt_bind_result(login_procedure, param)) {
		print_stmt_error(login_procedure, "Could not retrieve output parameter");
		goto err;
	}
	if(mysql_stmt_fetch(login_procedure)) {
		print_stmt_error(login_procedure, "Could not buffer results");
		goto err;
	}
	mysql_stmt_close(login_procedure);
	return role;

	err:
	mysql_stmt_close(login_procedure);
	failed:
	return 99;
}


void registraUtente(){
	char cf[17];
	char nome[16];
	char cognome[16];
	char dNascita[11];
	char cNascita[16];
	char indirizzo[46];
	char citta[16];
	char cardNumber[25];
	char nomeIntestatario[255];
	char cognomeIntestatario[255];
	char cvv[5];
	char pass[255];
	char usr[255];
	char dataScadenza[8];

	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[14];

	if (!setup_prepared_stmt(&prepared_stmt, "call inserisci_utente(?,?,?,?,?,?,?,?,?,?,?,?,?,?)", conn)){
		print_stmt_error(prepared_stmt, "Unable to initialize new_user statement\n");

	}
	clearScreen("Nuovo Utente");

	printf("INSERSICI I SEGUENTI DATI\n");
	printf("Codice Fiscale: ");
	scanf("%s", cf);
	fflush(stdin);

	printf("\nNome: ");
	scanf("%[^\n]", nome);
	fflush(stdin);

	printf("Cognome: ");
	scanf("%[^\n]", cognome);
	fflush(stdin);

	printf("Data di nascita [YYYY/MM/DD]: ");
	scanf("%s", dNascita);
	fflush(stdin);

	printf("Città di nascita: ");
	scanf("%s", cNascita);
	fflush(stdin);

	printf("Indirizzo di consegna: ");
	scanf("%[^\n]", indirizzo);
	fflush(stdin);

	printf("Città: ");
	scanf("%s", citta);
	fflush(stdin);

	printf("Numero carta: ");
	scanf("%s", cardNumber);
	fflush(stdin);

	printf("Data di scadenza [YYYY/MM]: ");
	scanf("%[^\n]", dataScadenza);
	fflush(stdin);

	printf("Nome Intestatario: ");
	scanf("%s", nomeIntestatario);
	fflush(stdin);

	printf("Cognome Intetastatrio: ");
	scanf("%s", cognomeIntestatario);
	fflush(stdin);

	printf("CVV: ");
	scanf("%s", cvv);
	fflush(stdin);

	printf("Username: ");
	scanf("%s", usr);
	fflush(stdin);

	printf("Password: ");
	scanf("%s", pass);
	fflush(stdin);


	memset(param, 0, sizeof(param));
	param[0].buffer_type = MYSQL_TYPE_VAR_STRING; // IN
	param[0].buffer = cf;
	param[0].buffer_length = strlen(cf);

	param[1].buffer_type = MYSQL_TYPE_VAR_STRING; // IN
	param[1].buffer = nome;
	param[1].buffer_length = strlen(nome);

	param[2].buffer_type = MYSQL_TYPE_VAR_STRING; // IN
	param[2].buffer = cognome;
	param[2].buffer_length = strlen(cognome);

	param[3].buffer_type = MYSQL_TYPE_VAR_STRING; // IN
	param[3].buffer = dNascita;
	param[3].buffer_length = strlen(dNascita);

	param[4].buffer_type = MYSQL_TYPE_VAR_STRING; // IN
	param[4].buffer = cNascita;
	param[4].buffer_length = strlen(cNascita);

	param[5].buffer_type = MYSQL_TYPE_VAR_STRING; // IN
	param[5].buffer = indirizzo;
	param[5].buffer_length = strlen(indirizzo);

	param[6].buffer_type = MYSQL_TYPE_VAR_STRING; // IN
	param[6].buffer = citta;
	param[6].buffer_length = strlen(citta);

	param[7].buffer_type = MYSQL_TYPE_VAR_STRING; // IN
	param[7].buffer = cardNumber;
	param[7].buffer_length = strlen(cardNumber);

	param[8].buffer_type = MYSQL_TYPE_VAR_STRING; // IN
	param[8].buffer = dataScadenza;
	param[8].buffer_length = strlen(dataScadenza);

	param[9].buffer_type = MYSQL_TYPE_VAR_STRING; // IN
	param[9].buffer = nomeIntestatario;
	param[9].buffer_length = strlen(nomeIntestatario);

	param[10].buffer_type = MYSQL_TYPE_VAR_STRING; // IN
	param[10].buffer = cognomeIntestatario;
	param[10].buffer_length = strlen(cognomeIntestatario);

	param[11].buffer_type = MYSQL_TYPE_VAR_STRING; // IN
	param[11].buffer = cvv;
	param[11].buffer_length = strlen(cvv);

	param[12].buffer_type = MYSQL_TYPE_VAR_STRING; // IN
	param[12].buffer = pass;
	param[12].buffer_length = strlen(pass);

	param[13].buffer_type = MYSQL_TYPE_VAR_STRING; // IN
	param[13].buffer = usr;
	param[13].buffer_length = strlen(usr);


	if (mysql_stmt_bind_param(prepared_stmt, param) != 0) {
		print_stmt_error(prepared_stmt, "Could not bind parameters for new_user");

	}

	if (mysql_stmt_execute(prepared_stmt) != 0) {
		print_stmt_error(prepared_stmt, "An error occured while create new user. Try again!");

	}else{
		printf("---- Utente registrato correttamente -----");
		input_wait("Premi un tasto per continuare...");
		clearScreen("Riepilogo Dati");
		printf("%s\n", cf);
		printf("%s\n", nome);
		printf("%s\n", cognome);
		printf("%s\n", dNascita);
		printf("%s\n", cNascita);
		printf("%s\n", indirizzo);
		printf("%s\n", citta);
		printf("%s\n", cardNumber);
		printf("%s\n", dataScadenza);
		printf("%s\n", nomeIntestatario);
		printf("%s\n", cognomeIntestatario);
		printf("%s\n", cvv);
		printf("%s\n", usr);
		printf("%s\n", pass);
	}
	mysql_stmt_close(prepared_stmt);

}



int main (int argc, char *argv[]) {
	// clearScreen("Aste Online");
	conn = mysql_init(NULL);
	if (conn == NULL){
		fprintf(stderr, "Errore conn\n");
	}

	login = mysql_real_connect(conn, "localhost" ,"login", "loginUser", "db_prova", 3306, NULL, 0);				// prova

		if (login == NULL) {
		fprintf(stderr, "%s\n", mysql_error(conn));
		mysql_close(conn);
		exit(1);
	}
	//
	// while (1) {
	// 	clearScreen("Aste Online");
	// printf("	1) Accedi\n");
	// printf("	2) Registra Nuovo Utente\n");
	// printf("	99) Termina\n");
	// printf("\nInserisci comando > ");
	// scanf("%i", &cmd1);
	// fflush(stdin);
	//
	// if(cmd1 == 99){
	// 		printf("-- Bye --\n");
	// 		exit(1);
	//
	// }else if(cmd1 == 1){
	//
	// 		clearScreen("LOGIN");
	//
	// 		printf("Inserisci username: \n> ");
	// 		scanf("%s", u);
	// 		fflush(stdin);
	// 		printf("Inserisci password: \n> ");
	// 		scanf("%s", p);
	// 		fflush(stdin);
	// 		printf("\n\n");
	//
	// 		int role = getRole(u,p);
	//
	// 		switch(role){
	//
	// 			case 1:
	// 				run_as_admin(conn, u);
	//
	// 				if (mysql_change_user(conn,"login", "loginUser", "db_prova")){
	// 					fprintf(stderr, "mysql_change_user() failed\n");
	// 					input_wait("Premi un tasto per continuare...");
	// 					exit(EXIT_FAILURE);
	// 					}
	// 				break;
	//
	// 			case 0:
	// 				run_as_user(conn, u);
	//
	// 				if (mysql_change_user(conn,"login", "loginUser", "db_prova")){
	// 					fprintf(stderr, "mysql_change_user() failed\n");
	// 					input_wait("Premi un tasto per continuare...");
	// 					exit(EXIT_FAILURE);
	// 					}
	// 				break;
	//
	// 			case 99:
	// 				printf("Invalid credentials\nFAILED LOGIN\n");
	// 				input_wait();
	// 				break;
	// 		}
	//
	//
	//
	// }else if (cmd1 ==2){
	// 		registraUtente();
	// 		input_wait("Premi un tasto per continuare...");
	// 		break;					// meglio mettere inputWait
	// }else{
	// 		printf("\n-- Comando non presente\n\n");
	// 		input_wait("Premi un tasto per continuare...");
	// 	}
	// 	}
		// run_as_user(conn, "utenteProva");
		run_as_admin(conn, "michele.salvatori");


// chiudere conn ?

}

// TODO Quando un amminastrore aggiunge un nuovo oggetto come passiamo il tipo di oggetto? Dovrebbe scriverlo lui da client (toLowerCase() ??)
// con nuova procedura che mostra tutti i tipi di oggetti
