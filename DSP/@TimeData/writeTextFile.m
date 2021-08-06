function writeTextFile( varargin )
%
% Write the object as a .txt file with the given filename.

% The wavwrite function requires that the data fit within +/- 1
% So rescale to fit within that range.

for ithObj = 1 : nargin
    currentObj = varargin{ithObj};
	if( ~isa(currentObj, 'TimeData') )
        error(['All arguments must be TimeData objects!! Arg #' sprintf('%d',ithObj), ' is not']);
	end
    % Create file name
    dc=currentObj.DataCommon;
    [path file ext iota]=splitPath( dc.source );
    
    textFileName = [file '.ascii.txt'];
    fid = fopen( textFileName, 'w' );
    if( fid == -1 )
        error(['Could not open file for writing: ' textFileName]);
    end
    numSamples = length(currentObj);
    fprintf( fid, 'FILE = %s\n', dc.source );
    fprintf( fid, 'SAMPLE_COUNT = %d\n', numSamples );
    fprintf( fid, 'SAMPLE_RATE = %f\n', currentObj.sampleRate );
    fprintf( fid, 'START_TIME = %s\n', datenum2str(dc.UTCref) );
    fprintf( fid, 'HEADER_END\n' );
    samps = currentObj.samples;
    for ithSample = 1 : numSamples
        fprintf( fid, '%d\n', samps(ithSample) );
    end
    fclose( fid );
end

