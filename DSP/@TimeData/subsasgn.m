function a = subsasgn(a,index,val)
%
% SUBSASGN Define index assignment for TimeData objects

switch index.type
case '()'
    % Treat indexing as direct access to the samples
    a.samples( index.subs{:} ) = val;
    
case '.'
    switch index.subs
    case 'sampleRate'
        a.sampleRate = val;
    case 'sampleCount'
        error('TimeData :: sampleCount is read ONLY!!');
    case 'axisLabel'
        a.axisLabel = val;
    case 'valueType'
        a.valueType = val;
    case 'valueUnit'
        a.valueUnit = val;
    case 'samples'
        sizor = size( val );
	if( sizor(2) > 2 )
	    display([ '@TimeData/subasgn:: max recommended number of columns in a TimeData object is 2!!!' ]);
	end
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
    error('Cell array indexing not supported by DataCommon objects')
end
