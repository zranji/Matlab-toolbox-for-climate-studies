#include <stdio.h>
#include "grib.h"
extern int debug;	/* for DPRINT */
void gbyte (char *inchar, unsigned long *iout, unsigned long *iskip, 
		unsigned long nbits);

/*
* 
*
* ================================================================== 
* A.  FUNCTION  gribgetgds 
*     PURPOSE:  decode Grid Description Section (GDS) from entire 
*        message block and store its info in GDS structures;
*
*     INPUT:
*        char *curr_ptr;        pointer to current block 
*        grid_desc_sec *gds;    pointer to GDS structure
*
*     OUTPUT:
*        0>  success
*        num> unsupported projection number
  
  REVISION/MODIFICATION HISTORY:
  
       03/07/94 written by Mugur Georgescu CSC, Monterey CA
       02/01/96 modified by Steve Lowe SAIC, Monterey CA
       06/19/96 modified by Alice Nakajima SAIC, Monterey CA
  
  DESCRIPTION:
  
   This subroutine is responsible for decoding the Grid Description Section 
   in Gridded Binary (GRIB) format.
   The steps in the processing are as follows:
  	- get the vertical & horizontal parameters.
  	- get the data representation type
  	- given the data representation type, write the information that
  	  follows to the right projection structure (defined in grib.h).
   	- return error if another representation type is sent.
   
  RESTRICTIONS:
  
       NONE
  
  LANGUAGE:
  
       ANSI C
  
  INCLUDED FILES:
* ================================================================== 
*/

int gribgetgds(char *curr_ptr, struct grid_desc_sec *gds)
{
/*
   LOCAL VARIABLES
*/
char *in = curr_ptr;      /* pointer to the message */
long skip;             /* bits to be skipped */
unsigned long something;  /* value extracted from message */
int sign;                 /* sign + or - */
int status;
/*FILE *fp;*/
extern void hdr_print();

 DPRINT ("Entering gribgetgds()\n");

/*
*
* A.0      INIT status to good, skip to 0
*/
 status=0;  skip=0;
/*
*
* A.1      FUNCTION gbyte  !GDS length 
*/
 gbyte(in,&something,&skip,24); 
 DPRINT ("gds->head.uslength\n");
 gds->head.uslength = (unsigned short) something;  

/* 
*
* A.2      FUNCTION gbyte  !parm_nv
*/
 gbyte(in,&something,&skip,8); 
 DPRINT ("gds->head.usNum_v\n");
 gds->head.usNum_v =(short) something;             
/* get parm_nv */

/* 
*
* A.3      FUNCTION gbyte  !parm_pv_pl
*/
 gbyte(in,&something,&skip,8); 
 DPRINT ("gds->head.usPl_Pv\n");
 gds->head.usPl_Pv = (short) something;            

/* 
*
* A.4      FUNCTION gbyte  !data representation type
*/
 gbyte(in,&something,&skip,8); 
 DPRINT ("gds->head.usData_type\n");
 gds->head.usData_type = (short) something;        

/* Remainder of GDS is projection dependent */
/*
*
* A.5      SWITCH (data type)
*/
 switch(gds->head.usData_type)
    {
    case 0:    /* Latitude/Longitude Grid (Equidistant Cylindrical
                  or Plate Carree )         */
    case 4:    /* Gaussian Latitude/Longitude grid */
    case 10:   /* Rotated Lat/Lon */
    case 14:   /* Rotated Gaussian */
    case 20:   /* Stretched Lat/Lon */
    case 24:   /* Stretched Gaussian */
    case 30:   /* Stretched and Rotated Lat/Lon */
    case 34:   /* Stretched and Rotated Gaussian */
/*
*             case latlon: 
*             case gaussian_latlon:
*             case rotated gaussian:
*             case stretched latlon:
*             case stretched gaussian:
*             case stretched & rotated latlon:
*             case stretched & rotated gaussian:
*                 FUNCTION gbyte !get Number of Columns
*/
       gbyte(in, &something, &skip, 16);
       DPRINT ("gds->llg.usNi\n");
       gds->llg.usNi = (int) something;                   /* get Ni */

/*
*                 FUNCTION gbyte !get Number of Rows
*/
       gbyte(in, &something, &skip, 16);
       DPRINT ("gds->llg.usNj\n");
       gds->llg.usNj = (int) something;                   /* get Nj */

/*
*                 FUNCTION gbyte !get Latitude of First point
*/
       gbyte(in,&something,&skip,24);
       DPRINT ("Sign & gds->llg.lLat1 \n");
       sign = (int)(something >> 23) & 1;                 /* get sign */
       gds->llg.lLat1 = (long) (something) & 8388607;     /* get La1 */
       if(sign)                                           /* negative value */
          gds->llg.lLat1 = - gds->llg.lLat1;              /* multiply by -1 */

/*
*                 FUNCTION gbyte !get Longitude of First point
*/
       gbyte(in,&something,&skip,24);
       DPRINT ("Sign & gds->llg.lLon1 \n");
       sign = (int)(something >> 23) & 1;                 /* get sign */
       gds->llg.lLon1 = (long) (something) & 8388607;     /* get Lo1 */
       if(sign)                                           /* negative value */
           gds->llg.lLon1 = - gds->llg.lLon1;             /* multiply by -1 */

/*
*                 FUNCTION gbyte !get resolution & comp flags
*/
       gbyte(in,&something,&skip,8);
       DPRINT ("gds->llg.usRes_flag\n");
       gds->llg.usRes_flag = (short) something;           /* get resolution & comp flags */

       gbyte(in,&something,&skip,24);
       DPRINT ("Sign & gds->llg.lLat2 \n");
/*
*                 FUNCTION gbyte !get Latitude of Last point
*/
       sign = (int)(something >> 23) & 1;                 /* get sign */
       gds->llg.lLat2 = (long) (something) & 8388607;     /* get La2 */
       if(sign)                                           /* negative value */
          gds->llg.lLat2 = - gds->llg.lLat2;              /* multiply by -1 */

/*
*                 FUNCTION gbyte !get Longitude of Last point
*/
       gbyte(in,&something,&skip,24);
       DPRINT ("Sign & gds->llg.lLon2 \n");
       sign = (int)(something >> 23) & 1;                 /* get sign */
       gds->llg.lLon2 = (long) (something) & 8388607;     /* get Lo2 */
       if(sign)                                           /* negative value */
          gds->llg.lLon2 = - gds->llg.lLon2;              /* multiply by -1 */

/*
*                 FUNCTION gbyte !get Longitudinal Increment
*/
       gbyte(in,&something,&skip,16);
       DPRINT ("gds->llg.iDi\n");
       gds->llg.iDi = (int) something;			  /* get Di */

/*
*                 FUNCTION gbyte !get Latitudinal Increment
*/
       gbyte(in,&something,&skip,16);
       DPRINT ("gds->llg.iDj\n");
       gds->llg.iDj = (int) something;			  /* get Dj */

/*
*                 FUNCTION gbyte !get scanning mode
*/
       gbyte(in,&something,&skip,8);
       DPRINT ("gds->llg.usScan_mode\n");
       gds->llg.usScan_mode = (short) something;          /* get scaning mode flag */

/*
*                 FUNCTION gbyte !get reserved octets 29-32
*/
       gbyte(in,&something,&skip,32);
       DPRINT ("gds->llg.usZero\n");
       gds->llg.usZero = (long) something;                /* get reserved octets 29 - 32 */

/*
*                 FUNCTION gbyte !get south pole lat
*/
       gbyte(in,&something,&skip,24);
       DPRINT ("Sign & gds->llg.lLat_southpole \n");
       sign = (int)(something >> 23) & 1;                        /* get sign */
       gds->llg.lLat_southpole = (long) (something) & 8388607;   /* get south pole lat */
       if(sign)                                                  /* negative value */
          gds->llg.lLat_southpole = - gds->llg.lLat_southpole;   /* multiply by -1 */

/*
*                 FUNCTION gbyte !get south pole lon
*/
       gbyte(in,&something,&skip,24);
       DPRINT ("Sign & gds->llg.lLon_southpole \n");
       sign = (int)(something >> 23) & 1;                        /* get sign */
       gds->llg.lLon_southpole = (long) (something) & 8388607;   /* get south pole lon */
       if(sign)                                                  /* negative value */
          gds->llg.lLon_southpole = - gds->llg.lLon_southpole;   /* multiply by -1 */

/*
*                 FUNCTION gbyte !angle of rotation
*/
       gbyte(in,&something,&skip,24);
       DPRINT ("gds->llg.lRotate\n");
       gds->llg.lRotate = (long) something;               /* get angle of rotation */

/*
*                 FUNCTION gbyte !get lat pole stretching
*/
       gbyte(in,&something,&skip,24);
       DPRINT ("Sign & gds->llg.lPole_lat \n");
       sign = (int)(something >> 23) & 1;                 /* get sign */
       gds->llg.lPole_lat = (long) (something) & 8388607; /* get lat pole stretching */
       if(sign)                                           /* negative value */
          gds->llg.lPole_lat = - gds->llg.lPole_lat;      /* multiply by -1 */

/*
*                 FUNCTION gbyte !get lon pole stretching
*/
       gbyte(in,&something,&skip,24);
       DPRINT ("Sign & gds->llg.lPole_lon \n");
       sign = (int)(something >> 23) & 1;                 /* get sign */
       gds->llg.lPole_lon = (long) (something) & 8388607; /* get lon pole stretching */
       if(sign)                                           /* negative value */
          gds->llg.lPole_lon = - gds->llg.lPole_lon;      /* multiply by -1 */

       gbyte(in,&something,&skip,24);
       DPRINT ("gds->llg.lStretch\n");
       gds->llg.lStretch = (long) something;
       break;

    case 1:    /* Mercator Projection Grid               */
/*
*             case Mercator Projection Grid:
*                 FUNCTION gbyte !get Number of Columns
*/
       gbyte(in,&something,&skip,16); 
       DPRINT ("gds->merc.cols\n");
       gds->merc.cols = (int) something;                  /* get Ni */

/*
*                 FUNCTION gbyte !get Number of Rows
*/
       gbyte(in,&something,&skip,16); 
       DPRINT ("gds->merc.rows\n");
       gds->merc.rows = (int) something;                  /* get Nj */

/*
*                 FUNCTION gbyte !get Latitude of First Point
*/
       gbyte(in,&something,&skip,24); 
       DPRINT ("Sign & gds->merc.first_lat\n");
       sign = (int)(something >> 23) & 1;                   /* get sign */
       gds->merc.first_lat = (long) (something) & 8388607;  /* get La1 */
       if(sign)                                             /* negative value */
          gds->merc.first_lat = - gds->merc.first_lat;      /* multiply by -1 */

/*
*                 FUNCTION gbyte !get Longitude of First Point
*/
       gbyte(in,&something,&skip,24); 
       DPRINT ("Sign & gds->merc.first_lon\n");
       sign = (int)(something >> 23) & 1;                   /* get sign */
       gds->merc.first_lon = (long) (something) & 8388607;  /* get Lo1 */
       if(sign)                                             /* negative value */
          gds->merc.first_lon = - gds->merc.first_lon;      /* multiply by -1 */

/*
*                 FUNCTION gbyte !get resolution & comp flag
*/
       gbyte(in,&something,&skip,8); 
       DPRINT ("gds->merc.usRes_flag\n");
       gds->merc.usRes_flag = (short) something;            /* get resolution & comp flags */

/*
*                 FUNCTION gbyte !get Latitude of Last point
*/
       gbyte(in,&something,&skip,24); 
       DPRINT ("Sign & gds->merc.La2\n");
       sign = (int)(something >> 23) & 1;                   /* get sign */
       gds->merc.La2 = (long) (something) & 8388607;        /* get La2 */
       if(sign)                                             /* negative value */
          gds->merc.La2 = - gds->merc.La2;                  /* multiply by -1 */

/*
*                 FUNCTION gbyte !get Longitude of Last point
*/
       gbyte(in,&something,&skip,24); 
       DPRINT ("Sign & gds->merc.Lo2\n");
       sign = (int)(something >> 23) & 1;                   /* get sign */
       gds->merc.Lo2 = (long) (something) & 8388607;        /* get Lo2 */
       if(sign)                                             /* negative value */
          gds->merc.Lo2 = - gds->merc.Lo2;                  /* multiply by -1 */

/*
*                 FUNCTION gbyte !get Latitude where projection intersects Earth
*/
       gbyte(in,&something,&skip,24); 
       DPRINT ("Sign & gds->merc.latin\n");
       sign = (int)(something >> 23) & 1;                   /* get sign */
       gds->merc.latin = (long) (something) & 8388607;      /* get latin */
       if(sign)                                             /* negative value */
          gds->merc.latin = - gds->merc.latin;              /* multiply by -1 */

       skip += 8;      /* skip over the reserved octet */

/*
*                 FUNCTION gbyte !get scanning mode flag
*/
       gbyte(in,&something,&skip,8);
       DPRINT ("gds->merc.usScan_mode\n");
       gds->merc.usScan_mode = (short) something;            /* get scaning mode flag */

/*
*                 FUNCTION gbyte !get Longitudinal Increment
*/
       gbyte(in,&something,&skip,24); 
       DPRINT ("gds->merc.lon_inc\n");
       gds->merc.lon_inc = (float) something;               /* get Di */

/*
*                 FUNCTION gbyte !get Latitudinal Increment
*/
       gbyte(in,&something,&skip,24); 
       DPRINT ("gds->merc.lat_inc\n");
       gds->merc.lat_inc = (float) something;               /* get Dj */

       gbyte(in,&something,&skip,32);
       DPRINT ("gds->merc.usZero\n");
       gds->merc.usZero = (long) something;
       break;

    case 5:    /* Polar Stereographic Projection Grid    */
/*
*             case Polar Stereographic Projection Grid:
*                 FUNCTION gbyte !get Number of Columns
*/
       gbyte(in,&something,&skip,16); 
       DPRINT ("gds->pol.usNx\n");
       gds->pol.usNx = (short) something;                   /* get Nx */

/*
*                 FUNCTION gbyte !get Number of Rows
*/
       gbyte(in,&something,&skip,16); 
       DPRINT ("gds->pol.usNy\n");
       gds->pol.usNy = (short) something;                   /* get Ny */

/*
*                 FUNCTION gbyte !get Latitude of First point
*/
       gbyte(in,&something,&skip,24); 
       DPRINT ("Sign & gds->pol.lLat1\n");
       sign = (int)(something >> 23) & 1;                   /* get sign */
       gds->pol.lLat1 = (long)  (something) & 8388607;      /* get La1 */
       if(sign)                                             /* negative value */
          gds->pol.lLat1 = - gds->pol.lLat1;                /* multiply by -1 */

/*
*                 FUNCTION gbyte !get Longitude of First point
*/
       gbyte(in,&something,&skip,24); 
       DPRINT ("Sign & gds->pol.lLon1\n");
       sign = (int)(something >> 23) & 1;                   /* get sign */
       gds->pol.lLon1 = (long) (something) & 8388607;       /* get Lo1 */
       if(sign)                                             /* negative value */
          gds->pol.lLon1 = - gds->pol.lLon1;                /* multiply by -1 */

/*
*                 FUNCTION gbyte !get resolution & comp flag
*/
       gbyte(in,&something,&skip,8); 
       DPRINT ("gds->pol.usRes_flag\n");
       gds->pol.usRes_flag = (short) something;             /* get resolution & comp flags */

/*
*                 FUNCTION gbyte !get Orientation Longitude
*/
       gbyte(in,&something,&skip,24); 
       DPRINT ("Sign & gds->pol.lLon_orient\n");
       sign = (int)(something >> 23) & 1;                    /* get sign */
       gds->pol.lLon_orient = (long) (something) & 8388607;  /* get Orientation */
       if(sign)                                              /* negative value */
          gds->pol.lLon_orient = - gds->pol.lLon_orient;     /* multiply by -1 */

/*
*                 FUNCTION gbyte !get Increment along a Row
*/
       gbyte(in,&something,&skip,24);
       DPRINT ("gds->pol.ulDx\n");
       gds->pol.ulDx = something;                   /* get Dx */

/*
*                 FUNCTION gbyte !get Increment along a Column
*/
       gbyte(in,&something,&skip,24);
       DPRINT ("gds->pol.ulDy\n");
       gds->pol.ulDy =  something;                   /* get Dy */

/*
*                 FUNCTION gbyte !get projection center flag
*/
       gbyte(in,&something,&skip,8);
       DPRINT ("gds->pol.usProj_flag\n");
       gds->pol.usProj_flag = (short) something;            /* get Projection center flag */

/*
*                 FUNCTION gbyte !get scanning mode
*/
       gbyte(in,&something,&skip,8);
       DPRINT ("gds->pol.usScan_mode\n");
       gds->pol.usScan_mode = (short) something;            /* get scaning mode flag */

/*
*                 FUNCTION gbyte !reserved zero
*/
       gbyte(in,&something,&skip,32);
       DPRINT ("gds->pol.usZero\n");
       gds->pol.usZero = (int) something;                   /* get Reserved zero */
       break;

    case 3:    /* Lambert conformal, secant or tangent, conical or bipolar */
    case 8:    /* Albers equal-area, secant or tangent, conical or bipolar */
    case 13:   /* Oblique Lambert conformal */
/*
*             case Lambert conformal, secant or tangent, conical or bipolar:
*             case Albers equal-area, secant or tangent, conical or bipolar:
*             case Oblique Lambert conformal:
*                 FUNCTION gbyte !get Number of Columns
*/
       gbyte(in,&something,&skip,16); 
       DPRINT ("gds->lam.iNx\n");
       gds->lam.iNx = (int) something;                      /* get Nx */

/*
*                 FUNCTION gbyte !get Number of Rows
*/
       gbyte(in,&something,&skip,16); 
       DPRINT ("gds->lam.iNy\n");
       gds->lam.iNy = (int) something;                      /* get Ny */

/*
*                 FUNCTION gbyte !get Latitude of First Point
*/
       gbyte(in,&something,&skip,24); 
       DPRINT ("Sign & gds->lam.lLat1\n");
       sign = (int)(something >> 23) & 1;                   /* get sign */
       gds->lam.lLat1 = (long)  (something) & 8388607;      /* get La1 */
       if(sign)                                             /* negative value */
          gds->lam.lLat1 = - gds->lam.lLat1;                /* multiply by -1 */

/*
*                 FUNCTION gbyte !get Longitude of First Point
*/
       gbyte(in,&something,&skip,24); 
       DPRINT ("Sign & gds->lam.lLon1)\n");
       sign = (int)(something >> 23) & 1;                   /* get sign */
       gds->lam.lLon1 = (long) (something) & 8388607;       /* get Lo1 */
       if(sign)                                             /* negative value */
          gds->lam.lLon1 = - gds->lam.lLon1;                /* multiply by -1 */

/*
*                 FUNCTION gbyte !get resolution & comp flag
*/
       gbyte(in,&something,&skip,8); 
       DPRINT ("gds->lam.usRes_flag\n");
       gds->lam.usRes_flag = (short) something;             /* get resolution & comp flags */

/*
*                 FUNCTION gbyte !get Orientation Longitude
*/
       gbyte(in,&something,&skip,24); 
       DPRINT ("Sign & gds->lam.lLon_orient)\n");
       sign = (int)(something >> 23) & 1;                    /* get sign */
       gds->lam.lLon_orient = (long) (something) & 8388607;  /* get Orientation */
       if(sign)                                              /* negative value */
          gds->lam.lLon_orient = - gds->lam.lLon_orient;     /* multiply by -1 */

/*
*                 FUNCTION gbyte !get Increment along a Row
*/
       gbyte(in,&something,&skip,24); 
       DPRINT ("gds->lam.ulDx\n");
       gds->lam.ulDx =  something;                    /* get Dx */

/*
*                 FUNCTION gbyte !get Increment along a Column
*/
       gbyte(in,&something,&skip,24); 
       DPRINT ("gds->lam.ulDy\n");
       gds->lam.ulDy =  something;                    /* get Dy */

/*
*                 FUNCTION gbyte !get Projection Center
*/
       gbyte(in,&something,&skip,8); 
       DPRINT ("gds->lam.usProj_flag\n");
       gds->lam.usProj_flag = (short) something;             /* get Projection center flag */

/*
*                 FUNCTION gbyte !get scanning mode flag
*/
       gbyte(in,&something,&skip,8); 
       DPRINT ("gds->usScan_mode\n");
       gds->lam.usScan_mode = (short) something;             /* get scaning mode flag */

/*
*                 FUNCTION gbyte !get First lat from pole that intersects Earth
*/
       gbyte(in,&something,&skip,24); 
       DPRINT ("gds->lLat_cut1\n");
       gds->lam.lLat_cut1 = (long) something;                /* get latin_1 */

/*
*                 FUNCTION gbyte !get Second lat from pole that intersects Earth
*/
       gbyte(in,&something,&skip,24); 
       DPRINT ("gds->lLat_cut2\n");
       gds->lam.lLat_cut2 = (long) something;                /* get latin_2 */

/*
*                 FUNCTION gbyte !get lat of south pole
*/
       gbyte(in,&something,&skip,24);
       DPRINT ("Sign & gds->lLat_southpole\n");
       sign = (int)(something >> 23) & 1;                        /* get sign */
       gds->lam.lLat_southpole = (long) (something) & 8388607;   /* get lat of S pole */
       if(sign)                                                  /* negative value */
           gds->lam.lLat_southpole = - gds->lam.lLat_southpole;  /* multiply by -1 */

/*
*                 FUNCTION gbyte !get lon of South pole
*/
       gbyte(in,&something,&skip,24); 
       DPRINT ("Sign & gds->lLon_southpole\n");
       sign = (int)(something >> 23) & 1;                        /* get sign */
       gds->lam.lLon_southpole = (long) (something) & 8388607;   /* get long of S pole */
       if(sign)                                                  /* negative value */
           gds->lam.lLon_southpole = - gds->lam.lLon_southpole;  /* multiply by -1 */

/*
*                 FUNCTION gbyte !get Reserved zero
*/
       gbyte(in,&something,&skip,16); 
       DPRINT ("gds->lam.usZero\n");
       gds->lam.usZero = (int) something;                    /* get Reserved zero */
       break;

    default :             /* other cases not implemented in this version */
/*
*             default:   ! unsupported data types
*                 SET status to bad
*/
       status=1;         /* set status to failure */
       break;
/*
*
* A.5      ENDSWITCH
*/
    }  /* end switch on data type */

/*
*
* A.6      HEADER debug print
*/
  hdr_print ("Grid Description Section", curr_ptr, gds->head.uslength);
  DPRINT ("Exiting gribgetgds() with status=%d\n", status);

/*
*
* A.7      RETURN (status)
*/
  return(status);

}  
/*
*  END OF FUNCTION 
*
*/
