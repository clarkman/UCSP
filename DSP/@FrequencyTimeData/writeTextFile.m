function writeTextFile( varargin )
%
% Write the object as a .txt file with the given filename.

% The wavwrite function requires that the data fit within +/- 1
% So rescale to fit within that range.

for ithObj = 1 : nargin
    currentObj = varargin{ithObj};
	if( ~isa(currentObj, 'FrequencyTimeData') )
        error(['All arguments must be FrequencyTimeData objects!! Arg #' sprintf('%d',ithObj), ' is not']);
	end
    % Create file name
    dc=currentObj.DataCommon;
    [path file ext iota]=splitPath( dc.source );
    
    textFileName = [file '.ftd.txt']

    fid = fopen( textFileName, 'w' );
    if( fid == -1 )
        error(['Could not open file for writing: ' textFileName]);
    end
    numSamples = length(currentObj);
    fprintf( fid, 'FILE = %s\n', dc.source );
    fprintf( fid, 'SAMPLE_COUNT = %d\n', numSamples );
    fprintf( fid, 'SAMPLE_RATE = %f\n', currentObj.sampleRate );
    fprintf( fid, 'FREQUENCY_RESOLUTION = %f\n', currentObj.freqResolution );
    fprintf( fid, 'START_TIME = %s\n', datenum2str(dc.UTCref) );
    fprintf( fid, 'HEADER_END\n' );
    samps = currentObj.samples;
    sizer = size( samps )
    for ithRow = 1 : sizer(1)
        for ithColumn = 1 : sizer(2)
            fprintf( fid, '%d ', samps(ithRow, ithColumn) );
        end
        fprintf( fid, '\n' );
    end
    fclose( fid );
end

