function [ timesArray, out ] = cohereogram( in1, in2, fftLength, overLapFactor, interactive )
%
% out = mscoheregram( obj1, obj2, 1024, 8 )
% 
% Render an array of rank 2, one axis for frequency
% one for time.  

if( nargin < 5 )
	interactive = 0;
end

doDebug = 1;

%in1 = obj1;
%in2 = obj2;
% Sanity Checking
if( abs(in1.sampleRate - in2.sampleRate) > 0.01 )
    error('mscoheregram: sample rates must match');
end
fs = in1.sampleRate;


% Need error checking
if doDebug
	if( overLapFactor > fftLength )
		error( 'Cannot overlap more than FFT length!!' );
	end
end
fractionOverlap = 1 - 1 / overLapFactor;


% Trim series to matching length
begTime1 = in1.DataCommon.UTCref;
begTime2 = in2.DataCommon.UTCref;
finTime1 = in1.DataCommon.UTCref + in1.DataCommon.timeEnd / 86400;
finTime2 = in2.DataCommon.UTCref + in2.DataCommon.timeEnd / 86400;
% Crude check ...
if( (begTime1 > finTime2) || (begTime2 > finTime1) )
    error( 'Time Series do not overlap ...!' );
end
if( begTime1 < begTime2 ), begClip = begTime2;, else, begClip = begTime1;, end;
if( finTime1 < finTime2 ), finClip = finTime1;, else, finClip = finTime2;, end;
in1 = segDatenum( in1, [begClip, finClip] );
in2 = segDatenum( in2, [begClip, finClip] );
len1 = length( in1 );
len2 = length( in2 );
if( len1 < len2 )
	in2 = slice( in2, 1, len1 );
elseif( len1 > len2 )
	in1 = slice( in1, 1, len2 );
end
serieslength=length(in1);
if doDebug
	% Bloody well check ...
	lengthIn2=length(in2);
	if( lengthIn2 ~= serieslength ), error( 'Segment trimming error ...!' ), end;
	if( serieslength < fftLength )
	    error( 'FFT length is longer than common segment of time series ...!' )
	end
end


% Set up for result ...
numFreqSlices = fftLength / 2 / overLapFactor + 1;
fftSlideStep = floor( fftLength / overLapFactor );
numTimeSlices = 0;
for sth = 1 : fftSlideStep : serieslength - fftLength
	numTimeSlices = numTimeSlices + 1;
end
if( sth < serieslength ) % Add one more for butt end
	numTimeSlices = numTimeSlices +1;
end

surface = zeros( numTimeSlices, numFreqSlices );

timesArray = zeros( numTimeSlices, 1 );

fftIncr = fftLength - 1;
thisTimeSlice = 0;
for sth = 1 : fftSlideStep : serieslength - fftLength
	thisTimeSlice = thisTimeSlice + 1;
	obj1 = offset(slice( in1, sth, sth + fftIncr ));
	timesArray(thisTimeSlice) = obj1.DataCommon.UTCref;
	[cohObj, F] = mscohere( obj1,  offset(slice( in2, sth, sth + fftIncr )), fractionOverlap, fftLength / overLapFactor );
	surface( thisTimeSlice, : ) = cohObj.samples;
end
if( sth < serieslength ) % Add one more for butt end
        endSamp = length( in1 );
	obj1 = offset(slice( in1, serieslength-fftLength+1, serieslength ));
	timesArray(thisTimeSlice+1) = obj1.DataCommon.UTCref;
	[cohObj, F] = mscohere( obj1,  offset(slice( in2, serieslength-fftLength+1, serieslength )), fractionOverlap, fftLength / overLapFactor );
	surface( end, : ) = cohObj.samples;
end

%Correct times for center of FFT
timesArray = timesArray + (fftLength / ( 2.0 * fs ))/86400;


totalCoherence = sum(sum(surface)) / (numTimeSlices*numFreqSlices);
newSampleRate = fs / fftSlideStep;
freqRes = 2 * fs / fftLength;
out = FrequencyTimeData(in1.DataCommon, surface', newSampleRate, freqRes);

out.timeOffset = 0;

sta1 = [ in1.DataCommon.network ' '  in1.DataCommon.station ' '  in1.DataCommon.channel ];
sta2 = [ in2.DataCommon.network ' '  in2.DataCommon.station ' '  in2.DataCommon.channel ];
out.source = [ sta1 ' vs ', sta2 ];


% Update the end time
sgramsize = size(out.samples);
parent = out.DataCommon;
out.title = ['CMN' in1.DataCommon.station in1.DataCommon.channel '-to-' 'CMN' in2.DataCommon.station in2.DataCommon.channel ];
out.history = 'Coherence';
out.valueType =  'Coherence^2';
plotSpread = [0.25, 1];
out.valueUnit = [ 'Range: ' sprintf( '%g-%g', plotSpread(1), plotSpread(2) ) ];
out.colorRange = plotSpread;


if interactive
	plot( out );
end

if 0 % 3D plot

	tAxis = getTAxis( out );
	fAxis = getFAxis( out );
	
	surf( tAxis, fAxis, surface',...
		'FaceColor', 'interp', ...
		'EdgeColor', 'none', ...
		'FaceLighting', 'phong' );
	%daspect([5 5 1])
	axis tight
	view( -120,30 )
	camlight left

	ylabel('Hz');
	xlabel('seconds');
	zlabel('Coherence');
	set(get(gcf,'CurrentAxes'),'ZLim',[0 1.0]);
	%title( [ 'Coherence of ', label1, ' to ' label2 ]);
	%text( sampsOff*scalar, 16, 1, [ 'Baseline is: ', sprintf('%f',baseCoherence) ], 'BackgroundColor', [1 1 1] )
	%text( sampsOff*scalar, 0, 0.95, [ 'Baseline coherence is: ', sprintf('%f',baseCoherence) ], 'BackgroundColor', [1 1 1], 'EdgeColor', [0 0 0] )
	%text( sampsOff*scalar, 0, 0.8, [ 'Best found is ', sprintf('%f',bestCoherence), ', obtained by sliding ', sprintf('%d',bestCoherenceIndex), ' samples.' ], 'BackgroundColor', [1 1 1], 'EdgeColor', [0 0 0] )
	%title( [ 'Coherence of ', label1, ' to ' label2, 'is: ', sprintf('%f',baseCoherence), '. Best found is ', sprintf('%f',bestCoherence), ', obtained by sliding ', sprintf('%d',bestCoherenceIndex), ' samples.' ]);
	%title( [ 'Base coherence of ', label1, ' to ' label2, 'is: ', sprintf('%f',baseCoherence), '. Best found is ', sprintf('%f',bestCoherence), ', obtained by sliding ', sprintf('%d',bestCoherenceIndex), ' samples.' ]);
end

return;

