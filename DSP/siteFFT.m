function [ fx, fy, fz, sg_xyz, tax, fax ] = siteFFT( site, network, date, fftL, overlap, ol_eps, window )
%
% siteFFT - Takes the three channels from a site and generates useful FFT products from it.
%           Normalized FFTs per channel are provided.  Also the cross covariance across the
%           the channels is produced.

lchunk = fftL;
%ddate   = datenum( date );
[yr,mo,day,hr,minute,sec] = datevec( date );

BKPATH  = '/mnt/Inetpub/Berkeley/bkProducts/dataCenterOutput/txt/';
TMP     = '/tmp/';

if ( window == 0 )
	window = hamming(fftL+1);
end


% Load the data
if ( strcmp( network, 'CMN' ) )
	for bi = 1:3,
		filename= sprintf('CHANNEL%d/%d%02d%02d.CMN.%s.%02d.txt',bi,yr,mo,day,site,bi);
		disp(filename);
		str = ['o',num2str(bi),'=TimeData(''',filename,''',''cmn'',''NoCal'');'];
		eval(str);
	end
elseif ( strcmp( network, 'BK' ) )
	for bi = 1:3,
		filename= sprintf('BK_%s_BT%d_%d_%02d_%02d.txt', site, bi, yr, mo, day );
		fullname= sprintf('%s/%s/BT%d/%s.gz', BKPATH, site, bi, filename );
		system( [ 'cp ', fullname, ' ', TMP ] );
		system( [ 'gzip -fd  ', TMP, filename, '.gz' ] );
		%system( 'ls /tmp/' )
		%disp(filename);
		%disp(fullname);
		str = ['o',num2str(bi),'=TimeData(''',TMP, filename,''',''bk'');'];
		eval(str);
		system( [ 'rm -f ', TMP, filename ] );
	end
else
	warning (['Unknown network' network]);
	fx     = -1;
	fy     = -1;
	fz     = -1;
	sg_xyz = -1;
	return
end


	sampf = floor(o1.sampleRate);
	totsamp = 24*3600*sampf;    % total number of samples in the day
	totsamp = min( [ o1.sampleCount o2.sampleCount o3.sampleCount ] );    % total number of samples in the day
	r2d     = 180/pi;           % radians to degrees conversion


	% ---- Spectrogram time chunks -----
	% 
	% number of points of overlap: np
	np  = round([ overlap-ol_eps : ol_eps/100 : overlap+ol_eps ]*lchunk);

	% number of time chunks, nch
	nch = round((totsamp - np)./(lchunk - np));

	% check remainder of samples with all combinations of np and nch, pick
	% combination of np and nch with least remaining points in sg.
	n_eps = totsamp - ( nch*lchunk - (nch-1).*np );
	n_eps_pos = find(n_eps>0);                     % get only +ve eps values
	n_epsi = find( n_eps == min(n_eps(n_eps_pos)) );   % find minimum positive
	ndt     = lchunk - np(n_epsi(1));
	dt      = ndt / sampf;
	nchunks = nch(n_epsi(1));

	numt    = nchunks;
	numf    = lchunk/2;
	tax     = [1:numt]*dt/3600;         % time-axis in hours
	tax     = [1:numt]*dt/3600;         % time-axis in hours
	fax     = [1:numf]/lchunk*sampf;    % freq axis, up to sampf/2

	disp(' ****  ')
	disp(['Number of time slices: ',num2str(nchunks)]);
	disp(['Overlap: ',num2str(np(n_epsi(1))/lchunk)]);
	disp(['Points in time chunk: ', num2str(lchunk), ...
	    ' from 0 to ', num2str(sampf), ' Hz']);
	disp(' ****  ');


	% x,y,z, dynamic spectrograms
	sg_xyz  = zeros(numt, numf);
	fx  = zeros(numt, numf);
	fy  = zeros(numt, numf);
	fz  = zeros(numt, numf);

	display('Loading transfer functions');
	if ( strcmp( o1.network, 'CMN' ) )
		tf1 = qf1005XferFuncPolar( o1, lchunk );
	else
		tf1 = xferFuncLoadPolar( o1, lchunk );
	end

	if ( strcmp( o2.network, 'CMN' ) )
		tf2 = qf1005XferFuncPolar( o2, lchunk );
	else
		tf2 = xferFuncLoadPolar( o2, lchunk );
	end

	if ( strcmp( o3.network, 'CMN' ) )
		tf3 = qf1005XferFuncPolar( o3, lchunk );
	else
		tf3 = xferFuncLoadPolar( o3, lchunk );
	end

	x = o2.samples;
	y = o1.samples;
	z = o3.samples;

	for ci = 1:nchunks,
	        starti  = 1 + (ci-1)*ndt;
        	stopi   = lchunk + (ci-1)*ndt;

        	x1 = x(starti:stopi).*window;
        	y1 = y(starti:stopi).*window;    
        	z1 = z(starti:stopi).*window;

		% Detrend data with a linear fit
		x1 = detrend( x1, 'linear'); 
		y1 = detrend( y1, 'linear'); 
		z1 = detrend( z1, 'linear'); 

		% Take the FFT and normalize
        	fx1 = fft(x1);
        	fy1 = fft(y1);
        	fz1 = fft(z1);

	        % Transfer function compensation and convert to nT;
	        fx1 = fx1(1:numf)./tf1*1e9/lchunk;
	        fy1 = fy1(1:numf)./tf2*1e9/lchunk;
	        fz1 = fz1(1:numf)./tf3*1e9/lchunk;

		%fx1(1) = fx1(3); fx1(2) = fx1(3);
		%fy1(1) = fy1(3); fy1(2) = fy1(3);
		%fz1(1) = fz1(3); fz1(2) = fz1(3);

	        fxy = fx1.*conj(fy1);
	        fxz = fx1.*conj(fz1);    
	        fyz = fy1.*conj(fz1);
	        sg_xyz(ci,:) = abs( fxy.^2 + fxz.^2 + fyz.^2 );

		fx(ci,:) = fx1;
		fy(ci,:) = fy1;
		fz(ci,:) = fz1;
	end	% for ci=1:nchunks

return;

