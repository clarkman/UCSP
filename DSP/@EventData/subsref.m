function b = subsref(a,index)
%
%SUBSREF Define field name indexing for EventData objects
switch index.type
case '()'
    % Treat indexing as direct access to the samples
    b = a.samples( index.subs{:} );
    
case '.'
    switch index.subs
    case 'eventTable'
        b = a.eventTable;
    case 'strings'
        b = a.strings;
    case 'DataCommon'
        b = a.DataCommon;
    otherwise
        % Pass it up to the parent class
        b = subsref(a.DataCommon, index);
    end
case '{}'
    error('Cell array indexing not supported by TimeData objects')
end
