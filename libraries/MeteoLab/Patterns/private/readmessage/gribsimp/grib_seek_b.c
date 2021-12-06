#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "grib.h"

extern int debug;       /* for dPRINT */
void gbyte (char *inchar, unsigned long *iout, unsigned long *iskip, 
		unsigned long nbits);

/*
* =====================================================================
* C.  FUNCTION: grib_seek ()
*     PURPOSE : search the input file for a GRIB message;
*
*     INPUT   : 
*       InFile      input file name
*       curr_ptr    pointer to start of a valid message
*       offset      holds #bytes to skip from the beginning of file
*       msg_length  length of message found.  0 if no message
*
*     RETURN CODE:  
*      0> no errors, may or may not have a valid message;
*         if (msg_len == 0) means that message found was not at
*         the expected offset which came from the Index file;
*         if (msg_len > 0)  message is found and at the expected 
*         offset if the Index file is used;  ptr is returned pointing 
*         to the block holding entire msg;  msg_length now holds 
*         length of entire message;
*      1> fseek error
*      2> malloc error
*      3> got end of file
* =====================================================================
*/

static FILE  *FPGRIB=NULL;
static char  *OLDFILE=NULL;
int grib_seek (char *InFile, char **curr_ptr, long *offset, unsigned long *msg_length)
{
   char  *GG, sm_blk[1004], *fwa_msg=NULL;
   unsigned long lMessageSize;
   long pos = *offset;  /* byte offs fr. beg. of file */
   int bytenum;         /* Index w/in sm_blk */
   int bytestoread=1004; /* #bytes to read into sm_blk at a time */
   int check_limit;     /* #bytes in sm_blk to check */ 
   int gotone;		/* set if found good msg */
   int nread;           /* #bytes got back from Read */
   int escape=0;        /* set for a quick exit */
   int status;
   long iskip;           /* for getbyte */

   DPRINT ("\nEntering grib_seek to search for Message\n");
/*
* C.1       INIT variables
*           !message len to zero, curr_ptr to NULL 
*           !status to success
*/
   status=0;
   *msg_length=0L;
   *curr_ptr= NULL;

/*
*
* C.2       OPEN Input file      !exit on error
*/

   if((OLDFILE==NULL) || (strcmp(InFile,OLDFILE)!=0)){
	   if(OLDFILE==NULL) {
		   OLDFILE=(char *)malloc(sizeof(char)*(strlen(InFile)+1));
	   }else if(strlen(InFile)>strlen(OLDFILE)){
			OLDFILE=(char *)realloc(OLDFILE,sizeof(char)*(strlen(InFile)+1));
	   }
	   strcpy(OLDFILE,InFile);
	   if(FPGRIB !=NULL) fclose(FPGRIB);
	   if ((FPGRIB = fopen (OLDFILE, "rb")) == NULL) {
#ifdef MATLAB_MEX_FILE
		   mexErrMsgTxt("Cannot open input file:\n");
#else 
		   fprintf (stderr,"Cannot open input file: %s.\n",InFile );
		   exit (0);
#endif
	   }   
   }
   


/*
*
* C.3       FOR (loop while no error, reading a block at a time)
*/
   
   for (gotone= 0; status == 0; pos += check_limit)
   {
/*
* C.3.1        IF (cannot SET file position to correct place)
*              THEN
*                 SET status to 1 !fseek err
*                 CONTINUE (Loop around to C.3)
*              ENDIF
*/
     if (fseek(FPGRIB, pos, SEEK_SET)!=0) { 
	DPRINT ("Got an fseek error to pos=%ld\n", pos); 
	status= 1; continue; }

/*
* C.3.2        IF (cannot READ more than 4 bytes)
*              THEN
*                 SET status to 3 !end of file
*                 CONTINUE (Loop around to C.3)
*              ELSE
*                 SET #bytes to check 4 bytes less than array size
*              ENDIF
*/
     nread= fread (sm_blk,sizeof(char), bytestoread,FPGRIB);
     if (nread <= 40) 
	{ 
	  if (nread==4)
	    DPRINT ("No bytes left to check for msg;\n"); 
	  else
	    DPRINT ("Only read %d bytes, too few to check for msg;\n",nread); 
	  status= 3; 
	  continue; 
	}
     else check_limit= nread - 4; 

/*
* C.3.3        WHILE (there is a 'G' in this block) DO
*/
     while ((GG= (char *) memchr (sm_blk, 'G', check_limit)) !=NULL)
	{
/*
* C.3.3.1           IF ('RIB' is not after 'G') THEN
*                    CLEAR out the 'G' in temp block
*                    CONTINUE  !Loop around to C.3.3
*                 ENDIF
*/
	   if (strncmp(GG, "GRIB",4)) {
		*GG='-';   /* no RIB after G, clear it */
		continue;  /* let Memchr find next G      */
		}

/*
* C.3.3.2           CALCULATE byte position within this block
*                             where this message begins
*/
	   bytenum = GG - sm_blk;  /* byte pos w/in this block */
	    
/*
* C.3.3.3           !MATCHED "GRIB"
*/
	  DPRINT ("Found string 'GRIB' at %ld\n", pos+bytenum);

/*
* C.3.3.4          FUNCTION gbyte !extract lMessageSize
*/
	  iskip=32;
          gbyte (sm_blk+bytenum ,&lMessageSize, &iskip,24);
          DPRINT ("lMessageSize\n");


/*
* C.3.3.5          IF (cannot MOVE ptr to start of the message) THEN
*                     SET status to 1
*                     CONTINUE
*                  ENDIF
*/
          if (fseek(FPGRIB, (long)(pos+bytenum), SEEK_SET)!=0) {
		DPRINT ("Got fseek error to pos+bytenum= %ld\n", pos+bytenum);
		status= 1;
		continue;
		}

/*
* C.3.3.6          IF (cannot ALLOCATE space to hold entire message) THEN
*                     SET status to 2
*                     CONTINUE
*                  ENDIF
*/
	  if ((fwa_msg = (char*) malloc(lMessageSize))==NULL) {
		DPRINT ("Malloc fwa_msg failed on size %d\n", lMessageSize);
		status= 2;
		continue;
		}
/*
* C.3.3.7          IF (successfully READ in entire message AND
*                      '7777' is where expected) THEN
*                      SET gotone flag
*                      BREAK   !skip checking rest of this block 
*                  ENDIF
*/
          if (fread (fwa_msg, lMessageSize, 1, FPGRIB) == 1  &&
             !strncmp((fwa_msg + lMessageSize - 4),"7777",4)) 
	     {  
		DPRINT ("Found string '7777' where expected\n");
	    	gotone=1;   /* found message */
		break;      /* so skip checking rest of block */
	     }
     	       
/*
* C.3.3.8          IF (unused block is still defined) THEN  
*                     FREE it up   !not valid message, so let it go
*                  ENDIF
*/      
          if (fwa_msg!=NULL) { free (fwa_msg); fwa_msg= NULL; }

/*
* C.3.3.9          CLEAR out 'G' in tmp block 
*/
	  *GG='-';    /* let Memchr find next 'G' in curr. block */
	  DPRINT ("'GRIB' at location %ld is not a valid message\n",
	  bytenum+pos);

/*
* C.3.3         ENDWHILE 
*/
     }  /* WHILE seeing 'G'*/

/*
* C.3.4         IF (Quick escape is needed OR actually Got a message) THEN
*                   BREAK   ! stop processing file
* C.3.5         ELSE        ! no msg found in this block
*                   DEBUG printing
*               ENDIF
*/
     if (escape== 1 || gotone) break;
     else DPRINT ("No Section 0 found between address %ld and %ld\n", 
	  pos, pos+check_limit);
/*
*
* C.3       ENDFOR    !until status changes
*/
  }  /* check entire file */


/*
*
* C.4        CLOSE input file;     !get here when found no messages
*
*/
/*   fclose(FPGRIB); */

/*	
* C.5        IF (got a message) THEN
*                UPDATE offset where to start searching for next message
*                UPDATE global variable msg_length
*                UPDATE curr_ptr to beginning of fwa_msg w/ message
*                !status is still 0, accept this message
*/
   if (gotone) 
	{
 	*offset = (long)(pos+bytenum);  /* return w/ new offset */
	*msg_length = lMessageSize;     /* return w/ new mesg len */
        *curr_ptr= fwa_msg; 		  /* with block w/message  */
	DPRINT ("Exiting grib_seek w/status=%d, message found\n", status);
	}
/*
*            ELSE
*               FREE up unused block  !no message found
*               DEBUG printing
*               !status is not good;
*            ENDIF
   else {
	if (fwa_msg != NULL) free(fwa_msg);
	DPRINT ("Exiting grib_seek  w/status=%d, no messages\n", status);
	}

/*
* C.7        RETURN with status 
*/
   return (status); 

/*
*
* END OF FUNCTION
*
*/
}
