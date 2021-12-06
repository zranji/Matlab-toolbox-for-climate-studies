#include <stdio.h>
#include <stdlib.h>
#include <math.h> 
#include "grib.h"
extern int debug;	/* for dPRINT */
void gbyte (char *inchar, unsigned long *iout, unsigned long *iskip, 
		unsigned long nbits);

/*
*
*
* ====================================================================
* A.  FUNCTION:  gribgetbds 
  
  REVISION/MODIFICATION HISTORY:
       03/07/94 written by Mugur Georgescu CSC, Monterey CA
       02/01/96 modified by Steve Lowe SAIC, Monterey CA
       04/17/96 modified by Alice Nakajima SAIC, Monterey CA
       06/19/96 add hdrprint;/nakajima
* 
*     PURPOSE :  decodes the Binary Data Section of the GRIB message 
*                and filling grib_data float array.
*
*     INPUT:
*        char *curr_ptr;          pointer to current block holding
*                                 the entire message;
*        float **ppgrib_data;     double pointer to array of float;
*                                 (null upon entry) 
*        int deci_scale;          decimal scaling factor
*        BDS_HEAD_INPUT bds_head; points to Binary Data Sect header struct
*                                 (empty upon entry)
*        BMS_INPUT *bms;	  points to Bit Map Sect header Struct 
*        grid_desc_sec *gds;	  points to Grid Description Sect hdr Struct 
* 
*      RETURN CODE:
*        0    no errors
*        1    unrecognized packing algorithm
*        2    # of points does not match bitmap
*        3    # of points does not match grid size in GDS
*        4    malloc error
* ====================================================================
  
  RESTRICTIONS: NONE
  LANGUAGE: ANSI C
*/

int gribgetbds(char *curr_ptr, float **pgrib_data, short deci_scale,
	struct BDS_HEAD_INPUT *bds_head, 
	grid_desc_sec *gds, BMS_INPUT *bms)
{
/*
   LOCAL VARIABLES
*/
char *in = curr_ptr;      /* pointer to the data block */
long length;              /* size of the Binary Data Section */
long scale;               /* scaling factor */
float ref_val;            /* reference value (minimum value) */
unsigned long something;  /* generic value from message */
long data_width;          /* number of bits that data occupies */
long halfBYTE4;            /* the first 4 bits in 4-th byte */
int sign;                 /* sign + or - */
float dscale;             /* 10 to the decimal scaling power */
float bscale;             /* 2 to the binary scaling power   */
long skip=0;              /* number of bits to be skipped */
long c_ristic;            /* characteristic for float representation */
long mantissa;            /* mantissa for float representation */
long numpts;              /* number of bits left at end of bitstream */
unsigned long data_pts;   /* number of data points in bitstream */
unsigned long num_calc;	  /* temp work var */
float *grib_data=0;       /* local work array for grid data */
float fdata=(float)0.;            /* data value stored in reference */
unsigned short i;         /* array counter */
extern void hdr_print();
int save_debug_flag;      /* while disabling debug flag */

/*
CODE
*/

/*
* A.0       HEADER debug print
*/
  DPRINT ("Entering gribgetbds()\n");
  hdr_print ("Binary Data Section", curr_ptr, 11);

/*
* A.1       FUNCTION gbyte !get bds length
*/
  gbyte(in,&length,&skip,24);
  DPRINT ("bds_head->length\n");
  bds_head->length = (unsigned long) length;

/*
*
* A.2       FUNCTION gbyte !get BDS flag 
*/
  gbyte(in, &halfBYTE4, &skip, 4);
  DPRINT ("bds_head->usBDS_flag\n");
  bds_head->usBDS_flag = (short) halfBYTE4;  /* get BDS Flag (Table 11) */

/*
*
* A.3       IF (unsupported packing algorithm)  THEN
*               RETURN 1
*           ENDIF
*/
  /* need to check on packing algorithm */
  if (halfBYTE4)  /* unrecognized packing algorithm */
    {
     DPRINT ("Exiting gribgetbds() with err status=1\n");
     return(1);   /* return error */
    }

/*
*
* A.4       FUNCTION gbyte !get number of unused bits
*/
  gbyte(in,&numpts,&skip,4);           /* get number of bits at end of BDS */
  DPRINT ("numpts\n");

/*
*
* A.5       FUNCTION gbyte !get Binary Scale Factor
*/
  gbyte(in,&something,&skip,16);
  DPRINT ("Sign & bds_head->Bin_sc_fctr\n");
  sign = (int)(something >> 15) & 1;  /* get sign for scale */
  scale = (int)(something) & 32767;   /* get scale */
  if(sign)                            /* scale negative */
     scale = -scale;                  /* multiply scale by -1 */
  bds_head->Bin_sc_fctr = (int) scale;  /* get binary scale factor */

/*
*
* A.6       CALCULATE Reference value from IBM representation
*             !FUNCTION gbyte !get the sign of reference
*             !FUNCTION gbyte !get charateristic
*             !FUNCTION gbyte !get the mantissa
*/
  gbyte(in,&something,&skip,8);
  DPRINT ("Sign & Reference)\n");
  sign = (int)(something >> 7) & 1;   /* get the sign for reference value */

  skip -= 7;
  gbyte(in,&c_ristic,&skip,7);         /* get the characteristic for the float */
  DPRINT ("c_ristic\n");

  gbyte(in,&mantissa,&skip,24);        /* get the mantissa for the float */
  DPRINT ("mantissa\n");
  c_ristic -= 64;                     /* substract 64 from chatacteristic */
  ref_val = (float)( mantissa * (float)(pow(16.0,(double)c_ristic)) * (pow(2.0,-24.0)));
  if(sign)                            /* negative reference value */
     ref_val = -ref_val;              /* multiply ref_val by -1 */
  bds_head->fReference = (float)ref_val;

/*
*
* A.7       FUNCTION gbyte !get data width
*/
  gbyte(in,&data_width,&skip,8);       /* get data width */
  DPRINT ("bds_head->usBit_pack_num\n");
  bds_head->usBit_pack_num = (short)data_width;

/*
*
* A.8       SET Binary and Decimal Scale Factors
*/
  /* set binary scale */
  bscale = (float)pow (2.0,(double) scale);

  /* set decimal scale */
  dscale = (float)pow (10.0, (double) deci_scale);

/*
*
* A.9       IF (data_width is zero) THEN
*               ! grid contains a constant value
*               SET grid_size to 1
*               ALLOCATE array of 1 float for gribdata
*               STORE Reference Value in gribdata
*               RETURN 0 !success
*           ENDIF
*/
  if (!data_width) {
     bds_head->ulGrid_size = 1;
     fdata = (float) (ref_val / dscale);
     *pgrib_data = (float *) malloc(sizeof(float));
     **pgrib_data = fdata;
     DPRINT ("Exiting gribgetbds() with status=0\n");
     return(0);
  }

  /* fill the data array with values from message */
  /*     - Assume that GDS may not be included so that
   *         the number of grid points may not be defined.       
   *     - Compute space to malloc based on BDS length,
   *         data_width, and numpts.
   *     - if grid_size from GDS is zero, use
   *         computed number of points.
   */

/*
*
* A.10      CALCULATE number of data points actually in BDS
*/
  num_calc = ((length - 11)*8 - numpts) / data_width;

  /* Check the number of points computed against info in the BMS
     or GDS, if they are available */

/*
*
* A.11      IF (BMS is present and has included bitmap) THEN
*               IF (#calculated not same as #bits set in BMS) THEN
*                   RETURN 2
*               ENDIF
*/
  if (bms->uslength > 6)
  {
      if (bms->ulbits_set != num_calc) {
	DPRINT ("exiting gribgetbds() with error status=2\n");
	return(2);
	}
  }
/*
* A.11.1    ELSE  !no bms
*               IF (GDS is present AND
*                   #calculated not same as BDS's grid size)
*               THEN
*                   RETURN 3
*               ENDIF
*/
  else
  {
      if (bds_head->ulGrid_size &&
          bds_head->ulGrid_size != num_calc) {
	   DPRINT ("exiting gribgetbds() with error status=3\n");
	   return(3);
	 }
  }
/*
* A.11      ENDIF (BMS present)
*/

  /* Only reach this point if number of points in BDS matches info
     in BMS or GDS.  This number is unchecked if no BMS or GDS. */

  /* Make sure number of points in BDS is value used for extracting */
/*
*
* A.12      SET #datapoints
*/
  data_pts= num_calc;

/*
*
* A.13      ALLOCATE storage for float array size
*           IF (error) THEN
*               RETURN 4
*           ENDIF
*/
  grib_data =(float *) malloc(data_pts * sizeof(float));
  if (grib_data==NULL) {
	DPRINT ("exiting gribgetbds() with error status=4\n");
	return(4);
	}

/*
*
* A.14      SET data array pointer to local data array
*/
  *pgrib_data = grib_data;

/*
*
* A.15      FOR (each data point) DO   !w/ debug temporarily disabled
*               FUNCTION gbyte !get data_width bits
*               INCREMENT skip by data_width
*               COMPUTE and STORE value in float array
*           ENDDO
*/

  save_debug_flag= debug; 
  debug=0;  

  for(i=0;i < data_pts ;i++)  /* not DPRINTing here */
     {
     gbyte(in,&something,&skip,data_width);
     grib_data[i]= (float)(ref_val + (something * bscale))/dscale;
     }

/*
*
* A.16      RESTORE debug flag 
*/
  debug= save_debug_flag;
 
/*
*
* A.17      DEBUG printing
*/
  DPRINT ("exiting gribgetbds() with no errors, status=0\n");
/*
*
* A.18      RETURN 0  !success
*/
return(0);  /* return status OK */
}    
/* 
* END OF FUNCTION  gribgetbds 
*
*
*/
