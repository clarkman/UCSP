#include <stdlib.h>
#include <stdarg.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <time.h>
#include <math.h>

#include "mex.h"

#define MAX_STR 29
#define SQL_STR 19

#define TT_BASE 719529.0

/*#define QFDEBUG*/

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{   
   double dn;
   struct tm tms;
   char sqlt[MAX_STR+1], *sqlFract;
   int  timeLen;
   double fract, tsecs;

   #ifdef QFDEBUG
   /* Check proper input and output */
    if( nrhs != 1 )
        mexErrMsgTxt( "One input required.\n  USAGE:: dn = sql2datenum( 'YYYY-MM-DD HH:MM:SS.FFFFFF' )" );
    if( mxIsChar( prhs[0] ) != 1 )
      mexErrMsgTxt("Input sql time must be a string.");
   #endif

    timeLen = mxGetNumberOfElements(prhs[0]);

   #ifdef QFDEBUG
    if( timeLen < SQL_STR )
        mexErrMsgTxt( "Malformed sql time! must be at least:  YYYY-MM-DD HH:MM:SS )" );  
    if( timeLen > MAX_STR )
        mexErrMsgTxt( "Malformed sql time! must be at most:  YYYY-MM-DD HH:MM:SS.123456789 )" );  
   #endif

    if( mxGetString( prhs[0], sqlt, timeLen+1 ) )
        mexErrMsgTxt( "Chicked on sql time. must be at least:  YYYY-MM-DD HH:MM:SS )" );

    sqlFract = strptime( sqlt, "%F %T", &tms );
    if( !sqlFract )
        mexErrMsgTxt( "Malformed sql time!" );  
    tsecs = (double)mktime( &tms );
    tsecs += atof(sqlFract);
    dn = TT_BASE + tsecs/86400.0;
    
   #ifdef QFDEBUG
    fprintf( stderr, "\nstrlen = %ld, sqlt=%s\n", strlen(sqlt), sqlt );
    fprintf( stderr, "tm_year=%d, tm_mon=%d, tm_mday=%d tm_hour=%d, tm_min=%d, tm_sec=%d \n", 
                      tms.tm_year, tms.tm_mon, tms.tm_mday, tms.tm_hour, tms.tm_min, tms.tm_sec );
    fprintf( stderr, "tsecs=%lf\n", tsecs );
   #endif

    plhs[0] = mxCreateDoubleMatrix(1, 1, mxREAL);
    double *yp = mxGetPr(plhs[0]);
    *yp = dn;

}

