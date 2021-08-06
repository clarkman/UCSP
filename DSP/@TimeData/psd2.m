function psd = psd2( d0, fftL, startSampleNumber, window, tf1 )
%
% Function: psd2 - Power Spectral Density Calculator
%
% Description:
%   Calculates the power spectral density of BK and CMN coil data.
%   Output is in units of T^2/Hz.  Tech Memo 16, Spectral Density 
%   Calculations of BK and CMN data, provides a description of the
%   algorithm and example plots.
%
% Arguments:
%   d0	              - Input TimeData object
%   fftL              - Length of the desired FFT
%   startSampleNumber - Starting sample
%   window            - Window to apply to data, this must be set.
%   tf1	              - Preloaded transfer function if desired, set to 0 if you want to load your own.

	DEBUG = 0;			% - Set to 1 if you want to print debug messages
	sr   = d0.sampleRate;		% - Sample rate
	ws   = sum(window.^2)/fftL;	% - Calculate the window loss.
	df   = sr / fftL;		% - Width of frequency bin, delta f.

	% Load TF
	if tf1 == 0,
		if ( strcmp( 'BK', d0.DataCommon.network ) )
			xfer1 = xferFuncLoad( d0, fftL, 0);		% Load transfer function
			tf1= xfer1(:,2) .* exp( i*xfer1(:,3)/180*pi);	% Convert TF to a usable format
			tf1=tf1(2:fftL/2+1);                           % 0
			tf1(1) = tf1(2)/100;
		elseif ( strcmp( 'CMN', d0.DataCommon.network ) )
			xfer1=loadTransferFunction( d0, fftL )';
			%xfer1 = qf1005XferFunc( d0, fftL, 0, floor(sr/2) ); 
			tf= xfer1(:,2) .* exp( i*xfer1(:,3)/180*pi);
			tf = tf * 2^24 / 40;
			tf = tf * 1e9;
			tf1 = tf(1:fftL/2);
			%tf1(1) = tf1(2)/100;
		else
			display('Error, wrong network');
		end
	end

	d1 = d0.samples;                           % - Extract samples from the TimeData object

	% Detrend data with a linear fit
	stopSampleNumber = startSampleNumber + fftL -1 ;
	d2 = detrend( d1(startSampleNumber:stopSampleNumber), 'linear'); 

	d3 = d2 .* window;			   % Apply the window

	fa = fft(d3,fftL);                         % - Take FFT of data.
	fb = fa(1:fftL/2);                         % - Trim to take first half fo FFT, rest is a mirror.
	fc = fb./tf1;                              % - TF compensate.
	fd = fc / fftL;                            % - Normalize the FFT.

	% Calc PSD
	psd = 1 / df / ws * abs(fd).^2 * 2;        % - Square to get power, divide by bandwidth,
	                                           %   double it to get second half of FFT that
	                                           %   was thrown away.
	% Check Parseval's equations
	if DEBUG,
		p1 = sum( abs(d2).^2 ) / fftL;
		p2 = sum( psd * ws * df .* abs(tf1).^2 );
		str = sprintf('Power in time series: %e\nPower in PSD:         %e\n',p1, p2);
		display([ '' str ]);
	end

	% Plot PSD
	if DEBUG,
		figure
		fax  = [1:fftL/2]/fftL*sr;	% - Frequency axis
		loglog(fax,psd);
		xlabel('Hz');
		ylabel('T^2/Hz');
		grid
	end

return
