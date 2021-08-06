#! /bin/bash

#
# Test forcing a file to be written.  Returns a code to indicate what happened.
#
#  result =  0: file can be written
#  result =  1: file exists and can be written over
#  result = -1: write failed.
#  result = -2: tmpFile write failed. (Uses $HOME/tmp)
#
# The technique used is to write the file to a local tmp location, then 
# copy it to its destination on the server.  An MD5Sum then confirms the
# write. Called by writeForce.m



# Test args
if [ -z $1 ]
then
    echo "Empty arg passed"
    exit -1
fi
if [ -d $1 ]
then
    echo "File: "$1" exists and is a directory"
    exit -1
fi

# Sense whether file exists
if [ -f $1 ]
then
    extant=1;
    if [ -w $1 ]
    then
        :
    else
        echo "File: "$1" exists and is not writeable"
        exit -1
    fi
else
    extant=0;
fi

# Check to ensure tmp write location exists
tmpLocation=$HOME/tmp
if [ -d $tmpLocation ]
then
    :
else
    echo "tmpFile directory does not exist"
    exit -2
fi


tmpFile=$tmpLocation/tmpFile.$$
echo "Probing write with ME ....  (From DSP/writeForce.bash)" > $tmpFile
if [ -f $tmpFile ]
then
    :
else
    echo "tmpFile could not be written"
    exit -2
fi


if [ $extant == 1 ] 
then
    targetFile=$1.$$
else
    targetFile=$1
fi

if cp $tmpFile $targetFile
then
    :
else
    echo "Write to $targetFile failed"
    rm $tmpFile # Cleanup
    exit -1;
fi
if [ -f $targetFile ] # Alms for the samba paranoid
then
    :
else
    echo "$targetFile could not be written"
    rm $tmpFile # Cleanup
    exit -1
fi
if [ -s $targetFile ]
then
    :
else
    echo "$targetFile could not be written"
    rm $tmpFile # Cleanup
    rm $targetFile # Cleanup
    exit -1
fi

LOCAL_MD5SUM=`md5sum $tmpFile | awk '{print $1}'`
TARGET_MD5SUM=`md5sum $targetFile | awk '{print $1}'`
if [ $TARGET_MD5SUM != $LOCAL_MD5SUM ]
then
    echo "MD5Sum failure"
    rm $tmpFile # Cleanup
    rm $targetFile # Cleanup
    exit -1
fi

rm $tmpFile

if [ $extant == 1 ]
then
    exit 1
else
    rm $targetFile
    exit 0
fi

