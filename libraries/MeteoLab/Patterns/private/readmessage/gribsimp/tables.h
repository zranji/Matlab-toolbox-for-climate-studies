/* HEADER FILE FOR THE TABLES USED IN GRIB */

#ifndef TABLES_H
#define TABLES_H

#define NPARM 256
#define NLEV 256
#define NGEOM 256
#define NMODEL 256
#define NOCTR 256

/* structure for table 2 variables, and sub-tables */
typedef struct table2{
  char   field_param[75];   /* field parameter -   2nd column */
  char   unit[25];          /* units -             3rd column */

  struct table2 *sub_tab2;  /* pointer to sub-table */
}table2;

/* structure for table 3 variables */
typedef struct{
  char   meaning[100];      /* meaning of code figure -       2nd column */
  char   contents1[100];     /* contents of octets 11 & 12 -   3rd column */
  char   contents2[100];     /* contents of octets 11 & 12 -   3rd column */
  int    num_octets;        /* number of octets used for
                               each definition of contents -  4th column */
}table3;

/* define strycture for ORIG_CENTER_ID, MODEL_ID and GEOM_ID arrays */
typedef struct{
   char  orig_ctr[NOCTR][61];
   char  geom_name[NGEOM][61];
   char  model[NMODEL][61];

}tables;

#endif
