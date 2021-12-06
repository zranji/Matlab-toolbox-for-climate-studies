#include <stdio.h>
#include "grib.h"

#define NBITSW 32

extern int debug;
/*
*
* ================================================================
* A.  FUNCTION gbyte
*     PURPOSE:  called to extract data of specified length from
*               specified offset from a block of type char;
*/
void gbyte (char *inchar, unsigned long *iout, unsigned long *iskip, 
		unsigned long nbits)
/* inchar is the current block */
{
/*
  ADAPTED FROM THE ORIGINAL FORTRAN VERSION OF GBYTE BY:
 
              DR. ROBERT C. GAMMILL, CONSULTANT
              NATIONAL CENTER FOR ATMOSPHERIC RESEARCH
              MAY 1972
 
              CHANGES FOR FORTRAN 90
              AUGUST 1990  RUSSELL E. JONES
              NATIONAL WEATHER SERVICE
              GBYTE RUN WITHOUT CHANGES ON THE FOLLOWING COMPILERS
              MICROSOFT FORTRAN 5.0 OPTIMIZING COMPILER
              SVS 32 386 FORTRAN 77 VERSION V2.8.1B
              SUN FORTRAN 1.3, 1.4
              DEC VAX FORTRAN
              SILICONGRAPHICS 3.3, 3.4 FORTRAN 77
              IBM370 VS COMPILER
              INTERGRAPH GREEN HILLS FORTRAN CLIPPER 1.8.4B
*
*     INPUT:
*       *inchar   THE FULLWORD IN MEMORY FROM WHICH UNPACKING IS TO
*                 BEGIN, SUCCESSIVE FULLWORDS WILL BE FETCHED AS
*                 REQUIRED.
*       *iskip    A FULLWORD INTEGER SPECIFYING THE INITAL OFFSET
*                 IN BITS OF THE FIRST BYTE, COUNTED FROM THE
*                 LEFTMOST BIT IN PCKD.  GETS BUMPED AT UPON EXIT;
*       nbits     A FULLWORD INTEGER SPECIFYING THE NUMBER OF BITS
*                 IN EACH BYTE TO BE UNPACKED.  LEGAL BYTE WIDTHS
*                 ARE IN THE RANGE 1 - 32, BYTES OF WIDTH .LT. 32
*                 WILL BE RIGHT JUSTIFIED IN THE LOW-ORDER POSITIONS
*                 OF THE UNPK FULLWORDS, WITH HIGH-ORDER ZERO FILL.
*
*     OUTPUT ARGUMENT LIST:
*       *iout     THE FULLWORD IN MEMORY INTO WHICH THE INITIAL BYTE
*                 OF UNPACKED DATA IS TO BE STORED.
* ================================================================
*
*/
   long masks[32];
   long	icon,index,ii,mover,movel;
   unsigned long temp, mask, inlong;


/*
* A.1      INITIALIZE mask possibilities of all bits set from LSB to
*          a particular bit position;  !bit position range: 0 to 31
*/
   masks[0] = 1; 
   masks[1] = 3;
   masks[2] = 7;
   masks[3] = 15; 
   masks[4] = 31;
   masks[5] = 63;
   masks[6] = 127;
   masks[7] = 255;
   masks[8] = 511;
   masks[9] = 1023;
   masks[10] = 2047;
   masks[11] = 4095;
   masks[12] = 8191;
   masks[13] = 16383;
   masks[14] = 32767;
   masks[15] = 65535;
   masks[16] = 131071;
   masks[17] = 262143;
   masks[18] = 524287;
   masks[19] = 1048575; 
   masks[20] = 2097151; 
   masks[21] = 4194303;
   masks[22] = 8388607; 
   masks[23] = 16777215;
   masks[24] = 33554431;
   masks[25] = 67108863;
   masks[26] = 134217727;
   masks[27] = 268435455; 
   masks[28] = 536870911; 
   masks[29] = 1073741823;
   masks[30] = 2147483647;
   masks[31] = -1;

/* NBYTE MUST BE LESS THAN OR EQUAL TO NBITSW
*
* A.2      IF (trying to retrieve more than 32 bits) THEN
*              RETURN
*          ENDIF
*/
   icon = NBITSW - nbits;
   if ( icon < 0 )
   {
      return;
   }
/*
*
* A.3      SET up mask needed for specified #bits to retrieve
*/
   mask = masks[nbits-1];
/*
*
* A.4      CALCULATE Index !Byte offset from 'inchar' where retrieval begins
*/
   index = *iskip / NBITSW;
/*
*
* A.5      CALCULATE Bit position within byte Index where retrieval begins
*/
   ii = *iskip % NBITSW;

/*
*
* A.6      CALCULATE #times to Right-shift the retrieved data so it 
*          is right adjusted
*/
   mover = icon - ii;

/*
*
* A.7.a    IF (need to right-adjust the byte) THEN
*/
   if ( mover > 0 )
   {

/*
* A.7.a.1     RETRIEVE 4 continuous byte from offset Index in block
*/
     {
       unsigned long l0, l1, l2, l3;
       l0 = (unsigned long)inchar[index*4] << 24;
       l1 = (unsigned long)(0x000000FF & inchar[index*4+1 ]) << 16;
       l2 = (unsigned long)(0x000000FF & inchar[index*4+2 ]) << 8;
       l3 = (unsigned long)(0x000000FF & inchar[index*4+3 ]);
       inlong = l0 + l1 + l2 + l3;
     }
/*
* A.7.a.2     RIGHT adjust this value
*/
     *iout = inlong >> mover;
/*
* A.7.a.3     MASK out the bits wanted only    !result in *out
*/
     *iout = (*iout & mask);
   } /* If */


/*
* A.7.b    ELSE IF (byte is split across a word break) THEN
*/
   else if ( mover < 0 )
   {
/*
*             !
*             !Get the valid bits out of the FIRST WORD
*             !
* A.7.b.1     CALCULATE #times to move retrieve data left so
*             the 1st significant bit aligns with MSB of word
* A.7.b.2     CALCULATE #times to move data that's aligned 
*             with MSB so that it aligns with LSB of word
*/
      movel = -mover;
      mover = NBITSW - movel;

/*
* A.7.b.3     RETRIEVE 4-byte word from offset Index from block
*/
     {
       unsigned long l0, l1, l2, l3;
       l0 = (unsigned long)(0x000000FF & inchar[index*4]) << 24;
       l1 = (unsigned long)(0x000000FF & inchar[index*4+1 ]) << 16;
       l2 = (unsigned long)(0x000000FF & inchar[index*4+2 ]) << 8;
       l3 = (unsigned long)(0x000000FF & inchar[index*4+3 ]);
       inlong = l0 + l1 + l2 + l3;
     }
/*
* A.7.b.4     SHIFT retrieve this data all the way left !Left portion
*/

/*
*             !
*             !Now Get the valid bits out of the SECOND WORD
*             !
* A.7.b.5     RETRIEVE the next 4-byte word from block
*/
      *iout = inlong << movel;
     {
       unsigned long l0, l1, l2, l3;
       l0 = (unsigned long)(0x000000FF & inchar[index*4+4]) << 24;
       l1 = (unsigned long)(0x000000FF & inchar[index*4+5 ]) << 16;
       l2 = (unsigned long)(0x000000FF & inchar[index*4+6 ]) << 8;
       l3 = (unsigned long)(0x000000FF & inchar[index*4+7 ]);
       inlong = l0 + l1 + l2 + l3;
     }
/* 
* A.7.b.6     SHIFT this data all the way right   !Right portion
* A.7.b.7     OR the Left portion and Right portion together
* A.7.b.8     MASK out the #bits wanted only     !result in *iout
*/
      temp  = inlong >> mover;
      *iout = *iout|temp;
      *iout &= mask;
/*
  THE BYTE IS ALREADY RIGHT ADJUSTED.
*/
   }
   else
/*
* A.7.c    ELSE    !the byte is already adjusted, no shifts needed
*/
   {
/*
* A.7.c.1     RETRIEVE the next 4-byte word from block
*/
     {
       unsigned long l0, l1, l2, l3;
       l0 = (unsigned long)(0x000000FF & inchar[index*4]) << 24;
       l1 = (unsigned long)(0x000000FF & inchar[index*4+1 ]) << 16;
       l2 = (unsigned long)(0x000000FF & inchar[index*4+2 ]) << 8;
       l3 = (unsigned long)(0x000000FF & inchar[index*4+3 ]);
       inlong = l0 + l1 + l2 + l3;
     }
/*
* A.7.c.2     MASK out the bits wanted only    !result in *out
*/
      *iout = inlong&mask;
   }
/*
* A.7.c    ENDIF    !the byte is already adjusted
*/

/*
*
* A.8      DEBUG printing
*/
  DPRINT ("gbyte(skip=%d %d bits)= %lu stored as ",
          *iskip, nbits, *iout);
/*
*
* A.9      BUMP pointer up
*/
	*iskip += nbits;
}
/* 
* END OF FUNCTION
*
*/
