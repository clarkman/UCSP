function [ tdObj, inds, tPeriods ] = makeTimeSeries( obj, tPer, ovlpFactor, dnRange )

[ inds, tPeriods ] = countEvents( obj, tPer, ovlpFactor, dnRange );

tdObj = TimeData;
tdObj.DataCommon = obj.DataCommon;
% Hours to seconds
tdObj.sampleRate = ovlpFactor / tPer / 3600;
