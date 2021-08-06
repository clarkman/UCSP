function a = subsasgn(a,index,val)
% SUBSASGN Define index assignment for FrequencyData objects
%

switch index.type
case '()'
    % Treat indexing as direct access to the samples
    a.samples( index.subs{:} ) = val;
    
case '.'
    switch index.subs
    case 'freqResolution'
        a.freqResolution = val;
    case 'axisLabel'
        a.axisLabel = val;
    case 'valueType'
        a.valueType = val;
    case 'valueUnit'
        a.valueUnit = val;
    case 'samples'
        a.samples = val;
    otherwise
        % Pass it up to the parent class
        a.DataCommon = subsasgn(a.DataCommon, index, val);
    end
    
case '{}'
    error('Cell array indexing not supported by FrequencyData objects')
end
