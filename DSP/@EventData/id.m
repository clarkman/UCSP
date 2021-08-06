function [staNum,chan] = id(obj)

staNum = obj.DataCommon.station;
sz=size( staNum );
if( sz(2) > 1 )
  chan = obj.DataCommon.channel;
  chan = chan(end:end);
else
  chan=[];
end
	