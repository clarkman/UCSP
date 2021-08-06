function [chan, ch] = getCh( pObj )

fullChan = pObj.DataCommon.channel;
chan = fullChan(end);
ch = sscanf( chan, '%d');