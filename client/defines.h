#include <mysql/mysql.h>
#include <stdbool.h>				// senza bool non è dichiarato, si usa _Bool


extern MYSQL *conn;
extern MYSQL *login;
extern char u[255];
extern char p[255];



// UTILITY
extern void clearScreen(char* s);
extern void input_wait();
extern void print_error (MYSQL *conn, char *message);
extern void print_stmt_error (MYSQL_STMT *stmt, char *message);
extern void finish_with_error(MYSQL *conn, char *message);
extern void finish_with_stmt_error(MYSQL *conn, MYSQL_STMT *stmt, char *message, bool close_stmt);
extern bool setup_prepared_stmt(MYSQL_STMT **stmt, char *statement, MYSQL *conn);
extern void dump_result_set(MYSQL *conn, MYSQL_STMT *stmt, char *title);
// 