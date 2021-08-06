function a = subsasgn(a,index,val)
%
% SUBSASGN Define index assignment forEventData objects

switch index.type
case '()'
    % Treat indexing as direct access to the samples
    a.samples( index.subs{:} ) = val;
    
case '.'

    switch index.subs
    
        case 'events'
            sz = size( val );
            if( sz(2) < 6 )
                error( '@EventData/subasgn:: min number of allowed columns in an EventData object is 6!!!' );
            end
            a.events = val;
            
        case 'strings'
            a.strings = val;
            
        case 'DataCommon'
            a.DataCommon = val;

        otherwise
            % Pass it up to the parent class
            a.DataCommon = subsasgn(a.DataCommon, index, val);
            
    end
    
    % Always.
    a = updateTimes(a);
    
case '{}'
    error('Cell array indexing not supported by EventData objects')
end
