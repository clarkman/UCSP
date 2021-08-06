function output = sort( obj, count, type )
%
% This function creates an 2 x n array containing bin number 
% and strength.  There are three calling syntaxes:
%
% 1) out = sort( TimeDataObject )
%    All frequency bins are sorted in ascending order.
%
% 2) out = sort( TimeDataObject, count )
%    Sort all in ascending order.  Return count # of items from the end of
%    the list.
%
% 3) out = sort ( TimeDataObject, count, type )
%    Sort all in ascending order.  Return count # of items from the end of
%    the list.  If type is 'rms' undB() first, else return default dB.
%

arf = obj.samples;
doUndB = 0;
outputCount=0;

if( nargin == 3 )
    if( type == 'rms' )
        doUndB = 1;
    end
end
if( nargin >= 2 )
    outputCount = count;
else
    outputCount = length( obj.samples );
end

% Fetch array
bins = obj.samples;

% Sort in ascending order
bins = sort( bins );

% Reverse to descending order
bins = flipdim( bins , 1 );

% Section
output = bins(1:outputCount);
