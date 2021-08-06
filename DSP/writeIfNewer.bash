#! /bin/bash

#
# Checks dependencies for file write.  Requires at least
# two arguments in order to act, but will accept up to 100.
# The last argument ($#) is the target file.  All arguments
# preceding it must be filenames of existing files or directories.
# These are called input files.  Thus if the script runs there
# is one target, and at least one input file.  Therefore 
#
#  result = 0-N : The count of input files that are newer than target
#  result =  -1 : The target file does not yet exist.
#  result =  -2 : Usage error or other error
#
# The technique used is to write the file to a local tmp location, then 
# copy it to its destination on the server.  An MD5Sum then confirms the
# write. Called by writeForce.m



# Usage checks
if [ $# -lt 2 ]
then
    echo "Too few arguments" 
    exit -2
fi
# Target name acquisition
declare -i ARG_COUNT=0;
for argth in $*
do
   target=$argth;
   ARG_COUNT=$ARG_COUNT+1;
done
declare -i INPUT_FILE_COUNT=0;
INPUT_FILE_COUNT=$ARG_COUNT-1;
# Target/inputFile match check
ARG_COUNT=0;
for argth in $*
do
   ARG_COUNT=$ARG_COUNT+1;
   if [ $ARG_COUNT -gt $INPUT_FILE_COUNT ]
   then
       break; # Done.
   fi
   if [ $target == $argth ]
   then
       echo "One of the input files is identical to the target";
       exit -2
   fi
done


# Check out the target
declare -i TARG_DATE=0;
ARG_COUNT=0;
if [ -f $target -o -d $target ]
then
    TARG_DATE=`stat -c %Y $target`
else
    #echo "The target file does not yet exist"
    exit -1
fi



# Check out the target' viability
declare -i TARGET_STATUS=0;
$QFDC_ROOT/tools/DSP/writeForce.bash $target
TARGET_STATUS=`echo $?`
if [ $TARGET_STATUS -le 0 ]
then
    echo "Script error: The target file does not yet exist should already BE?!?"
    echo "              Or write error ..."
    exit -2
fi



# Time Checks
declare -i NEWER_COUNT=0;
declare -i NEXT_DATE=0;
ARG_COUNT=0;
for argth in $*
do
   ARG_COUNT=$ARG_COUNT+1;
   if [ $ARG_COUNT -gt $INPUT_FILE_COUNT ]
   then
       break; # Done.
   fi
   if [ -f $argth -o -d $argth ]
   then
       NEXT_DATE=`stat -c %Y $argth`
       if [ $NEXT_DATE -gt $TARG_DATE ]
       then
           NEWER_COUNT=$NEWER_COUNT+1;
       fi
   fi
done

exit $NEWER_COUNT
