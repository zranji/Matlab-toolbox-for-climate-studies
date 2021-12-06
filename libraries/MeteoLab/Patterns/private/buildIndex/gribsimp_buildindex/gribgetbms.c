/*  FILE  :  gribgetbms.c
    Author:  Alice Nakajima, SAIC
    Date  :  June 17, 1996
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "grib.h"               /* GRIB encoder/decoder include file */
extern int debug;	/* for DPRINT */
void gbyte (char *inchar, unsigned long *iout, unsigned long *iskip, 
		unsigned long nbits);


/*
*
*=======================================================================
* A.  FUNCTION:   gribgetbms
*
*     PURPOSE:  decode the Bitmap Section from the GRIB 
*               format and store its info in the BMS structure.
*               Pre-defined Bitmap case is not currently supported;
*     INPUT:
*     char *curr_ptr;    pointer to first octet of BMS
*     BMS_INPUT *bms;    pointer to empty BMS structure
*     int gds_flag;      flag set if GDS is present
*     unsgined long ulGrid_size;  size of grid as in Bds struct
* 
*     RETURN CODE:
*     0>  Always,  
*         BMS info stored in BMS structure if not using pre-defined bitmap;
* =======================================================================
*/
int   gribgetbms (char *curr_ptr, BMS_INPUT *bms, int gds_flag, 
                  unsigned long ulGrid_size)
{
  char *pp;			    /* tmp ptr to bit map */
  int totbits,val, bitpos,stopbit;  /* tmp working vars */
  unsigned long lMessageSize;       /* message and section size */
  unsigned long ulvar;		    /* tmp var */
  long skip=0;

extern void hdr_print();

/*
* A.0      INIT status to no error
*/
int   status=0;

     DPRINT ("Entering gribgetbms():\n");
/* 
*
* A.1      FUNCTION gbyte   !get bitmap length
*/
    skip=0;
    gbyte(curr_ptr,&lMessageSize,&skip,24); 
    DPRINT ("lMessageSize\n");
    bms->uslength= (unsigned short) lMessageSize;

/* 
*
* A.2      FUNCTION gbyte   !get number of unused bits
*/
    gbyte(curr_ptr,&ulvar,&skip,8); 
    DPRINT ("bms->usUnused_bits\n");
    bms->usUnused_bits= (unsigned short) ulvar;

/* 
*
* A.3      FUNCTION gbyte   !get bitmap id (non-zero for a pre-defined bitmap)
*/
    gbyte(curr_ptr,&ulvar,&skip,16); 
    DPRINT ("bms->usBMS_id\n");
    bms->usBMS_id= (unsigned short) ulvar;

/*
*
* A.4      IF (Bitmap follows)   !not a predefined bitmap
*/
    if ( bms->uslength > 6)     /* Bitmap follows */
       {

/* 
* A.4.1       CALCULATE Num of bits in bitmap
*/
         /* = (BMS length)*8 bits - 48 header bits - # of unsused bits */
         totbits=lMessageSize*8 - 48 - bms->usUnused_bits;

/*
* A.4.2       IF (GDS is present AND 
*                      #bits differs from Grid Size)        !Corrupted BMS
*                 RETURN 1
*             ENDIF
*/
          if (gds_flag && (unsigned long)totbits != ulGrid_size) {
	        DPRINT ("exiting gribgetbms() with error status=1\n");
		return (1); /* Corrupted BMS */
		}

/*
* A.4.3       ASSIGN bitmap pointer to 6th byte of BMS
*/
          bms->bit_map =  curr_ptr + 6;
          pp= bms->bit_map; 
          bms->ulbits_set= 0; 
/* 
*
* A.4.4       !SUM up total number of bits set
*             FOR (Each 8-bit block of Total Bits Present in BMS)
*/
          for ( ; totbits > 0 ; totbits-=8) 
          {
/*
* A.4.4.1       IF (any of the 8 bits are set) 
*/
             if ((val=(int)*pp++) != 0) 
               {

/*
* A.4.4.1.1        IF (not within 8 bits of end of bitmap)
*                      SET stopbit to 0
*                  ELSE
*                      SET stopbit to end of bitmap
*                  ENDIF
*/
                 if (totbits > 8) stopbit=0;   /* check all 8 bits */
                 else stopbit= 7-totbits+1;    /* stop at end of bitmap */

/*
* A.4.4.1.2        SUM up number of bits set in this BMS byte
*/
                 for (bitpos= 7; bitpos >= stopbit; bitpos--)
                    if (val >> bitpos & 0x0001) bms->ulbits_set += 1;
/*
* A.4.4.1       ENDIF  ! any of 8 exists
*/
               }
/*
* A.4.4     ENDFOR   !each 8-bit loop
*/
           }
/*
* A.4      ENDIF	!Bitmap follows
*/
	}  

/*  else {
        / * Predefined Bitmap - not supported!! Could add function here 
	    to load a bitmap from local storage * /
         bms->uslength=6;	
         bms->bit_map= Load_predefined_bms (bms->usBMS_id);
       }
*/


/*
*
* A.5     HEADER debug print
*/
     hdr_print ("Bit Map Section", curr_ptr, 6);
     DPRINT ("exiting gribgetbms() with no errors, status 0;\n");
/*
*
* A.6      RETURN status !  always 0
*/
    return (status);
/*
* END OF FUNCTION
*/ }
