function [ out ] = convertVal( inp, fmt )
%CONVERTVAL Convert string to number with specified format
%   Works with pluckArray and readLabeledCSV

%display( [ 'Converting: ', inp, ' with: ' fmt ] )

switch lower( fmt )
  case 'dn'
    out = convertSQLTime( inp );
  case 'lv'
    out = convertLabviewTime( inp );
  case 'bool'
    out = convertBool( inp );
  case 'h16'
    out = convertHex16( inp, 2 );
  case 'float'
    out = convertFloat( inp );
  case 'sst'
    out = convertSST( inp );
  otherwise % Matlab defaults
    out = sscanf(inp,fmt);
end

end

function out = convertSST( inp )
    % Following -9999 tradition
    if strcmpi( inp, 'null')
        out = -9999;
    else
        out = sscanf(inp,'%d');
    end
end

function out = convertLabviewTime( inp )
    offset = datenum('01/01/1904 00:00:00.000');
    inpVals = sscanf( inp, '%g' );
    inpDays = inpVals / 86400;
    out = offset + inpDays;
end

function out = convertSQLTime( inp )
    inds = strfind(inp,':'); % Coreection from iLogger
    if length(inds) == 3
        inp(inds(3))='.';
    end
    out = datenum( inp );
end

function out = convertBool( inp )
    if strcmp( lower(inp), 'true' )
        out = double(1);
    elseif strcmp( lower(inp), 'false' )
        out = double(0);
    else
        error([ 'Bogus bool: ', inp ] )
    end
end

function out = convertHex16( inp, len )
    numChars = numel(inp);
    if( numChars ~= length(inp) )
        error('function convertHex16 only works with one dimensional arrays.')
    end
    if( inp(1) == '0' && inp(2) == 'x' ) % Skip '0x'
        s = 3;
        numChars = numChars - 2;
    else
        s = 1;
    end
    if( mod(numChars,len) ~= 0 )
        error('function convertHex16 only accepts inputs with lengths divisible by four')
    end
    valStrs = inp(s:end);
    numVals = length(valStrs) / len;
    vals = zeros(numVals,1);
    for v = 0 : numVals - 1
        valStr = valStrs(v*len+1:(v+1)*len);
        val = sscanf(valStr,'%hx');
        if( val > 127 )
            vals(v+1) = val - 128; 
        else
            vals(v+1) = val;
        end
    end
    vals = vals - 128;
    vals = vals * -1;
    out = vals;
end

function out = convertFloat( inp )
    len = 8;
    numChars = numel(inp);
    if( numChars ~= length(inp) )
        error('function convertFloat only works with one dimensional arrays.')
    end
    if( inp(1) == '0' && inp(2) == 'x' ) % Skip '0x'
        s = 3;
        numChars = numChars - 2;
    else
        s = 1;
    end
    if( mod(numChars,len) ~= 0 )
        error('function convertFloat only accepts inputs with lengths divisible by 8')
    end
    valStrs = inp(s:end);
    numVals = length(valStrs) / len
    vals = zeros(numVals,1);
    for v = 0 : numVals - 1
        valStr = valStrs(v*len+1:(v+1)*len)
        valStr = [ valStr(5:8), valStr(1:4) ]
        return
        vals(v+1) = sscanf(valStr,'%x');
    end
    out = vals;
end
