/*
*
*
*=========================================================================
* A.  FUNCTION init_struct()
*     PURPOSE:  initializes all structures
*     INPUT:
*       *pds        pointer to product definition section structure
*       *gds        pointer to grid description section structure
*       *bms	    pointer to bitmap section structure
*       *dds_gead   pointer to binary data section header structure 
*     RETURN CODE:  none
*=========================================================================
   NAME:         init_struct 
   DESCRIPTION:  INITIALIZES ALL STRUCTURES
   DATE:         05 FEB 1996
   PROGRAMMER:   STEVE LOWE, SAIC

   Revisions:
   17apr96 A. Nakajima, SAIC : added BMS initialization
   11jun96 A. Nakajima, SAIC: replaced with Memset
*/

#include <stdio.h>
#include <string.h>
#include "grib.h"    /* definition of all GRIB structures */
extern int debug;    /* for dprint*/

void init_struct (PDS_INPUT *pds, grid_desc_sec *gds, BMS_INPUT *bms, 
		BDS_HEAD_INPUT *bds_head)

{

/* 
*
* A.0       DEBUG printing
*/
  DPRINT ("Inside init_struct()\n");

/* 
*
* A.1       INITIALIZE Product Description Section struct elements
*/
  memset ((void *)pds, '\0', sizeof(PDS_INPUT)); 
  pds->usCenter_sub = 999;
  pds->usSecond = 999;
  pds->usParm_sub = 999;

/* 
*
* A.2       INITIALIZE Grid Description Section struct elements
*/
  memset ((void *)gds, '\0', sizeof(grid_desc_sec)); 
  gds->head.usData_type = 255;


/*
*
* A.3       INITIALIZE Bitmap Map Section  header struct elements
*/
  memset ((void *)bms, '\0', sizeof(BMS_INPUT));

/* 
*
* A.4       INITIALIZE Binary Data Section Header Struct elements 
*/
  memset ((void *)bds_head, '\0', sizeof(BDS_HEAD_INPUT));

/* 
*
* A.5       DEBUG printing
*/
  DPRINT ("Leaving init_struct(), no return code\n");


}
/*
* END OF FUNCTION
*/
