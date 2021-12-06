/* Program    : printer
   Programmer : Todd J. Kienitz, SAIC
   Date       : January 10, 1996
   Purpose    : To produce the information file output of the GRIB message.

   Revisions  : Steve Lowe, SAIC, 4/17/96, modified data print-out
                Alice Nakajima, SAIC, 4/22/96, added BMS summary
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "grib.h"
#include "tables.h"
extern int debug;  /* for dpint */

void printer(PDS_INPUT pds, grid_desc_sec gds, BDS_HEAD_INPUT bds,
             unsigned long msg_length, table2 tab2[], table3 tab3[],
             tables mgotab, float *grib_data, int UseTables, long offset,
             BMS_INPUT bms)

/* 
*
*
* =====================================================================
*  A.  FUNCTION printer()
*
*      PURPOSE:  Produce debug file GRIB.log from the GRIB Header structures
*
*      INPUT VARIABLES:
*      pds        product definition section structure
*      gds        grid description section structure
*      bds        binary data section header structure
*      msg_length total length of GRIB message
*      tab2[]     array of table2 structures
*      tab3[]     array of table3 structures
*      mgotab     structure for geom, model, and orig_ctr IDs
*      grib_data array of decoded data
*      UseTables  0: don't use tables, 1: use table
*      offset     starting location of GRIB message in bytes
*      bms        bit map definition section structure
*
*      OUTPUT: file GRIB.log
*
*      RETURN CODE:  none
* =====================================================================
*/
{
  int i;
/*  int k;*/
  int fd;
  int numpts = 100;
  float dsf;
  float res;
  float min;
  float max;
  FILE *fp;

/*
*
* A.0   DEBUG printing
*/
  DPRINT ("Entering  printer()\n");

/* 
*
* A.1   OPEN file "GRIB.log" in APPEND mode
*/
  fp=fopen ("GRIB.log", "a+");

/*
*
* A.2   WRITE Indicator Section information to file
*       !message length
*       !GRIB Edition number
*/
  fprintf (fp, "**** VALID MESSAGE FOUND AT %ld BYTES ****\n",offset);

  fprintf (fp, "\n********* SECTION 0 IDS *********\n" );
  fprintf (fp, "Total Message length = %u\n",msg_length);
  fprintf (fp, "Edition Number = %d\n", pds.usEd_num);

/*
*
* A.3   WRITE Product Definition Section information to file
*       !Section length
*       !Parameter Table version
*       !Parameter Sub-Table version if defined
*       !Tracking id if defined
*/
  fprintf(fp,"\n********* SECTION 1 PDS *********\n");
  fprintf(fp,"Section length = %d\n", pds.uslength);
  fprintf(fp,"Table version = %d\n",pds.usParm_tbl);
  if (pds.usSub_tbl != 0)
    fprintf(fp,"Local Table version = %d\n",pds.usSub_tbl);
  if(pds.usTrack_num  != 0)
    fprintf(fp,"Tracking ID = %d\n",pds.usTrack_num);

/*
*       !Originating Center id
*       !IF (using tables) Name of Originating Center
*/
  fprintf(fp,"Originating Center id = %d\n",pds.usCenter_id);
  if (UseTables)
     if ( strlen(mgotab.orig_ctr[pds.usCenter_id]) != 0 )
        fprintf(fp,"Originating Center = %s\n",mgotab.orig_ctr[pds.usCenter_id]);
     else
        fprintf(fp,"Originating Center ID not defined in current table.\n");

/*
*       !Sub-Table Entry for Originating Center if defined
*/
  if (pds.usCenter_sub != 999) 
     fprintf(fp,"Sub-Table Entry Originating Center = %d\n",pds.usCenter_sub);


/*
*       !Model Identification
*       !IF (using tables) Model Description
*/
  fprintf(fp,"Model id = %d\n",pds.usProc_id);
  if (UseTables)
     if ( strlen(mgotab.model[pds.usProc_id]) != 0 )
        fprintf(fp,"Model Description = %s\n",mgotab.model[pds.usProc_id]);
     else
        fprintf(fp,"Model ID not defined in current table.\n");

/*
*       !Grid Identification
*       !IF (using tables) Grid Description
*/
  fprintf(fp,"Grid id = %d\n",pds.usGrid_id);
  if (UseTables) 
     if ( strlen(mgotab.geom_name[pds.usGrid_id]) != 0 )
        fprintf(fp,"Grid Description = %s\n",mgotab.geom_name[pds.usGrid_id]);
     else
        fprintf(fp,"Grid ID not defined in current table.\n");

/*
*       !Parameter Identification
*/
  fprintf(fp,"Parameter id = %d\n",pds.usParm_id);

/*
*       !IF ((Parm id > 249) AND (Sub Parm ID defined))
*       !  IF (Parameter sub-id defined)
*       !    Parameter sub-id
*       !    IF (using tables) Parameter Description and Units
*       !  ENDIF (sub-id defined)
*/
  if((pds.usParm_id > 249) && (pds.usParm_sub != 999))
  {
      fprintf(fp,"Parameter sub-id = %d\n",pds.usParm_sub);
      if(UseTables) {
        if ( strlen(tab2[pds.usParm_id].sub_tab2[pds.usParm_sub].field_param) != 0 )
        {
           fprintf(fp,"Parameter name = %s\n",
                   tab2[pds.usParm_id].sub_tab2[pds.usParm_sub].field_param);
           fprintf(fp,"Parameter units = %s\n",
                   tab2[pds.usParm_id].sub_tab2[pds.usParm_sub].unit);
        }else
           fprintf(fp,"Parameter ID not defined in current table.\n");
      }
  }

/*
*       !ELSE (messase does not include Parameter sub-id)
*       !    IF (using tables) Parameter Description and Units
*/
  else
    if(UseTables) {
      if ( strlen(tab2[pds.usParm_id].field_param) != 0 ) {
         fprintf(fp,"Parameter name = %s\n",tab2[pds.usParm_id].field_param);
         fprintf(fp,"Parameter units = %s\n",tab2[pds.usParm_id].unit);
      }else
         fprintf(fp,"Parameter ID not defined in current table.\n");
    }

/*
*       !Level Id 
*       !IF (using tables)
*       !  Level description
*       !  SWITCH (number of octets to store Height1)
*       !     2: Level = Height1
*       !     1: Bottom of Layer = Height1
*       !        Top of Layer = Height2
*       !     0: (no Height value required)
*       !     default: (corrupt table entry or message)
*       !  ENDSWITCH
*       !ELSE (not using tables)
*       !  Level = Height1  (Level assumed)
*       !ENDIF
*/
  fprintf(fp,"Level_type = %d\n",pds.usLevel_id);
  if(UseTables) {
    if ( strlen(tab3[pds.usLevel_id].meaning) != 0 ) {
       fprintf(fp,"Level description = %s\n",tab3[pds.usLevel_id].meaning);
       switch(tab3[pds.usLevel_id].num_octets){
         case 2:
           fprintf(fp,"%s = %u\n",tab3[pds.usLevel_id].contents1,pds.usHeight1);
           break;
         case 1:
           fprintf(fp,"%s = %u\n",tab3[pds.usLevel_id].contents1,pds.usHeight1);
           fprintf(fp,"%s = %u\n",tab3[pds.usLevel_id].contents2,pds.usHeight2);
           break;
         case 0:
           break;
         default:
           fprintf(fp,"***Number of octets for table 3 undefined - possibly "
                   "corrupt dataset.***\n");
       }
    }else
       fprintf(fp,"Level ID not defined in current table.\n");
  } /* end UseTables 'if' statement */
  else fprintf(fp,"Level = %u\n",pds.usHeight1);

/*
*       !Reference Date/Time:
*       !  Century
*       !  Year
*       !  Month
*       !  Day
*       !  Hour
*       !  Minute
*       !  Second if defined
*/
  fprintf(fp,"Reference Date/Time of Data Set:\n");
  fprintf(fp,"   Century = %d\n",pds.usCentury);
  fprintf(fp,"   Year = %d\n",pds.usYear);
  fprintf(fp,"   Month = %d\n",pds.usMonth);
  fprintf(fp,"   Day = %d\n",pds.usDay);
  fprintf(fp,"   Hour = %d\n",pds.usHour);
  fprintf(fp,"   Minute = %d\n",pds.usMinute);
  if(pds.usSecond != 999)
    fprintf(fp,"   Second = %d\n",pds.usSecond);

/*
*       !Forecast Time Unit
*       !  Forecast Period 1
*       !  Forecast Period 2
*/
  switch(pds.usFcst_unit_id){
    case 0:
      fprintf(fp,"Forecast Time Unit = Minute\n");
      break;
    case 1:
      fprintf(fp,"Forecast Time Unit = Hour\n");
      break;
    case 2:
      fprintf(fp,"Forecast Time Unit = Day\n");
      break;
    case 3:
      fprintf(fp,"Forecast Time Unit = Month\n");
      break;
    case 4:
      fprintf(fp,"Forecast Time Unit = Year\n");
      break;
    case 5:
      fprintf(fp,"Forecast Time Unit = Decade (10 years)\n");
      break;
    case 6:
      fprintf(fp,"Forecast Time Unit = Normal (30 years)\n");
      break;
    case 7:
      fprintf(fp,"Forecast Time Unit = Century (100 years)\n");
      break;
    case 254:
      fprintf(fp,"Forecast Time Unit = Second\n");
      break;
    default:
      fprintf(fp,"Forecast Time Unit = UNDEFINED!!\n");
  }
  fprintf(fp,"   Forecast Period 1 = %d\n",pds.usP1);
  fprintf(fp,"   Forecast Period 2 = %d\n",pds.usP2);

/*
*       !Time Range Indicator
*       !Number in Average
*       !Number Missing
*/
  fprintf(fp,"Time Range = %d\n",pds.usTime_range);
  fprintf(fp,"Number in Average = %d\n",pds.usTime_range_avg);
  fprintf(fp,"Number Missing = %d\n",pds.usTime_range_mis);

/*
*       !Decimal Scale Factor
*/
  fprintf(fp,"Decimal Scale Factor = %d\n",pds.sDec_sc_fctr);

/*
*
* A.4   IF (GDS included) THEN
* A.4.1    WRITE Grid Definition Section information to file
*            !Section length
*            !Parm_nv
*            !Parm_pv_pl
*            !Data type
*/
  if(pds.usGds_bms_id >> 7 & 1) {

     fprintf(fp,"\n********* SECTION 2 GDS *********\n");
     fprintf(fp,"Section length = %d\n",gds.head.uslength);
     fprintf(fp,"Parm_nv = %d\n",gds.head.usNum_v);
     fprintf(fp,"Parm_pv_pl = %d\n",gds.head.usPl_Pv);
     fprintf(fp,"Data_type = %d\n",gds.head.usData_type);
   
/*
* A.4.2    SWITCH (Data Type, Table 6)
*                 !  For each Data Type, write the following to file:
*                 !     Number of points along rows/columns of grid
*                 !     Reference Lat/Lon information
*                 !     Resolution and Component Flags (Table 7)
*                 !       Direction increments if given
*                 !       Assumption of Earth shape
*                 !       U&V component orientation
*                 !     Scanning mode flags (Table 8)
*              Default: Projection not supported, exit;
*/
     switch(gds.head.usData_type)
     {

/*
*               Case 0: Latitude/Longitude projection
*/
    case 0:    /* Latitude/Longitude Grid (Equidistant Cylindrical
                  or Plate Carree )         */
      fprintf(fp,"Projection = Latitude/Longitude\n");
      fprintf(fp,"Number of points along a parallel = %d\n",gds.llg.usNi);
      fprintf(fp,"Number of points along a meridian = %d\n",gds.llg.usNj);
      fprintf(fp,"Latitude of first grid point = %.3f deg\n",
      ((float)gds.llg.lLat1)/1000.);
      fprintf(fp,"Longitude of first grid point = %.3f deg\n",
      ((float)gds.llg.lLon1)/1000.);
      fprintf(fp,"Latitude of last grid point = %.3f deg\n",
      ((float)gds.llg.lLat2)/1000.);
      fprintf(fp,"Longitude of last grid point = %.3f deg\n",
      ((float)gds.llg.lLon2)/1000.);

      fprintf(fp,"Resolution and Component Flags: \n");
      if ((gds.llg.usRes_flag >> 7) & 1) {
         fprintf(fp,"    Longitudinal increment = %f deg\n",((float)gds.llg.iDi)/1000.);
         fprintf(fp,"    Latitudinal increment = %f deg\n",((float)gds.llg.iDj)/1000.);
      }else fprintf(fp,"    Direction increments not given.\n");
      if ((gds.llg.usRes_flag >> 6) & 1)
           fprintf(fp,"    Earth assumed oblate spherical.\n");
      else fprintf(fp,"    Earth assumed spherical.\n");
      if ((gds.llg.usRes_flag >> 3) & 1)
           fprintf(fp,"    U&V components resolved relative to +I and "
                   "+J\n");
      else fprintf(fp,"    U&V components resolved relative to east "
                   "and north.\n");

      fprintf(fp,"Scanning Mode Flags: \n");
      if ((gds.llg.usScan_mode >> 7) & 1)
           fprintf(fp,"    Points scan in -I direction.\n");
      else fprintf(fp,"    Points scan in +I direction.\n");
      if ((gds.llg.usScan_mode >> 6) & 1)
           fprintf(fp,"    Points scan in +J direction.\n");
      else fprintf(fp,"    Points scan in -J direction.\n");
      if ((gds.llg.usScan_mode >> 5) & 1)
           fprintf(fp,"    Adjacent points in J direction are "
                   "consecutive.\n");
      else fprintf(fp,"    Adjacent points in I direction are "
                   "consecutive.\n");
      break;

/*
*               Case 1: Mercator Projection
*/
    case 1:    /* Mercator Projection Grid    */
      fprintf(fp,"Projection = Mercator\n");
      fprintf(fp,"Number of points along a parallel = %d\n",gds.merc.cols);
      fprintf(fp,"Number of points along a meridian = %d\n",gds.merc.rows);
      fprintf(fp,"Latitude of first grid point = %.3f deg\n",
      ((float)gds.merc.first_lat)/1000.);
      fprintf(fp,"Longitude of first grid point = %.3f deg\n",
      ((float)gds.merc.first_lon)/1000.);
      fprintf(fp,"Latitude of last grid point = %.3f deg\n",
      ((float)gds.merc.La2)/1000.);
      fprintf(fp,"Longitude of last grid point = %.3f deg\n",
      ((float)gds.merc.Lo2)/1000.);
      fprintf(fp,"Latitude of intersection with Earth = %.3f deg\n",
      ((float)gds.merc.latin)/1000.);

      fprintf(fp,"Resolution and Component Flags: \n");
      if ((gds.merc.usRes_flag >> 7) & 1) {
         fprintf(fp,"    Longitudinal increment = %f deg\n",
	 ((float)gds.merc.lon_inc)/1000.);
         fprintf(fp,"    Latitudinal increment = %f deg\n",
	 ((float)gds.merc.lat_inc)/1000.);
      }else fprintf(fp,"    Direction increments not given.\n");
      if ((gds.merc.usRes_flag >> 6) & 1)
           fprintf(fp,"    Earth assumed oblate spherical.\n");
      else fprintf(fp,"    Earth assumed spherical.\n");
      if ((gds.merc.usRes_flag >> 3) & 1)
           fprintf(fp,"    U&V components resolved relative to +I and "
                   "+J\n");
      else fprintf(fp,"    U&V components resolved relative to east "
                   "and north.\n");

      fprintf(fp,"Scanning Mode Flags: \n");
      if ((gds.merc.usScan_mode >> 7) & 1)
           fprintf(fp,"    Points scan in -I direction.\n");
      else fprintf(fp,"    Points scan in +I direction.\n");
      if ((gds.merc.usScan_mode >> 6) & 1)
           fprintf(fp,"    Points scan in +J direction.\n");
      else fprintf(fp,"    Points scan in -J direction.\n");
      if ((gds.merc.usScan_mode >> 5) & 1)
           fprintf(fp,"    Adjacent points in J direction are "
                   "consecutive.\n");
      else fprintf(fp,"    Adjacent points in I direction are "
                   "consecutive.\n");
      break;

/*
*               Case 3: Lambert Conformal Projection
*/
    case 3:    /* Lambert conformal, secant or tangent, conical or bipolar
                  Projection Grid    */
      fprintf(fp,"Projection = Lambert Conformal\n");
      fprintf(fp,"Number of points along X-axis = %d\n",gds.lam.iNx);
      fprintf(fp,"Number of points along Y-axis = %d\n",gds.lam.iNy);
      fprintf(fp,"Latitude of first grid point = %.3f deg\n",
      ((float)gds.lam.lLat1)/1000.);
      fprintf(fp,"Longitude of first grid point = %.3f deg\n",
      ((float)gds.lam.lLon1)/1000.);
      fprintf(fp,"Orientation of grid = %.3f deg\n",
      ((float)gds.lam.lLon_orient)/1000.);
      fprintf(fp,"First Latitude Cut = %.3f deg\n",
      ((float)gds.lam.lLat_cut1)/1000.);
      fprintf(fp,"Second Latitude Cut = %.3f deg\n",
      ((float)gds.lam.lLat_cut2)/1000.);

      fprintf(fp,"Resolution and Component Flags: \n");
      if ((gds.lam.usRes_flag >> 7) & 1) {
            fprintf(fp,"    X-direction increment = %d meters\n",
            gds.lam.ulDx);
            fprintf(fp,"    Y-direction increment = %d meters\n",
            gds.lam.ulDy);
      }else fprintf(fp,"    Direction increments not given.\n");
      if ((gds.lam.usRes_flag >> 6) & 1)
           fprintf(fp,"    Earth assumed oblate spherical.\n");
      else fprintf(fp,"    Earth assumed spherical.\n");
      if ((gds.lam.usRes_flag >> 3) & 1)
           fprintf(fp,"    U&V components resolved relative to +I and "
                   "+J\n");
      else fprintf(fp,"    U&V components resolved relative to east "
                   "and north.\n");

      fprintf(fp,"Scanning Mode Flags: \n");
      if ((gds.lam.usScan_mode >> 7) & 1)
           fprintf(fp,"    Points scan in -I direction.\n");
      else fprintf(fp,"    Points scan in +I direction.\n");
      if ((gds.lam.usScan_mode >> 6) & 1)
           fprintf(fp,"    Points scan in +J direction.\n");
      else fprintf(fp,"    Points scan in -J direction.\n");
      if ((gds.lam.usScan_mode >> 5) & 1)
           fprintf(fp,"    Adjacent points in J direction are "
                   "consecutive.\n");
      else fprintf(fp,"    Adjacent points in I direction are "
                   "consecutive.\n");
      break;

/*
*               Case 4: Gaussian Latitude/Longitude Projection
*/
    case 4:    /* Gaussian Latitude/Longitude Grid */
      fprintf(fp,"Projection = Gaussian Latitude/Longitude\n");
      fprintf(fp,"Number of points along a parallel = %d\n",gds.llg.usNi);
      fprintf(fp,"Number of points along a meridian = %d\n",gds.llg.usNj);
      fprintf(fp,"Latitude of first grid point = %.3f deg\n",
      ((float)gds.llg.lLat1)/1000.);
      fprintf(fp,"Longitude of first grid point = %.3f deg\n",
      ((float)gds.llg.lLon1)/1000.);
      fprintf(fp,"Latitude of last grid point = %.3f deg\n",
      ((float)gds.llg.lLat2)/1000.);
      fprintf(fp,"Longitude of last grid point = %.3f deg\n",
      ((float)gds.llg.lLon2)/1000.);

      fprintf(fp,"Resolution and Component Flags: \n");
      if ((gds.llg.usRes_flag >> 7) & 1) {
         fprintf(fp,"    i direction increment = %f deg\n",((float)gds.llg.iDi)/1000.);
         fprintf(fp,"    Number of parallels between pole and equator = %d\n",gds.llg.iDj);
      }else fprintf(fp,"    Direction increments not given.\n");
      if ((gds.llg.usRes_flag >> 6) & 1)
           fprintf(fp,"    Earth assumed oblate spherical.\n");
      else fprintf(fp,"    Earth assumed spherical.\n");
      if ((gds.llg.usRes_flag >> 3) & 1)
           fprintf(fp,"    U&V components resolved relative to +I and "
                   "+J\n");
      else fprintf(fp,"    U&V components resolved relative to east "
                   "and north.\n");

      fprintf(fp,"Scanning Mode Flags: \n");
      if ((gds.llg.usScan_mode >> 7) & 1)
           fprintf(fp,"    Points scan in -I direction.\n");
      else fprintf(fp,"    Points scan in +I direction.\n");
      if ((gds.llg.usScan_mode >> 6) & 1)
           fprintf(fp,"    Points scan in +J direction.\n");
      else fprintf(fp,"    Points scan in -J direction.\n");
      if ((gds.llg.usScan_mode >> 5) & 1)
           fprintf(fp,"    Adjacent points in J direction are "
                   "consecutive.\n");
      else fprintf(fp,"    Adjacent points in I direction are "
                   "consecutive.\n");
      break;

/*
*               Case 5: Polar Sterographic Projection
*/
    case 5:    /* Polar Stereographic Projection Grid    */
      fprintf(fp,"Projection = Polar Stereographic\n");
      fprintf(fp,"Number of points along X-axis = %d\n",gds.pol.usNx);
      fprintf(fp,"Number of points along Y-axis = %d\n",gds.pol.usNy);
      fprintf(fp,"Latitude of first grid point = %.3f deg\n",
	((float)gds.pol.lLat1)/1000.);
      fprintf(fp,"Longitude of first grid point = %.3f deg\n",
	((float)gds.pol.lLon1)/1000.);
      fprintf(fp,"Orientation of grid = %.3f deg\n",
	((float)gds.pol.lLon_orient)/1000.);
      fprintf(fp,"Projection Center: ");
      if ((gds.pol.usProj_flag >> 7) & 1)
           fprintf(fp,"South Pole\n");
      else fprintf(fp,"North Pole\n");

      fprintf(fp,"Resolution and Component Flags: \n");
      if ((gds.pol.usRes_flag >> 7) & 1) {
         fprintf(fp,"    X-direction grid length = %d meters\n",gds.pol.ulDx);
         fprintf(fp,"    Y-direction grid length = %d meters\n",gds.pol.ulDy);
      }else fprintf(fp,"    Direction increments not given.\n");
      if ((gds.pol.usRes_flag >> 6) & 1)
           fprintf(fp,"    Earth assumed oblate spherical.\n");
      else fprintf(fp,"    Earth assumed spherical.\n");
      if ((gds.pol.usRes_flag >> 3) & 1)
           fprintf(fp,"    U&V components resolved relative to +I and "
                   "+J\n");
      else fprintf(fp,"    U&V components resolved relative to east "
                   "and north.\n");

      fprintf(fp,"Scanning Mode Flags: \n");
      if ((gds.pol.usScan_mode >> 7) & 1)
           fprintf(fp,"    Points scan in -I direction.\n");
      else fprintf(fp,"    Points scan in +I direction.\n");
      if ((gds.pol.usScan_mode >> 6) & 1)
           fprintf(fp,"    Points scan in +J direction.\n");
      else fprintf(fp,"    Points scan in -J direction.\n");
      if ((gds.pol.usScan_mode >> 5) & 1)
           fprintf(fp,"    Adjacent points in J direction are "
                   "consecutive.\n");
      else fprintf(fp,"    Adjacent points in I direction are "
                   "consecutive.\n");
      break;

    default:   /* no others are currently implemented    */
#ifdef MATLAB_MEX_FILE
		mexErrMsgTxt("This projection is not currently implemented.\n");
#else 
      printf("This projection is not currently implemented.\n");
      exit(0);
#endif

/*
* A.4.2    ENDSWITCH (Data Type)
*/
     } /* Switch */

  } /* gds included */
/*
*
* A.4     ELSE 
*             PRINT no Gds message
* A.4     ENDIF
*/
  else fprintf(fp,"\n******* NO SECTION 2 GDS *********\n" );


/*
*
* A.5   IF (Bitmap Section is present)
*       THEN
*          WRITE Bitmap Section information to file
*       ELSE
*          PRINT no bms mesg
*       ENDIF
*/
  if(pds.usGds_bms_id >> 6 & 1) {
    fprintf(fp,"\n********* SECTION 3 BMS **********\n" );
    fprintf(fp,"Section length = %ld\n", bms.uslength);
    if (bms.uslength <= 6)
      fprintf(fp,"Bitmap is predefined (Not in message).\n");
    else fprintf(fp,"Bitmap is included with message.\n");
    fprintf(fp,"Bitmap ID = %d \n", bms.usBMS_id);
    fprintf(fp,"Number of unused bits = %d\n", bms.usUnused_bits);
    fprintf(fp,"Number of datapoints set = %ld\n", bms.ulbits_set);
  }else{
    fprintf(fp,"\n******* NO SECTION 3 BMS *********\n" );
  }

/*
*
* A.6   WRITE out Binary Data Section Information to file 
*       !Section Length
*/
  fprintf(fp,"\n********* SECTION 4 BDS *********\n" );
  fprintf(fp,"Section length = %ld\n",bds.length);

/*
*       !Table 11 Flags
*/       
  fprintf(fp,"Table 11 Flags:\n");
  if ((bds.usBDS_flag >> 7) & 1)
       fprintf(fp,"    Spherical harmonic coefficients.\n");
  else fprintf(fp,"    Grid-point data.\n");
  if ((bds.usBDS_flag >> 6) & 1)
       fprintf(fp,"    Second-order packing.\n");
  else fprintf(fp,"    Simple Packing.\n");
  if ((bds.usBDS_flag >> 5) & 1)
       fprintf(fp,"    Integer values.\n");
  else fprintf(fp,"    Floating point values.\n");
  if ((bds.usBDS_flag >> 4) & 1)
       fprintf(fp,"    Octet 14 contains additional flag bits.\n");
  else fprintf(fp,"    No additional flags at octet 14.\n");

/*
*       !Decimal Scale Factor (Repeated from PDS)
*/
  fprintf(fp,"\nDecimal Scale Factor = %d\n",pds.sDec_sc_fctr);

/*
*       !Binary Scale Factor
*       !Bit Width
*       !Number of Data Points
*/
  fprintf(fp,"Binary scale factor = %d\n", bds.Bin_sc_fctr);
  fprintf(fp,"Bit width = %d\n", bds.usBit_pack_num);
  fprintf(fp,"Number of data points = %ld\n",bds.ulGrid_size);

/*
* A.6.1   WRITE Data Summary to file
*         !Compute Data Min/Max and Resolution
*/
  dsf = (float) pow( (double) 10, (double) pds.sDec_sc_fctr);
  res = (float) pow((double)2,(double)bds.Bin_sc_fctr) / dsf;
  min = bds.fReference / dsf;
  max = (float) (pow((double)2, (double)bds.usBit_pack_num) - 1);
  max = min + max * res;
  fprintf(fp,"Data Minimum = %f\n", min );
  fprintf(fp,"Data Maximum = %f\n", max );
  fprintf(fp,"Resolution = %f\n",res );

/*
*         !Compute Format Specifier for printing Data
*/
  fd = (int)( -1 * (float) log10((double) res) + .5); 
  if (fd <= 0)
  {
    fd = 0;
    fprintf(fp,"DATA will be displayed as integers (res > 0.1).\n");
  }

/*
*         !WRITE First 100 Data Points to file
*/
  if (bds.ulGrid_size > 1) {
  if (bds.ulGrid_size < 100) numpts = bds.ulGrid_size;
  fprintf(fp,"\nDATA ARRAY: (first %d)\n",numpts);
  for (i=0; i<numpts; i=i+5)
  {
    fprintf(fp, "%02d-  %.*f  %.*f  %.*f  %.*f  %.*f\n",
            i,fd,grib_data[i],fd,grib_data[i+1],fd,
            grib_data[i+2],fd,grib_data[i+3],fd,grib_data[i+4] );
  }
  }

  fprintf (fp,"\n******** END OF MESSAGE *******\n\n");

/*
* 
* A.7   CLOSE file
*/
  fclose (fp);

/*
*
* A.8   DEBUG printing
*/
  DPRINT ("Exiting printer(), no return code\n");

/*
* END OF printer()
*
*
*/
}
