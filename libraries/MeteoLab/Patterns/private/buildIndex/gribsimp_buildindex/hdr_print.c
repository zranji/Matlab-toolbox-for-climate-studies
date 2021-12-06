#include <stdio.h>
#include "grib.h"
extern int debug;

/*
* 
* ==============================================================
* A.  FUNCTION  hdr_print
*     PURPOSE:  print specified number of bytes  of a block
*     INPUT:  
*       char *title     Title to print
*       char *block     HOlds data to print
*       int bytes toprint  #bytes to print
*     RETURN:  nothing
*===============================================================
*/
void  hdr_print (char *title, unsigned char *block, int bytestoprint)
{
int i=0;

/*
* A.1       IF (debug is off) THEN
*               RETURN
*           ENDIF
*/
   if (!debug) return;

/*
*
* A.2       PRINT title string
*/
   printf("hdr_print %d bytes of '%s'=", bytestoprint, title);

/*
* 
* A.3       WHILE (more bytes to print) DO
*                PRINT byte value
*           ENDDO
*/
   while (i < bytestoprint)
    {
	if (i % 8 == 0) {
	   if (i+7>= bytestoprint-1)
		printf("\n[%2d-%2d]:  ",i+1, bytestoprint);
      	   else printf("\n[%2d-%2d]:  ",i+1, i+8);
	}
	printf("%03u ", block[i++]);
	if (i % 4 == 0) printf("| ");
    }
   printf("\n");

   DPRINT ("Exiting hdr_print(), no return code\n");
/*
* END OF FUNCTION
*/ }
