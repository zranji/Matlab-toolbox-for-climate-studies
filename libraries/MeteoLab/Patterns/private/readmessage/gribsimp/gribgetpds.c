#include <stdio.h>
#include <string.h>
#include "grib.h"
extern int debug;	/* for DPRINT */
void gbyte (char *inchar, unsigned long *iout, unsigned long *iskip, 
		unsigned long nbits);

int gribgetpds(char *curr_ptr, PDS_INPUT *pds)

/*
  IDENTIFICATION:
       gribgetpds - decode the Product Definition Section PDS
  
  REVISION/MODIFICATION HISTORY:
       03/07/94 written by Mugur Georgescu CSC, Monterey CA
       02/01/96 modified by Steve Lowe SAIC, Monterey CA
       06/18/96 modified by Alice Nakajima SAIC, Monterey CA 
  RESTRICTIONS: NONE
  LANGUAGE: ANSI C
  INCLUDED FILES:
*/

/*
*
* =======================================================================
* A.  FUNCTION  gribgetpds()
*     PURPOSE:  decodes the Product Definition Section from the GRIB 
*               format and store its info in the PDS structure.
*     INPUT:
*     char *curr_ptr;    pointer to first octet of PDS
*     PDS_INPUT *pds;    pointer to empty PDS structure
* 
*     RETURN CODE:
*     0>  Always,  PDS info stored in Pds structure;
* =======================================================================
*/
{
char *in = curr_ptr;      /* pointer to the message */
long skip=0;              /* bits to be skipped */
unsigned long something;  /* value extracted from message */
int sign;                 /* sign + or - */
extern void hdr_print();

 DPRINT ("Entering gribgetpds()\n");

/*
* A.1       FUNCTION gbyte !3-byte PDS length
*/
 gbyte(in,&something,&skip,24); 
 DPRINT ("pds->uslength\n");
 pds->uslength = (unsigned short) something;       

/*
*
* A.2       FUNCTION gbyte !parameter table version
*/
 gbyte(in,&something,&skip,8); 
 DPRINT ("pds->usParm_tbl\n");
 pds->usParm_tbl = (unsigned short) something;     

/*
*
* A.3       FUNCTION gbyte !center identification
*/
 gbyte(in,&something,&skip,8); 
 DPRINT ("pds->usCenter_id\n");
 pds->usCenter_id = (unsigned short) something;    

/*
*
* A.4       FUNCTION gbyte !generating process id
*/
 gbyte(in,&something,&skip,8); 
 DPRINT ("pds->usProc_id\n");
 pds->usProc_id = (unsigned short) something;      

/*
*
* A.5       FUNCTION gbyte !grid identification
*/
 gbyte(in,&something,&skip,8); 
 DPRINT ("pds->usGrid_id\n");
 pds->usGrid_id = (unsigned short) something;      

/*
*
* A.6       FUNCTION gbyte !flag of GDS, BMS presence
*/
 gbyte(in,&something,&skip,8); 
 DPRINT ("pds->usGds_bms_id\n");
 pds->usGds_bms_id = (unsigned short) something;   

/*
*
* A.7       FUNCTION gbyte !parameter indicator and units 
*/
 gbyte(in,&something,&skip,8); 
 DPRINT ("pds->usParm_id\n");
 pds->usParm_id = (unsigned short) something;      

/*
*
* A.8       FUNCTION gbyte !level type indicator
*/
 gbyte(in,&something,&skip,8); 
 DPRINT ("pds->usLevel_id\n");
 pds->usLevel_id = (unsigned short) something;  

 /* switch on Level_id to determine if level or layer */
/*
*
* A.9       SWITCH (level_id)
*/
 switch(pds->usLevel_id)
    {
    case 101: /* layer between two isobaric surfaces */
    case 104: /* layer between two specified altitudes */
    case 106: /* layer between two specified height levels above ground */
    case 108: /* layer between two sigma levels */
    case 110: /* layer between two hybrid levels */
    case 112: /* layer between two depths below land surface */
    case 114: /* layer between two isentropic levels */
    case 121: /* layer between two isobaric surfaces (high precision) */
    case 128: /* layer between two sigma levels (high precision) */
    case 141: /* layer between two isobaric surfaces (mixed precision) */
/*
*              layer:
*                 FUNCTION gbyte !top of layer
*                 FUNCTION gbyte !bottom of layer
*/
       gbyte(in,&something,&skip,8);
       DPRINT ("pds->usHeight1\n");
       pds->usHeight1 = (unsigned short) something;  /* top layer */
       gbyte(in,&something,&skip,8);
       DPRINT ("pds->usHeight2\n");
       pds->usHeight2 = (unsigned short) something;  /* bottom layer */
       break;

    default:  /* all others (levels) */
/*
*              default:  !assume a level
*                 FUNCTION gbyte !level value
*                 SET Height2 to ZERO
*/
       gbyte(in,&something,&skip,16);
      DPRINT ("pds->usHeight1\n");
       pds->usHeight1 = (unsigned short) something;
       pds->usHeight2 = 0;                
       break;
    }
/*
* A.9       ENDSWITCH
*/

/*
*
* A.10      FUNCTION gbyte !year of Reference Data/Time
*/
 gbyte(in,&something,&skip,8); 
 DPRINT ("pds->usYear\n");
 pds->usYear = (unsigned short) something;   

/*
*
* A.11      FUNCTION gbyte !month of Reference Data/Time
*/
 gbyte(in,&something,&skip,8); 
 DPRINT ("pds->usMonth\n");
 pds->usMonth = (unsigned short) something;   

/*
*
* A.12      FUNCTION gbyte !day of Reference Data/Time
*/
 gbyte(in,&something,&skip,8); 
 DPRINT ("pds->usDay\n");
 pds->usDay = (unsigned short) something;      

/*
*
* A.13      FUNCTION gbyte !hour of Reference Data/Time
*/
 gbyte(in,&something,&skip,8); 
 DPRINT ("pds->usHour\n");
 pds->usHour = (unsigned short) something;      

/*
*
* A.14      FUNCTION gbyte !minute of Reference Data/Time
*/
 gbyte(in,&something,&skip,8); 
 DPRINT ("pds->usMinute\n");
 pds->usMinute = (unsigned short) something;     

/*
*
* A.15      FUNCTION gbyte !forecast time unit
*/
 gbyte(in,&something,&skip,8); 
 DPRINT ("pds->usFcst_unit_id\n");
 pds->usFcst_unit_id = (unsigned short) something;

/*
*
* A.16      FUNCTION gbyte !forecast period 1
*/
 gbyte(in,&something,&skip,8); 
 DPRINT ("pds->usP1\n");
 pds->usP1 = (unsigned short) something;         

/*
*
* A.17      FUNCTION gbyte !forecast period 2
*/
 gbyte(in,&something,&skip,8); 
 DPRINT ("pds->usP2\n");
 pds->usP2 = (unsigned short) something;          

/*
*
* A.18      FUNCTION gbyte !time range indicator
*/
 gbyte(in,&something,&skip,8); 
 DPRINT ("pds->usTime_range\n");
 pds->usTime_range = (unsigned short) something;   

/*
*
* A.19      FUNCTION gbyte !#included in average
*/
 gbyte(in,&something,&skip,16); 
 DPRINT ("pds->usTime_range_avg\n");
 pds->usTime_range_avg = (unsigned short) something;

/*
*
* A.20      FUNCTION gbyte !#missing from average
*/
 gbyte(in,&something,&skip,8); 
 DPRINT ("pds->usTime_range_mis\n");
 pds->usTime_range_mis = (unsigned short) something;

/*
*
* A.21      FUNCTION gbyte !century of Reference Data/Time
*/
 gbyte(in,&something,&skip,8); 
 DPRINT ("pds->usCentury\n");
 pds->usCentury = (unsigned short) something;  

/*
*
* A.22      FUNCTION gbyte !reserved field
*/
 gbyte(in,&something,&skip,8); 
 DPRINT ("pds->usZero\n");
 pds->usZero = (unsigned short) something;      

/*
*
* A.23      FUNCTION gbyte !decimal scale factor
*/
 gbyte(in,&something,&skip,16); 
      DPRINT ("Sign & pds->sDec_sc_fctr\n");
 sign = (int)(something >> 15) & 1;                /* sign bit*/
 pds->sDec_sc_fctr = (short) (something) & 32767;  /* Decimal sclfctr D */
 if(sign)                                          /* negative Dec. sclfctr*/
    pds->sDec_sc_fctr = - pds->sDec_sc_fctr;       /* multiply by -1 */

/* 
*
* A.24      IF (more than 40 bytes in PDS) THEN
*              INCREMENT #bits to &skip !skip reserved octets 29-40
*              FUNCTION gbyte !originating sub-center
*           ENDIF
*/

 if(pds->uslength > 40){
    skip += 96;                                  
    gbyte(in,&something,&skip,8);
    DPRINT ("pds->usCenter_sub\n");
    pds->usCenter_sub = (unsigned short) something;
 }

/*
* 
* A.25      IF (NRL/MRY GRIB extensions) THEN
*/
 if((pds->usCenter_sub==99)||(pds->usCenter_id==128)||(pds->usCenter_id==129)) {

/*
*
* A.25.1       IF (more than 41 bytes in PDS) THEN
*                 FUNCTION gbyte !seconds of Reference Data/Time
*              ENDIF
*/
    if(pds->uslength >= 42){
      gbyte(in,&something,&skip,8);
      DPRINT ("pds->usSecond\n");
      pds->usSecond = (unsigned short) something;  
    }
/*
*
* A.25.2       IF (more than 43 bytes in PDS) THEN
*                 FUNCTION gbyte !Tracking ID
*              ENDIF
*/
    if(pds->uslength >= 44){
      gbyte(in,&something,&skip,16);
      DPRINT ("pds->usTrack_num\n");
      pds->usTrack_num = (unsigned short) something;
    }
/*
*
* A.25.3       IF (more than 44 bytes in PDS) THEN
*                 IF (it's a Sub-Table) THEN
*                     FUNCTION gbyte ! Parameter Sub-table entry
*                 ENDIF
*              ENDIF
*/
    if(pds->uslength >= 45){
      if (pds->usParm_id > 249)
	{
          gbyte(in,&something,&skip,8);
          DPRINT ("pds->usParm_sub\n");
          pds->usParm_sub = (unsigned short) something;  
	}
      else skip += 8;
    }
/*
*
* A.25.4       IF (more than 45 bytes in PDS) THEN
*                 FUNCTION gbyte ! Local table version number
*              ENDIF
*/
    if(pds->uslength >= 46){
      gbyte(in,&something,&skip,8);
      DPRINT ("pds->usSub_tbl\n");
      pds->usSub_tbl = (unsigned short) something;    
    }

/*
* A.25      ENDIF   !NRL/MRY extensions
*/
  }
/*
* To read ECMWF products, by Antonio S. Cofiño
*      antonio.cofino@unican.es
*/
 if((pds->usCenter_id==98 || pds->usCenter_id==74) && (pds->usCenter_sub>=1)) {
    if(pds->uslength >= 42){
      gbyte(in,&something,&skip,8);
      DPRINT ("pds->ecClass\n");
      pds->ecClass = (unsigned short) something;    
    }
    if(pds->uslength >= 43){
      gbyte(in,&something,&skip,8);
      DPRINT ("pds->ecType\n");
      pds->ecType = (unsigned short) something;    
    }
    if(pds->uslength >= 45){
      gbyte(in,&something,&skip,16);
      DPRINT ("pds->ecStream\n");
      pds->ecStream = (unsigned short) something;    
    }
    if(pds->uslength >= 49){
      strncpy(pds->ecVersion,&in[skip/8],4);
	  skip+=32;
	  DPRINT ("pds->ecVersion\n");   
    }
    
	if(pds->ecStream==1090 || pds->ecStream==1220){
		if(pds->uslength >= 51){
		  gbyte(in,&something,&skip,16);
		  DPRINT ("pds->ecNumber\n");
		  pds->ecNumber = (unsigned short) something;    
		}
		if(pds->uslength >= 53){
		  gbyte(in,&something,&skip,16);
		  DPRINT ("pds->ecSystemNumber\n");
		  pds->ecSystemNumber = (unsigned short) something;    
		}
		if(pds->uslength >= 55){
		  gbyte(in,&something,&skip,16);
		  DPRINT ("pds->ecMethodNumber\n");
		  pds->ecMethodNumber = (unsigned short) something;    
		}
		if(pds->uslength >= 57){
		  gbyte(in,&something,&skip,16);
		  DPRINT ("pds->ecEnsembleSize\n");
		  pds->ecEnsembleSize = (unsigned short) something;    
		}
		if(pds->ecEnsembleSize==0) pds->ecEnsembleSize=pds->ecClass==6?9:0; 

	}else{
		
		if(pds->uslength >= 50){
		  gbyte(in,&something,&skip,8);
		  DPRINT ("pds->ecNumber\n");
		  pds->ecNumber = (unsigned short) something;    
		}
		if(pds->uslength >= 51){
		  gbyte(in,&something,&skip,8);
		  DPRINT ("pds->ecEnsembleSize\n");
		  pds->ecEnsembleSize = (unsigned short) something;    
		}
	}	
 }



/*
* A.26      HEADER debug print
*/
  hdr_print ("Product Description Section", curr_ptr, pds->uslength);
  DPRINT ("Exiting gribgetpds() with no errors, status=0\n");

/*
* 
* A.27      RETURN 0  !success
*/
return(0);
} 
/*
* END OF FUNCTION
*
*
*/
