/* Program    : Error printing
   Programmer : Steve Lowe, SAIC
   Date       : February 5, 1996
   Purpose    : Print Error message for return code from gribdec
*/

#include <stdio.h>
#include "grib.h"
extern int debug;  /* for dprint */

/*
*
*
*===================================================================
* A.  FUNCTION:  prt_err
*     PURPOSE : Print error message for return code from gribdec1();
*     INPUT:    int errnum
*     RETURN CODE:  none
*/
void prt_err(int errnum)
{

/*
*
* A.1     SWITCH (errornum)
*            PRINT apropriate message for the specified errornum
*         ENDSWITCH
*/
  DPRINT ("Entering prt_err()\n");
  fprintf(stderr,"\nError in function gribdec1.  Return code = %d\n\n",errnum);
  switch (errnum) {
     case 1:
       fprintf(stderr,"***************************************************\n");
       fprintf(stderr,"* 1: 'GRIB' string not found at pointer location. *\n");
       fprintf(stderr,"***************************************************\n");
       break;
     case 2:
       fprintf(stderr,"*************************************************\n");
       fprintf(stderr,"* 2: '7777' string not found at end of message. *\n");
       fprintf(stderr,"*************************************************\n");
       break;
     case 3:
       fprintf(stderr,"************************************************\n");
       fprintf(stderr,"* 3: Message not encoded using GRIB edition 1. *\n");
       fprintf(stderr,"************************************************\n");
       break;
     case 101:
       fprintf(stderr,"***********************************************\n");
       fprintf(stderr,"* 101: Error decoding PDS section of message. *\n");
       fprintf(stderr,"***********************************************\n");
       break;
     case 201:
       fprintf(stderr,"************************************************\n");
       fprintf(stderr,"* 201: Data representation type not supported. *\n");
       fprintf(stderr,"************************************************\n");
       break;
     case 301:
       fprintf(stderr,"**************************************************\n");
       fprintf(stderr,"* 301: Bitmap size does not match GDS grid size. *\n");
       fprintf(stderr,"**************************************************\n");
       break;
     case 401:
       fprintf(stderr,"*******************************************\n");
       fprintf(stderr,"* 401: Data packing method not supported. *\n");
       fprintf(stderr,"*******************************************\n");
       break;
     case 402:
       fprintf(stderr,"************************************************\n");
       fprintf(stderr,"* 402: Number of data points in bitstream does *\n");
       fprintf(stderr,"*      not match number specified in the bitmap*\n");
       fprintf(stderr,"************************************************\n");
       break;
     case 403:
       fprintf(stderr,"************************************************\n");
       fprintf(stderr,"* 403: Number of data points in bitstream does *\n");
       fprintf(stderr,"*      not match number specified in GDS.      *\n");
       fprintf(stderr,"************************************************\n");
       break;
     default:
       fprintf(stderr,"***********************************************\n");
       fprintf(stderr,"* CODE NOT DEFINED; IN GENERAL:               *\n");
       fprintf(stderr,"*   < 100  => Error in main function gribdec1 *\n");
       fprintf(stderr,"*   100 's => Error in function gribgetpds    *\n");
       fprintf(stderr,"*   200 's => Error in function gribgetgds    *\n");
       fprintf(stderr,"*   300 's => Error related to bit map        *\n");
       fprintf(stderr,"*   400 's => Error in function gribgetbds    *\n");
       fprintf(stderr,"*  1000 's => Error in function apply_bitmap  *\n");
       fprintf(stderr,"***********************************************\n");
       break;
  }

  DPRINT ("Exiting prt_err(), no return code\n");
/*
*
* END OF FUNCTION
*/ }
