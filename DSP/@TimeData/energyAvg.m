function outdata = energyAvg(obj, timeConstant, outputType)
%
% Performs a simple moving average of the energy in obj, using the
% timeConstant to determine the number of points to average.
% outdata is time lagged with respect to the input
% outputType can be 'db' or 'rms' (not case sensitive)  Optional; if
% omitted, it is 'db'.  Also, if outputType is 'blockrms' or 'blockdb'
% the the value "floor(timeConstant)" will be taken as an exact count
% of samples to be used in the moving average, and the operation is
% then termed as a block average.  
%
%    The output is in dB relative to the input. E.g., if the input is in
%  counts, the output is in dB-counts.

outdata = TimeData(obj);    % initialize output with all the same fields

% Remove the DC level before squaring
outdata = removeDC(obj);

% Square the input points
outdata.samples = outdata.samples .^ 2;              

outdata = addToTitle(outdata, 'Squared');

% Perform the moving average
if( nargin > 2 )
    doBlocks = strfind(outputType, 'block');
else
    doBlocks = [];
end
if( ~isempty(doBlocks) && nargin >= 3 )
    [outdata, numBlocks]  = blockAvg(outdata, timeConstant);
else
    outdata  = movingAvg(outdata, timeConstant);
end

outdata.valueType = 'Average Energy';
outdata.valueUnit = [outdata.valueUnit,'-rms'];

if (nargin < 3   ||  strfind(outputType, 'db') )
    % Convert to dB
    outdata.samples = 10*log10(outdata.samples);
    outdata.valueUnit = ['dB ', outdata.valueUnit];
elseif strcmpi(outputType, 'rms')
    % Take the square root
    outdata.samples = sqrt(outdata.samples);
    % Note that outdata.valueUnit is the same as the input
        
else
    error(['Third argument must be ''db'' or ''rms'' (case insensitive).',...
            'It can be omitted (when the default is ''db'' ' ]);
end
                         


