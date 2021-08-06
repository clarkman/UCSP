function writeLabelFile( inputObject, outputFileName )
%

currentObj = inputObject

if( ~isa(currentObj, 'FrequencyData') )
	error(['All arguments must be FrequencyData objects!! Arg #' sprintf('%d',ithObj), ' is not']);
end

% Create file name
display( ['Opening file: ' outputFileName]);
fid = fopen( outputFileName, 'w' );
if( fid == -1 )
	error(['Could not open file for writing: ' outputFileName]);
end


numSamples = length(currentObj);
fprintf( fid, 'FILE = %s\n', currentObj.DataCommon.source );
fprintf( fid, 'FREQ_RESOLUTION = %f\n', [currentObj.freqResolution] );
fprintf( fid, 'SAMPLE_COUNT = %d\n', numSamples );
fprintf( fid, 'LABELS = Frequency\tValue\n' );
samps = currentObj.samples;
for ithSample = 1 : numSamples
	fprintf( fid, '%d\t%d\n', ithSample*currentObj.freqResolution, samps(ithSample) );
end
fclose( fid );

