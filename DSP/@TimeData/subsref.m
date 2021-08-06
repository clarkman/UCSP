function b = subsref(a,index)
%
%SUBSREF Define field name indexing for TimeData objects
switch index.type
case '()'
    % Treat indexing as direct access to the samples
    b = a.samples( index.subs{:} );
    
case '.'
    switch index.subs
    case 'sampleRate'
        b = a.sampleRate;
    case 'sampleCount'
        b = length(a.samples);
    case 'axisLabel'
        b = a.axisLabel;
    case 'valueType'
        b = a.valueType;
    case 'valueUnit'
        b = a.valueUnit;
    case 'samples'
        b = a.samples;
    case 'DataCommon'
        b = a.DataCommon;
    case 'filename'
        a.DataCommon.source
        [path, file, ext, anot] = splitPath( a.DataCommon.source );
        b = [path,file,ext];
    otherwise
        % Pass it up to the parent class
        b = subsref(a.DataCommon, index);
    end
case '{}'
    error('Cell array indexing not supported by TimeData objects')
end
