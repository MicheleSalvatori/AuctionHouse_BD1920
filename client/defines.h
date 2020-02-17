#include <mysql/mysql.h>
#include <stdbool.h>				// senza bool non è dichiarato, si usa _Bool


extern MYSQL *conn;
extern MYSQL *login;
extern char u[255];
extern char p[255];
extern char c;
extern int cmd1;
extern int cmd2;
extern int num_fields;
extern MYSQL_RES *result;
extern MYSQL_ROW row;
extern MYSQL_FIELD *field;
extern char CF_I[17];
extern char NOME_PISCINA_ADDETTO[50];
extern char query[255];
