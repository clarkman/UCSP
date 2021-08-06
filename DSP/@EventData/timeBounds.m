function [ begDN, finDN ] = timeBounds( obj )
% Count events base on time in col 1.
% tPer must be in hours
% ovlpFactor is denominator, ie. 1/4 means 75% overlap
% hourBounds are optional and in 0-23 format

obj = updateTimes( obj );

begDN = obj.DataCommon.UTCref;
finDN = begDN + obj.DataCommon.timeEnd / 86400;
