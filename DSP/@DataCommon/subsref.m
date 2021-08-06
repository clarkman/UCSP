function b = subsref(a,index)
%SUBSREF Define field name indexing for DataCommon objects

switch index.type
case '()'
    error('Array indexing not supported by DataCommon objects')
    
case '.'
    switch index.subs
    case 'source'
        b = a.source;
    case 'title'
        b = a.title;
    case 'network'
        b = a.network;
    case 'station'
        b = a.station;
    case 'channel'
        b = a.channel;
    case 'UTCref'
        b = a.UTCref;
    case 'timeOffset'
        b = a.timeOffset;
    case 'timeEnd'
        b = a.timeEnd;
    case 'history'
        b = a.history;
    otherwise
        error('Invalid field name')
    end
case '{}'
    error('Cell array indexing not supported by DataCommon objects')
end
