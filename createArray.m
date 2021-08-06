function arr = createArray( numRows, arrayType )
% Create data array given type
% double | int16 | int32 | int64 | int8 | intmax | intmin | single | uint16 | uint32 | uint64 | uint8


switch arrayType
    case { '%s', 'h16', 'float' }
        arr = cell(numRows,1);
        return
    case { '%d', 'sst' } 
        dataType = 'int32';
    case '%u' 
        dataType = 'uint32';
    case '%ld' 
        dataType = 'int64';
    case '%lu' 
        dataType = 'uint64';
    case { '%g', '%f', '%e', 'dn', 'lv', 'bool' } 
        dataType = 'double';
    otherwise
        error('Unexpected arrayType type. Only %d, %u, %ld, %lu, %g, %e, %f, dn, lv, h16, float, and %s are supported so far.')
end

arr = zeros( numRows, 1, dataType );
