function outObj = assign(inObj,sta,ch)
%  $Id: assign.m,v d4e01bc08f7c 2013/10/28 18:54:34 qcvs $


[staNum,sid] = makeSid(sta);
staInfo = getStaInfo(sta);
[chan,ch] = makeCh(ch);

outObj = inObj;
outObj.DataCommon.network='CMN';
outObj.DataCommon.station=staNum;
outObj.DataCommon.channel=['CHANNEL',chan];
outObj.DataCommon.title=staInfo.file_name{1};
