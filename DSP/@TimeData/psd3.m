function psd = psd2( d0, fftL, startT, stopT, window, avg, tf1 )
%
% Function: psd2
%
% Arguments:
%	d0	- Input TimeData object
%	fftL	- Length of the desired FFT
%	startT	- Starting sample
%	stopT	- Ending sample
%	window	- Window to apply to data, this must be set.
%	avg	- Not used.
%	tf1	- Preloaded transfer function if desired, set to 0 if you want to load your own.

	sr   = d0.sampleRate;		% - Sample rate
	fax  = [1:fftL/2]/fftL*sr;	% - Frequency axis
	ws   = sum(window.^2)/fftL;
	df   = sr / fftL;

	% Load TF
	if tf1 == 0,
	    if ( strcmp( 'BK', d0.DataCommon.network ) )
		xfer1 = xferFuncLoad( d0, fftL, 0);		% Load transfer function
		tf1= xfer1(:,2) .* exp( i*xfer1(:,3)/180*pi);	% Convert TF to a usable format
		tf1=tf1(2:fftL/2+1);                            % 0
		tf1(1) = tf1(2)/100;
	    elseif ( strcmp( 'CMN', d0.DataCommon.network ) )
		%xfer1 = qf1005XferFunc( d0, fftL/2, 0, floor(sr/2) ); 
		%xfer1 = qf1005XferFunc( d0, fftL, 0, floor(sr/2) ); 
                xfer1=loadTransferFunction( d0, fftL )';
		tf= xfer1(:,2) .* exp( i*xfer1(:,3)/180*pi );
		tf = tf * 2^24 / 40;
		tf = tf * 1e9;
		tf1 = tf(1:fftL/2);
		%tf1(1) = tf1(2)/100;
	    else
		display('Error, wrong network');
	    end
	end

	d1 = d0.samples;                           % - Extract samples from the TimeData object

	% detrend data
	d2 = detrend( d1(startT:stopT), 'linear'); % - Detrend data with a line.

	d3 = d2 .* window;

	fa = fft(d3,fftL);                         % - Take FFT of data.
	fb = fa(1:fftL/2);                         % - Trim to take first half fo FFT, rest is a mirror.
	fc = fb ./ tf1;                            % - TF compensate.
	fd = fc / fftL;                            % - Normalize the FFT.

	% Calc PSD
	psd = 1 / df / ws * abs(fd).^2 * 2;        % - Square to get power, divide by bandwidth,
	                                           %   double it to get second half of FFT that
                                                   %   was thrown away.
                                                   
plot(psd)
title('from psd2');
set(gca,'XLim',[1 1024]);
set(gca,'YLim',[1e-28 1e-18]);
set(gca,'XScale','log');
set(gca,'YScale','log');

	% Check Parseval's equations
	if 0,
		p1 = sum( abs(d2).^2 ) / fftL
		%p2 = sum( 2*(abs(fd.*tf1')).^2 )
		p2 = sum( psd * df .* abs(tf1').^2 )
	end

	if 0,
	figure
	loglog(fax,psd2);
	xlabel('Hz');
	ylabel('pT/rootHz');
	grid
	set(get(gcf,'CurrentAxes'),'XLim',[0.01 10]);
	end

return
