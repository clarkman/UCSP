function a = subsasgn(a,index,val)
% SUBSASGN Define index assignment for DataCOmmon objects
switch index.type
case '()'
    error('Array indexing not supported by DataCommon objects')
    
case '.'
    switch index.subs
    case 'source'
        a.source = val;
    case 'title'
        a.title = val;
    case 'network'
        a.network = val;
    case 'station'
        a.station = val;
    case 'channel'
        a.channel = val;
    case 'UTCref'
        if isa(val, 'char')
            % convert the string to a datenum
            a.UTCref = str2datenum(val);
        elseif isa(val, 'numeric')
            a.UTCref = val;
        else
            error(' Setting UTCref to an invalid type');
        end
    case 'timeOffset'
        a.timeOffset = val;
    case 'timeEnd'
        a.timeEnd = val;
    case 'history'
        a.history = val;
    otherwise
        error('Invalid field name')
    end
    
case '{}'
    error('Cell array indexing not supported by DataCommon objects')
end
