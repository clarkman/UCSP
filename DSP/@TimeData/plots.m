function plots(varargin)
%
% Makes a number of useful plots quickly.

numTimeDataObjects = 0;

for ith = 1:nargin
    % Check args
    if( isa( varargin{nargin}, 'TimeData' ) == 0 )
        error('Time Data Objects only');
        return;
    end
    tmp = varargin{ith};
	%plot(tmp);
	tmpLength = length(tmp.samples)/tmp.sampleRate;
	out = tmp;
	%out = segment(tmp,0,tmpLength-1.0);
	
	%plot(out);
	plot(spectrum(out,length(out.samples)));
	plot(energyAvg(out,0.2));
	%print(plot(energyAvg(out,0.2)));
	plot(spectrogram(out,1024,0.875));
end

