#include <stdio.h>              /* standard I/O header file          */
#include <stdlib.h>
#include <string.h>
#include "grib.h"               /* GRIB encoder/decoder include file */
extern int debug;  /* for dprint */

/*
 * FILE       : gribdec.c
 * PROGRAMMER : Steve Lowe and Todd Kienitz, SAIC Monterey
 * DATE       : February 7, 1996
 * PURPOSE    : Responsible for decoding gridded data that is
 *              received in Gridded Binary (GRIB) edition 1 format.
 *              Function receives as input a pointer to a GRIB message
 *              loaded into memory, and returns all header information
 *              and the decoded data to the calling routine.
 * 
 * RESTRICTIONS:  NONE
 * LANGUAGE:  ANSI C
 * REVISED BY:  Alice Nakajima, SAIC, 1996
 *
 *INCLUDED FILES:
*/


  /* LOW LEVEL SUBROUTINE TO READ BITS FROM MSG */
void gbyte(char *inchar, unsigned long *iout, unsigned long * iskip,
           unsigned long nbyte);

  /* DECODE PRODUCT DEFINITION SECTION */
int gribgetpds(char *curr_ptr, PDS_INPUT *pds);

  /* DECODE GRID DESCRIPTION SECTION */
int gribgetgds(char *curr_ptr, grid_desc_sec *gds);

  /* DECODE BIT MAP DESCRIPTION SECTION */
int gribgetbms(char *curr_ptr, BMS_INPUT *bms, int gds_flag, 
   unsigned long ulGrid_size);

  /* DECODE BINARY DATA SECTION */
int gribgetbds_DOUBLE(char *curr_ptr, double **pgrib_data, short deci_scale,
                struct BDS_HEAD_INPUT *bds_head , 
		grid_desc_sec *gds,  BMS_INPUT *bms);

/*
*
*====================================================================
* A.  FUNCTION: gribdec1()
*     PURPOSE : decode a Gridded Binary (GRIB edition 1) format message
*
*     INPUT   : 
*        *curr_ptr     pointer to 1st byte of GRIB message block
*        *pds          pointer to product definition section structure
*        *gds          pointer to grid description section structure
*        *bds_head     pointer to binary data section header structure
*        *bms	       pointer to bitmap section structure
*        **pgrib_data  pointer to nothing upon entry;  
*                     
*     RETURN CODE:
*        0> Success, **pgrib_data now points to a block containing
*           the BDS bitstream (no header);
*        1> Fail: first 4 bytes of curr_ptr is not 'GRIB'
*        2> Fail: last 4 bytes of curr_ptr is not '7777'
*        3> Fail: not Grib Edition 1
*      1xx> Fail: error from gribgetpds()  <---- NEVER HAPPENS!!!!
*      2xx> Fail: error from gribgetgds()
*      4xx> Fail: error from gribgetbds()
*======================================================================
*/

int gribdec1_DOUBLE(char *curr_ptr, struct PDS_INPUT *pds,
             struct grid_desc_sec *gds, struct BDS_HEAD_INPUT *bds_head, 
             BMS_INPUT *bms, double **pgrib_data)

{
  unsigned long lMessageSize;       /* message and section size */
  long edition;                     /* GRIB edition number */
  int flag;                         /* tests if a condition has happened */
  int gds_flag;			    /* set if Gds present */
  int nReturn = 0;
  unsigned long skip;

/*
*
* A.0     DEBUG printing
*/
 DPRINT ("Entering gribdec1 ()\n");

/*
*
* A.1     IF (incoming pointer is not at 'GRIB') 
*            RETURN 1
*         ENDIF
*/
if(strncmp(curr_ptr,"GRIB",4) != 0) {
  DPRINT ("Exit gribdec1() with status=1\n");
  return(1);   /* GRIB not found */
 }

/*
*
* A.2     FUNCTION gbyte   !get total message length from IDS 
*/
skip=32;
gbyte(curr_ptr,&lMessageSize,&skip,24);
DPRINT ("lMessageSize\n");

/*
*
* A.3     IF (Message does not end with '7777') 
*            RETURN 2
*         ENDIF
*/
if(strncmp((curr_ptr + lMessageSize - 4),"7777",4)!=0) {
  DPRINT ("Exit gribdec1() with status=2\n");
  return(2);
  }

/*
*
* A.4     SET GRIB edition
*         IF (not GRIB edition 1)
*            RETURN 3
*         ENDIF
*/
edition = (long) curr_ptr[7];        /* get edition */
pds->ulMess_Size = lMessageSize;
pds->usEd_num = (unsigned short) edition;
if(edition != 1) {
  DPRINT ("Exit gribdec1() with status=3\n");
  return(3);          /* check the edition, only works for 1 */
  }

/*
*
* A.5     MOVE pointer to the Product Definition section
*/
curr_ptr = curr_ptr + 8;

/* 
*
* A.6     FUNCTION gribgetpds  !decode the PDS 
*         IF (error) THEN
*            RETURN 1xx	!100 + error number
*         ENDIF
*/
if( nReturn=gribgetpds(curr_ptr,pds)) {
  DPRINT ("Exit gribdec1() with status=%d\n",100+nReturn);
  return(100+nReturn); /* exit on error */
  }

/* 
*
* A.7     MOVE pointer to Grid Description section
*/
curr_ptr += pds->uslength;


/*
*
* A.8     IF (GDS is present)
*/
gds_flag = pds->usGds_bms_id >> 7 & 1;
if(gds_flag)  /* grid description section present */
  {
   
/*
* A.8.1      FUNCTION gribgetgds   !decode GDS
*            IF (error) 
*               RETURN 2xx  !200+ error number
*            ENDIF
*/
   if( nReturn=gribgetgds(curr_ptr,gds)) {
	  DPRINT ("Exit gribdec1() with status=%d\n", 200+nReturn);
	  return(200+nReturn);
       }

/* 
* A.8.2      MOVE the cursor to the next section (either BMS/BDS)
*/
   curr_ptr += gds->head.uslength;

/* 
* A.8.3      SET the number of data points depending on Projection
*/
   switch(gds->head.usData_type){
     case 0:    /* Lat/Lon Grid */
     case 4:    /* Gaussian Latitude/Longitude grid */
     case 10:   /* Rotated Lat/Lon */
     case 14:   /* Rotated Gaussian */
     case 20:   /* Stretched Lat/Lon */
     case 24:   /* Stretched Gaussian */
     case 30:   /* Stretched and Rotated Lat/Lon */
     case 34:   /* Stretched and Rotated Gaussian */
       bds_head->ulGrid_size = gds->llg.usNi * gds->llg.usNj;
       break;
     case 1:  /* Mercator Grid */
       bds_head->ulGrid_size = gds->merc.cols * gds->merc.rows; 
       break;
     case 3:  /* Lambert Conformal */
     case 8:  /* Albers equal-area */
     case 13: /* Oblique Lambert Conformal */
       bds_head->ulGrid_size = gds->lam.iNx * gds->lam.iNy; 
       break;
     case 5:  /* Polar Stereographic */
       bds_head->ulGrid_size = gds->pol.usNx * gds->pol.usNy; 
       break;
     }
  }
/*
* A.8     ENDIF (GDS is present)
*/

/*
*
* A.9     IF (bitmap Section is present)
*/
flag = pds->usGds_bms_id >> 6 & 1;
if(flag)  /* bit map section present */
  {
/*
* A.9.1      FUNCTION gribgetbms   !decode BMS
*            IF (error) 
*               RETURN 3xx  !300+ error number
*            ENDIF
*/
   if( nReturn=gribgetbms(curr_ptr,bms,gds_flag, bds_head->ulGrid_size)) 
	{
	  DPRINT ("Exit gribdec1() with status=%d\n", 300+nReturn);
	  return(300+nReturn);
	}

/* 
* A.9.2      MOVE the cursor to beginning of Binary Data Section
*/
     curr_ptr += lMessageSize;

  } /* Bms present */
/*
* A.9     ENDIF  !bms present
*/


/*
*
* A.10    FUNCTION  gribgetbds()
*         IF (error)
*             RETURN 4xx  !400+error num
*         ENDIF
*/
if( nReturn=gribgetbds_DOUBLE(curr_ptr,pgrib_data,pds->sDec_sc_fctr,
    bds_head, gds, bms)) 
    {
	  DPRINT ("Exit gribdec1() with status=%d\n", 400+nReturn);
	  return(400+nReturn);  /* exit on error */
    }

/*
*
* A.11    RETURN 0  !success, pgrib_data has bitstream
*/
 
  DPRINT ("Exit gribdec1() with status=0\n");
  return(0);

}   /* end gribdec */
/*
*
* END OF FUNCTION gribdec()
*
*
*/
