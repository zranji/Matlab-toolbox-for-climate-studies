#ifdef MATLAB_MEX_FILE
#include "mex.h"
#endif
#define       FOPENERR                        100
#define       FWRITERR                        101
#define       MALLOCERR                       102
#define       PACKGRIDERR                     103
#define       FSCANFERR                       104
#define      FCLOSERR                        200
#define BYTE_BIT_CNT   8
#define WORD_BIT_CNT   32

#ifndef DPRINT
#define DPRINT if ( debug ) printf
#endif

#ifndef SEEK_SET
#define SEEK_SET   0                     /* Set file pointer to "offset" */
#endif

typedef struct PDS_INPUT{             /*  User input structure - PDS  */
   unsigned short   uslength;            /* PDS Length - depends on extensions */
   unsigned short   usEd_num;            /* GRIB Edition number - #1 (IndS)  */
   unsigned short   usParm_tbl;          /* Parameter table number (1)    */
   unsigned short   usCenter_id;         /* Id of originating center (Table 0)*/
   unsigned short   usProc_id;           /* Generating process Id number (Table A) */
   unsigned short   usGrid_id;           /* Grid Identification (Table B)  */
   unsigned short   usGds_bms_id;        /* GDS and BMS flag (Table 1)     */
   unsigned short   usParm_id;           /* Parameter and unit id (Table 2) */
   unsigned short   usLevel_id;          /* Type of level or layer id (Table 3/3a) */
   unsigned short   usLevel_octets;      /* number of octets used in Table 3 (0, 1, 2 values) */
   unsigned short   usHeight1;           /* Height1, pressure1,etc of level (Table 3)*/
   unsigned short   usHeight2;           /* Height2, pressure2,etc of level (Table 3)*/
   unsigned short   usYear;              /* Year of century -Initial or ref. */
   unsigned short   usMonth;             /* Month of year   -time of forecast */
   unsigned short   usDay;               /* Day of month                  */
   unsigned short   usHour;              /* Hour of day                   */
   unsigned short   usMinute;            /* Minute of hour                */
   unsigned short   usFcst_unit_id;      /* Forecast time unit (Table 4)  */
   unsigned short   usP1;                /* Period of time (Number of time units)  */
   unsigned short   usP2;                /* Time interval between forecasts  */
   unsigned short   usTime_range;        /* Time range indicator (Table 5)   */
   unsigned short   usTime_range_avg;    /* Number included in average if flag set */
   unsigned short   usTime_range_mis;    /* Number missing from average      */
   unsigned short   usCentury;           /* Centry of Initial time (19)      */
   unsigned short   usZero;              /* Reserved                         */
   short            sDec_sc_fctr;        /* Decimal scale factor             */
   unsigned short   ausZero[12];         /* Reserved                         */
   unsigned short   usCenter_sub;	 /* Sub-Table Entry for originating center (Table 0) */
   unsigned short   usSecond;		 /* Second of Minute	             */
   unsigned short   usTrack_num;	 /* Tracking ID for data set	     */
   unsigned short   usParm_sub;		 /* Sub-Table Entry for parameter and unit (Table 2) */
   unsigned short   usSub_tbl;           /* Sub-Table version number */
   unsigned long    ulMess_Size;
}PDS_INPUT;

typedef struct GDS_LAM_INPUT {         /* Input: Lambert Conformal Grid      */
   unsigned short   usData_type;         /* Data representation type ( Table 6)    */
   int		    iNx;                 /* Nx - # of points along x-axis   */
   int		    iNy;                 /* Ny - # of points along y-axis   */
   long             lLat1;               /* Latitude of first grid point    */
   long             lLon1;               /* Longitude of first grid point   */
   unsigned short   usRes_flag;          /* Resolution and component flag (Table 7)*/
   long             lLon_orient;         /* Orientaion of grid - longitude  */
   unsigned long    ulDx;                /* X-direction grid length         */
   unsigned long    ulDy;                /* Y-direction grid length         */
   unsigned short   usProj_flag;         /* Projection center flag          */
   unsigned short   usScan_mode;         /* Scan mode                       */
   long             lLat_cut1;           /* First latitude which secant cone cuts  */
   long             lLat_cut2;           /* Second latitude from pole       */
   long             lLat_southpole;      /* Latitude of southern pole (millidegree)*/
   long             lLon_southpole;      /* Longitude of southern pole      */
   int		    usZero;              /* Reserved (set to 0)             */
} GDS_LAM_INPUT;

typedef struct GDS_LATLON_INPUT{       /* Input: Latitude/Longitude Grid    */
   unsigned short   usData_type;         /* Data representation type ( Table 6)    */
   int		    usNi;                /* Number of points along a parallel */
   int		    usNj;                /* Number of points along a meridian */
   long             lLat1;               /* Latitude of first grid point      */
   long             lLon1;               /* Longitude of first grid point     */
   unsigned short   usRes_flag;          /* Resolution and component flag (Table 7)*/
   long             lLat2;               /* Latitude of last grid point       */
   long             lLon2;               /* Longitude of last grid point      */
   int              iDi;                 /* I-direction increment             */
   int              iDj;                 /* J-direction increment             */
   unsigned short   usScan_mode;         /* Scanning mode (Table 8)           */
   long		    usZero;              /* Reserved (set to 0)               */
   long             lLat_southpole;      /* Latitude of southern pole (millidegree)*/
   long             lLon_southpole;      /* Longitude of southern pole        */
   long             lRotate;             /* Angle of rotation                 */
   long             lPole_lat;           /* Latitude of pole of stretching (millidegree) */
   long             lPole_lon;           /* Longitude of pole of stretching   */
   long             lStretch;            /* Stretching factor                 */
}GDS_LATLON_INPUT;

typedef struct GDS_PS_INPUT {            /* Input: Polar Stereographic Grid */
   unsigned short   usData_type;         /* Data representation type ( Table 6) */
   unsigned short   usNx;                /* Nx - # of points along x-axis */
   unsigned short   usNy;                /* Ny - # of points along y-axis */
   long             lLat1;               /* Latitude of first grid point */
   long             lLon1;               /* Longitude of first grid point */
   unsigned short   usRes_flag;          /* Resolution and component flag (Table 7) */
   long             lLon_orient;         /* Orientaion of grid - longitude */
   unsigned long    ulDx;                /* X-direction grid length */
   unsigned long    ulDy;                /* Y-direction grid length */
   unsigned short   usProj_flag;         /* Projection center flag */
   unsigned short   usScan_mode;         /* Scan mode */
   unsigned short   usZero;              /* Reserved (set to 0) */
} GDS_PS_INPUT;

typedef struct mercator  /* mercator grids */
   {
   int cols;               /* Ni - Number of points along a latitude circle */
   int rows;               /* Nj - Number of points along a longitude meridian */
   long first_lat;         /* La1 - Latitude of first grid point */
   long first_lon;         /* Lo1 - Longitude of first grid point */
   unsigned short   usRes_flag;  /* Resolution and component flag (Table 7)*/
   long La2;               /* latitude of last grid point, or # point / row */
   long Lo2;               /* longitude of last grid point, or # point / column */
   long latin;             /* Latin - the latitude at which the mercator 
                                      projection intersects the earth */
   unsigned short   usZero1;   /* Reserved (set to 0)                    */
   unsigned short   usScan_mode; /* Scanning mode (Table 8)                */
   float lon_inc;       /* Di - the longitudinal direction increment 
                           (west to east) */
   float lat_inc;       /* Dj - the latitudinal direction increment 
                           (south to north) */
   long             usZero;              /* Reserved (set to 0)                    */
 }mercator;

typedef struct space_view     /* space view perspective or orthographic */
   {
   int cols;            /* Ni - Number of points along x-axis */
   int rows;            /* Nj - Number of points along y-axis */
   long first_lat;     /* La1 - Latitude of sub-satellite point */
   long first_lon;     /* Lo1 - Longitude of sub-satellite point */
   unsigned short   usRes_flag;          /* Resolution and component flag (Table 7)*/
   long x_a_diam;       /* dx - apparent diameter of earth in grid lengths, in x direction */
   long y_a_diam;       /* dy - apparent diameter of earth in grid lengths, in y direction */
   int x_ssp;           /* Xp - X-coordinate of sub satellite point */
   int y_ssp;           /* Yp - Y-coordinate of sub satellite point */
   unsigned short   usScan_mode;         /* Scanning mode (Table 8)                */
   long orientation;    /* orientation of the grid */
   long altitude;      /* altitude of the camera from the earth's center */
   int 		iXo;	/* X coordinate of origin of sector image */
   int 		iYo;	/* Y coordinate of origin of sector image */
   char		cszero[6];	/* Reserved zero */
 }space_view;

typedef struct BDS_HEAD_INPUT {          /* BDS Header Input                */
   unsigned long    length;              /* BDS Length */
   unsigned short   usBDS_flag;          /* BDS flag (Table 11)                    */
   int              Bin_sc_fctr;         /* Binary scale factor                    */
   float            fReference;          /* Reference value (minimum value)        */
   unsigned short   usBit_pack_num;      /* Number of bits into which data is packed*/
   unsigned long    ulGrid_size;         /* Number of grid points                  */
   float            fPack_null;          /* Pack_null value for packing data       */
}BDS_HEAD_INPUT;

typedef struct GDS_HEAD_INPUT {        /* GDS Header Input                */
   unsigned short   usNum_v;             /* Number of vertical cords   */
   unsigned short   usPl_Pv;             /* PV or PL location  */
   unsigned short   usData_type;         /* Data representation type (Table 6)     */
   unsigned short   uslength;            /* GDS Length - depends on projection */
}GDS_HEAD_INPUT;

typedef struct IDS_GRIB {              /* IDS -Indicator Section 0               */
   unsigned char   szId[4];              /* "GRIB" Identifier                      */
   unsigned char   achTtl_length[3];     /* Total length of GRIB msg               */
   unsigned char   chEd_num;             /* GRIB Edition number  - #1              */
} IDS_GRIB;

typedef struct PDS_GRIB {              /* PDS -Product Definition Section 1       */
   unsigned char    achPDS_length[3];    /* Section length (in octets)             */
   unsigned char    chParm_tbl;          /* Parameter table number (1)             */
   unsigned char    chCenter_id;         /* Id of originating center (Table 0)     */
   unsigned char    chProc_id;           /* Generating process Id number (Table A) */
   unsigned char    chGrid_id;           /* Grid Identification (Table B)          */
   unsigned char    chGds_bms_id;        /* GDS and BMS flag (Table 1)             */
   unsigned char    chParm_id;           /* Parameter and unit id (Table 2)        */
   unsigned char    chLevel_id;          /* Type of level or layer id (Table 3/3a) */
   unsigned char    achHeight[2];        /* Height, pressure,etc of level (Table 3)*/
   unsigned char    chYear;              /* Year of century     -Initial or ref.   */
   unsigned char    chMonth;             /* Month of year       -time of forecast  */
   unsigned char    chDay;               /* Day of month                           */
   unsigned char    chHour;              /* Hour of day                            */
   unsigned char    chMinute;            /* Minute of hour                         */
   unsigned char    chFcst_unit_id;      /* Forecast time unit (Table 4)           */
   unsigned char    chP1;                /* Period of time (Number of time units)  */
   unsigned char    chP2;                /* Time interval between forecasts        */
   unsigned char    chTime_range;        /* Time range indicator (Table 5)         */
   unsigned char    achTime_range_avg[2]; /* Number included in average if flag set */
   unsigned char    chTime_range_mis;    /* Number missing from average            */
   unsigned char    chCentury;           /* Centry of Initial time (19)            */
   unsigned char    chZero;              /* Reserved                               */
   unsigned char    achDec_sc_fctr[2];   /* Decimal scale factor                   */
   unsigned char    achZero[12];         /* Reserved                               */
   unsigned char    chCenter_sub;        /* Sub-Table entry for originating center (Table 0) */
   unsigned char    chSecond;            /* Second of Minute                       */
   unsigned char    chTrack_num[2];         /* Tracking ID for data set               */
   unsigned char    chParm_sub;          /* Sub-Table Entry for parameter and unit (Table 2) */
   unsigned char    chSub_tbl;           /* Sub-Table Version number */
} PDS_GRIB;

typedef struct GDS_HEAD {              /* GDS header                              */
   unsigned char    achGDS_length[3];    /* Section length (in octets)             */
   unsigned char    chNV;                /* # of vertical coord. parameters (not used)*/
   unsigned char    chPV;                /* Location of vert. coord., 255 if none  */ 
   unsigned char    chData_type;         /* Data representation type (Table 6)     */
} GDS_HEAD;

typedef struct LAMBERT {               /* Lambert Conformal Grid                  */
   unsigned char    achNx[2];                /* Nx - # of points along x-axis          */
   unsigned char    achNy[2];                /* Ny - # of points along y-axis          */
   unsigned char    achLat1[3];          /* Latitude of first grid point           */
   unsigned char    achLon1[3];          /* Longitude of first grid point          */
   unsigned char    chRes_flag;          /* Resolution and component flag (Table 7)*/
   unsigned char    achLon_orient[3];    /* Orientaion of grid - longitude         */
   unsigned char    achDx[3];            /* X-direction grid length                */
   unsigned char    achDy[3];            /* Y-direction grid length                */
   unsigned char    chProj_flag;         /* Projection center flag                 */
   unsigned char    chScan_mode;         /* Scan mode                              */
   unsigned char    achLat_cut1[3];      /* First latitude which secant cone cuts  */
   unsigned char    achLat_cut2[3];      /* Second latitude from pole              */
   unsigned char    achLat_southpole[3]; /* Latitude of southern pole (millidegree)*/
   unsigned char    achLon_southpole[3]; /* Longitude of southern pole             */
   unsigned char    achZero[2];              /* Reserved (set to 0)                    */
} LAMBERT;

typedef struct POLAR {                   /* Polar Stereographic Grid */
   unsigned short   usNx;                /* Nx - # of points along x-axis */
   unsigned short   usNy;                /* Ny - # of points along y-axis */
   unsigned char    achLat1[3];          /* Latitude of first grid point */
   unsigned char    achLon1[3];          /* Longitude of first grid point */
   unsigned char    chRes_flag;          /* Resolution and component flag (Table 7) */
   unsigned char    achLon_orient[3];    /* Orientaion of grid - longitude */
   unsigned char    achDx[3];            /* X-direction grid length */
   unsigned char    achDy[3];            /* Y-direction grid length */
   unsigned char    chProj_flag;         /* Projection center flag */
   unsigned char    chScan_mode;         /* Scan mode */
   unsigned short   usZero;              /* Reserved (set to 0) */
} POLAR;

typedef struct LATLON {                  /* Input: Latitude/Longitude Grid          */
   unsigned short   usNi;                /* Number of points along a parallel      */
   unsigned short   usNj;                /* Number of points along a meridian      */
   unsigned char    achLat1[3];          /* Latitude of first grid point           */
   unsigned char    achLon1[3];          /* Longitude of first grid point          */
   unsigned char    chRes_flag;          /* Resolution and component flag (Table 7)*/
   unsigned char    achLat2[3];          /* Latitude of last grid point            */
   unsigned char    achLon2[3];          /* Longitude of last grid point           */
   unsigned char    usDi[2];             /* I-direction increment                  */
   unsigned char    usDj[2];             /* J-direction increment                  */
   unsigned char    chScan_mode;         /* Scanning mode (Table 8)                */
   unsigned short   usZero;              /* Reserved (set to 0)                    */
   unsigned char    achLat_southpole[3]; /* Latitude of southern pole (millidegree)*/
   unsigned char    achLon_southpole[3]; /* Longitude of southern pole             */
   unsigned char    achRotate[4];        /* Angle of rotation                      */
   unsigned char    achPole_lat[3];      /* Latitude of pole of stretching (millidegree) */
   unsigned char    achPole_lon[3];      /* Longitude of pole of stretching        */
   unsigned char    achStretch[4];       /* Stretching factor                      */
} LATLON;

typedef struct BDS_HEAD {                /* Binary Data Section 4                     */
   unsigned char    achBDS_length[3];    /* Section length                         */
   unsigned char    chBDS_flag;          /* Flag (Table 11)                        */
   unsigned char    achBin_sc_fctr[2];   /* Binary Scale Factor                    */
   unsigned char    achReference[4];     /* Reference value (minimum value)IBM format*/
   unsigned char    chBit_pack_num;      /* Number of bits into which data is packed*/
} BDS_HEAD;

typedef struct EDS_GRIB {                /* End Section 5                           */
   unsigned char    szEDS_id[4];         /* "7777" Ascii characters                */
} EDS_GRIB;

typedef struct grid_desc_sec     /* Grid Description Section */
{
  struct GDS_HEAD_INPUT head;    /* GDS Header section - common to all */
  struct GDS_LATLON_INPUT llg;   /* Latitude/Longitude or Gaussian grids */
  struct GDS_LAM_INPUT lam;      /* lambert conformal grids */
   struct GDS_PS_INPUT pol;      /* polar stereographic grids */
   struct mercator merc;         /* mercator grids */
   struct space_view svw;        /* space view perspective or orthographic */
}grid_desc_sec;

typedef struct BMS_GRIB 		/* Bit Map Section 3 			*/
{
  unsigned char	 achBMS_length[3];	/* Section length			*/
  unsigned char	 chUnused_bits;		/* #unused bits in bitmap stream	*/
  unsigned char  achBMS_id[2];		/* 0 or a predefined bitmap id		*/
} BMS_GRIB;

typedef struct BMS_INPUT	/* User Input structure - BMS */
{
  unsigned short uslength;	/* section length */
  unsigned short usUnused_bits;	/* number of Unused bits */
  unsigned short usBMS_id;	/* 0 or a predefined id  */
  unsigned long  ulbits_set;	/* num of datapts present */
  char		*bit_map;	/* pts to beg. of BM bstream */
} BMS_INPUT;

