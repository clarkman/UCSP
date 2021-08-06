function a = subsasgn(a,index,val)
% SUBSASGN Define index assignment for FrequencyTimeData objects
switch index.type
case '()'
    % Treat indexing as direct access to the samples
    a.samples( index.subs{:} ) = val;
    
case '.'
    switch index.subs
    case 'sampleRate'
        a.sampleRate = val;
    case 'freqResolution'
        a.freqResolution = val;
    case 'timeAxisLabel'
        a.timeAxisLabel = val;
    case 'freqAxisLabel'
        a.freqAxisLabel = val;
    case 'valueType'
        a.valueType = val;
    case 'valueUnit'
        a.valueUnit = val;
    case 'colorRange'
        a.colorRange = val;
    case 'samples'
        a.samples = val;
    case 'DataCommon'
        a.DataCommon = val;
    otherwise
        % Pass it up to the parent class
        a.DataCommon = subsasgn(a.DataCommon, index, val);
    end

    % Always.
    a = updateEndTime(a);
        
case '{}'
    error('Cell array indexing not supported by FrequencyTimeData objects')
end
