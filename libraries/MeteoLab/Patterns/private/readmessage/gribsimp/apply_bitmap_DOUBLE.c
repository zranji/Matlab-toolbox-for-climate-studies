#include <stdio.h>
#include <stdlib.h>

#include "grib.h"
extern int debug;  /* for dprint */

/*
    FILE  	: apply_bitmap.c
    Author	: Alice Nakajima, SAIC
    Date	: 17apr96
    Language	: Ansi-C

    Note:  any line that begins with '*' in column 1 will be
	   selected in strip_comments;
*
*
* ====================================================================
*  A.  FUNCTION:  apply_bitmap()
*
*      PURPOSE:   
*       apply the bitmap to the float array. Return with the
*	data array expanded with 'fill_value' in places where data
* 	points are missing.
*
*      INPUT VARIABLES:
*      BMS_INPUT *bms:  ptr to Bit Map Section Hdr structure
*      float **pgrib_data:  ptr to Data (copied fr BDS's bitstream)
*            current size is bms->ulbits_set elements
*            or (ROW*COL - #missing pts) elements;
*      float fill_value:    value used for missing datapoints
*      BDS_HEAD_INPUT *bds_head:  ptr to Binary Descr Hdr struct
*
*      RETURN CODE:
*      0>  Success; float **pgrib_data probably have been altered, 
*          new size is now ROW x COL;
*      1>  Fail: NULL bitmap encountered
*      2>  Fail: Error mallocing space for data array
*      3>  Fail: Tried to access more than avaiable in message
*      4>  Fail: not bits set in BMS
* =====================================================================
*/ 

int  apply_bitmap_DOUBLE ( BMS_INPUT *bms, double **pgrib_data, double fill_value, 
		BDS_HEAD_INPUT *bds_head)
{
  int   j;			/* temp var */
  int   val;			/* temp var */
  int	buf_indx;		/* index for expanded float *buff array */
  int   gribdata_indx;		/* index for float *Grid_data array */
  int	tot_bits_set;		/* must be < expanded size */
  char  *pbms; 			/* BIT ptr beg. at BMS data array */
  double	*fbuff;		 	/* holds expanded float array */
  int	 gridsize;		/* expanded size r*c */

/*
* 
* A.0   DRBUG printing
*/
  DPRINT ("Enter apply_bitmap()\n");

/*
*
* A.1   IF (using pre-defined bitmap)
*          PRINT 'case not supported' message
*          RETURN 0  !success
*       ENDIF
*/
  if (bms->uslength == 6) /* References pre-defined bitmap */
    {
      /* Not currently supported.  User can add code inside this IF
       * to retreive the bitmap from local storage if available.
       * For now, code prints warning and leaves data array alone */
      fprintf(stderr,"\nPredefined bitmap encountered! Not supported.\n");
      fprintf(stderr,"Must apply bitmap to data externally.\n");
      fprintf(stderr,"See GRIB.log for more info.\n");
      DPRINT("Leaving apply(): Predefined bitmap used, no action taken\n");
      return(0);
    }
           
/*
*
* A.2   IF (Bitmap pointer is NULL)
*          PRINT error msg
*          RETURN 1   !null pointer
*       ENDIF
*/
  if (bms->bit_map==NULL) {
	DPRINT ("Leaving apply():  bitmap is Null, no action taken\n");
	return(1); 
	}

/*
*
* A.3   IF (count of bits set in BMS is Zero)
*          PRINT error msg
*          RETURN 4   !no bits set
*       ENDIF
*/
   if ((tot_bits_set=bms->ulbits_set) == 0) {
       fprintf(stderr,"\nNo bits set in bitmap.  No data retrieved!!\n"); 
       DPRINT("Leaving apply(): No bits set in bitmap\n"); 
       return(4);
   }

/*
*
* A.4      CALCUALATE grid_size from total number of bits in BMS;
*/
  /* = (BMS length)*8 bits - 48 header bits - # of unsused bits */
  gridsize=(bms->uslength)*8 - 48 - bms->usUnused_bits;

  DPRINT ("Apply bitmap: expanding array from [%d] to [%d]; ",
  tot_bits_set, gridsize);

/* 
*
* A.5   ALLOCATE storage for expanded array 
*       IF (malloc error) 
*          RETURN 2 
*       ENDIF
*/
  fbuff= (double *)malloc (gridsize * sizeof(double));
  if (fbuff==(double *)NULL)
	{ 
          fprintf(stderr, "Error mallocing %ld bytes\n",gridsize);
          DPRINT ("Leaving apply(), malloc error\n");
          return(2); 
	}

/*
*
* A.6   FOR (each point expected)
*/
  pbms= bms->bit_map;	/* pts to char arry bstr of BMS */
  gribdata_indx=0;	/* index for incoming float arr */
  for (buf_indx=0; buf_indx < gridsize; ++pbms) {

/*
* A.6.1    GET next byte from Bitmap Section Data 
*/
	val= (int)*pbms & 0x0000ff ;	/* BMS bitstream */

/*
* A.6.2    LOOP, check each Bit of byte read (left to rightmost)
*/
	for (j=7; j>=0 && buf_indx < gridsize; j--) {
/*
* A.6.2.1     IF (bit is set)  !means datapoint is present
*/
	    if (val & (1<<j))
		{  
/*
* A.6.2.1.1       IF (trying to access more than #elements in Incoming Array)
*                    PRINT error
*                    RETURN 3    ! incoming float array unchanged
*                 ENDIF
*/
		   if (gribdata_indx == tot_bits_set) {
		     fprintf(stderr,
                    "Error:  accessing more than %d elements in Grib_data[]\n",
			tot_bits_set);
		     DPRINT ("Leaving apply(), access out of range element\n");
		     return(3);  /* incoming Float array is unchanged */
		     }

/*
* A.6.2.1.2       !still within range
*                 STORE datapoint at correct place in expanded array
*/
		   fbuff[buf_indx++]= **pgrib_data + gribdata_indx++;
		}
/*
*              ELSE  ! means data point is missing
*/
	    else {
/*
* A.6.2.2         STORE Missing Value at correct place in expanded array
*/
		   fbuff[buf_indx++]= fill_value;
		}
/*
* A.6.2.1      ENDIF
*/
         }  /* bit loop */
/*
* A.6.2    ENDLOOP 
*/

    } /* for every datapt */
/*
* A.6   ENDFOR !for every datapoint
*/

/*
*
* A.7   FREE old float array 
*/
  bds_head->ulGrid_size= (unsigned long)gridsize;  /* store new sz */
  free (*pgrib_data);

/*
*
* A.8   ASSIGN new expanded array to pointer
*/
  *pgrib_data= fbuff;	/* give it addr of expanded arr */

/*
*
* A.9   DEBUG printing
*/
  DPRINT ("Leaving apply_bitmap()\n");

  return (0); /* OK */
/*
*
* A.9  RETURN 0 !success
* END OF apply_bitmap()
*
*/
}
