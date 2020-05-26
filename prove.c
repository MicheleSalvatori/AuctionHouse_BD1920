#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <mysql/mysql.h>


int main(){
  MYSQL_TIME ts;
  char buffer[9];

  printf("DAY: ");
  scanf("%d",&(ts.day));
  printf("HOUR: ");
  scanf("%d",&(ts.hour));
  printf("MINUTE: ");
  scanf("%d",&(ts.minute) );

  sprintf(buffer, "%02d:%02d:%02d", ts.day, ts.hour, ts.minute);
  printf("%s %d\n", buffer, strlen(buffer));
}
