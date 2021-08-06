function b = subsref(a,index)
%SUBSREF Define field name indexing for FrequencyTimeData objects
switch index.type
    
case '()'
    % Treat indexing as direct access to the samples
    b = a.samples( index.subs{:} );
    
case '.'
    switch index.subs
    case 'sampleRate'
        b = a.sampleRate;
    case 'freqResolution'
        b = a.freqResolution;
    case 'timeAxisLabel'
        b = a.timeAxisLabel;
    case 'freqAxisLabel'
        b = a.freqAxisLabel;
    case 'valueType'
        b = a.valueType;
    case 'valueUnit'
        b = a.valueUnit;
    case 'colorRange'
        b = a.colorRange;
    case 'samples'
        b = a.samples;
    case 'DataCommon'
        b = a.DataCommon;
    otherwise
        % Pass it up to the parent class
        b = subsref(a.DataCommon, index);
    end
case '{}'
    error('Cell array indexing not supported by FrequencyTimeData objects')
end
