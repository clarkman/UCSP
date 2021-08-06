function [sg_xyz, sg_f1, sg_f2, sg_f3, nchunks, my_th, my_ph, my_mag, my_R, my_beta, my_thax, fax, tax] = ...
	waves ( day, network, site, lchunk, df, f1, minwid, overlap, ol_eps, MAKEPLOT, MAKEMEANS, FINDPC1 )

% waves.m 
%
% Based off of Jacobs Pc1 finder code.  Converting to CMN.
%
% Input vars:
%	o1	- TimeData object for x axis
%	o2	- TimeData object for y axis
%	o3	- TimeData object for z axis
%	lchunk	- Length of data segment in points to analyze
%	df	- Frequency band to anlayze
%	f1	- Start frequency of band to analyze
%	minwid	- Minimum width of peak to be detected
%	overlap	- starting value for time slice overlap
%	ol_eps	- range around overlap to look for best fit
%	MAKEPLOT  - Generate plot of wave parameters
%	MAKEMEANS - Generate means for each lchunk
%
% Output vars:
% 	sg_xyz	- dynamic spectrum, cross covariance
% 	sg_f1	- dynamic spectrum, x
% 	sg_f2	- dynamic spectrum, y
% 	sg_f3	- dynamic spectrum, z
% 	nchunks	- number of time chunks in analysis
% 	my_th	- wave calc output, theta
% 	my_ph	- wave calc output, phi
% 	my_mag	- wave calc output, magnitude
% 	my_R	- wave calc output, polarization Ratio
% 	my_beta	- wave calc output, ellipticity (tan(beta))
% 	my_thax	- wave calc output, axis inclination



% Switches
READ    = 1;    % Read the PKD files
REPLACE = 1;    % if outfile exists in current directory, replace it

if ( strcmp( network, 'bk' ) )
	BKdir=sprintf( 'mnt/Inetpub/Berkeley/bkProducts/dataCenterOutput/txt/%s', site );
	BKdir='/opt/backups/txt/';
end
txtDir = '/tmp';

if ~MAKEMEANS,
	display('Not making means, making zeros');
	my_th   = 0;
	my_ph   = 0;
	my_mag  = 0;
	my_R    = 0;
	my_beta = 0;
	my_thax = 0;
end

%
% Load in TimeData objects
[yr,mo,day,hr,minute,sec] = datevec( day );
    
	display('Loading channel files');
	for bi = 1:3,
		
		if ( strcmp( network, 'cmn' ) )
			filename= sprintf('CHANNEL%d/%d%02d%02d.CMN.%d.%02d.txt',bi,yr,mo,day,site,bi);
			disp(filename);
			str=['o',num2str(bi),'=removeDC(TimeData(''',filename,''',''cmn'',''Means''));'];
			eval(str);
		elseif ( strcmp( network, 'bk' ) )
			filename = sprintf('%s/BK_%s_BT%d_%d_%02d_%02d.txt',txtDir,site,bi,yr,mo,day);
			zipname = sprintf('%s/%s/BT%d/BK_%s_BT%d_%d_%02d_%02d.txt.gz',BKdir,site,bi,site,bi,yr,mo,day);
			disp(['Filename: ', filename]);
			if exist(zipname) 
				disp(['Zipname', zipname]);
				system(['cp -f ', zipname, ' ',txtDir]);	
				system(['gzip -df ',filename,'.gz']);
				str=['o',num2str(bi),'=TimeData(''',filename,''',''bk'');'];
				disp(str);
				eval(str);
			else
				sg_f1   = 0;
				sg_f2   = 0;
				sg_f3   = 0;
				sg_pc   = 0;
				sg_xyz  = 0;
				my_th   = 0;
				my_ph   = 0;
				my_mag  = 0;
				my_R    = 0;
				my_beta = 0;
				my_thax = 0;
				nchunks = 0;
				fax = 0;
				tax = 0;
				return
			end;	% if exist(zipname)
			str=['o',num2str(bi),'=removeDC(TimeData(''',filename,''',''bk''));'];
			eval(str);
			system(['rm ',filename]);
		end

	end  % for bi=1:3

sampf = floor(o1.sampleRate);
totsamp = 24*3600*sampf;    % total number of samples in the day
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
fax     = [1:numf]/lchunk*sampf;    % freq axis, up to sampf/2

ham     = 0.54 - 0.46*cos( 2*pi*[1:lchunk]'/lchunk ); % Hamming window

disp(' ****  ')
disp(['Number of time slices: ',num2str(nchunks)]);
disp(['Overlap: ',num2str(np(n_epsi(1))/lchunk)]);
disp(['Points in time chunk: ', num2str(lchunk), ...
    ' from 0 to ', num2str(sampf), ' Hz']);
disp(' ****  ');


        % trim to 3456000 (Clark's fix).  Do a bit of error checking.
        tmp = o2.samples;
        if length(tmp)<totsamp | ~any(tmp),
		disp('ERROR, length incorrect');
        else,
            x   = tmp([1:totsamp]);
            x = x - mean(x);
        end

        tmp = o1.samples;
        if length(tmp)<totsamp | ~any(tmp),
		disp('ERROR, length incorrect');
        else,
            y   = tmp([1:totsamp]);
            y = y - mean(y);
        end

        tmp = o3.samples;
        if length(tmp)<totsamp | ~any(tmp),
		disp('ERROR, length incorrect');
        else,
            z   = tmp([1:totsamp]);
            z = z - mean(z);
        end
        
	% x,y,z, dynamic spectrograms
	sg_f1   = zeros(numt, numf);
	sg_f2   = zeros(numt, numf);
	sg_f3   = zeros(numt, numf);
	sg_pc   = zeros(numt, numf);
	sg_xyz  = zeros(numt, numf);

	% polarization parameters
	th      = zeros(numt, 1);   % theta: angle from vertical
	ph      = zeros(numt, 1);   % phi: azimuth angle from x-axis
	mag     = zeros(numt, 1);   % mag: pwoportional to mag of pwr in band
	R       = zeros(numt, 1);   % R: polarizarion ratio (pol/unpol power)
	beta    = zeros(numt, 1);   % beta: ellipticity, tan(beta)=min/maj axis
	thax    = zeros(numt, 1);   % theta axis: ang of maj ellipse wrt rotated x


	display('Loading transfer functions');
	if ( strcmp( network, 'cmn' ) )
		xfer1 = qf1005XferFunc( o1, lchunk/2, 0, sampf/2 );	% Load transfer function
		tf= xfer1(:,2) .* exp( i*xfer1(:,3)/180*pi);			% Convert TF to a usable format
		tf1 = [ tf' , fliplr( conj(tf(2:(max(size(tf))-1)))' ) ];	% --
		tf1(1) = tf1(2)/100;
	else
		xfer1 = xferFuncLoad( o1, lchunk, 0);			% Load transfer function
		tf1= xfer1(:,2) .* exp( i*xfer1(:,3)/180*pi);			% Convert TF to a usable format
		tf1=tf1(2:lchunk/2+1)';
		tf1(1) = tf1(2)/100;
	end

	if ( strcmp( network, 'cmn' ) )
		xfer2 = qf1005XferFunc( o2, lchunk/2, 0, sampf/2 );	% Load transfer function
		tf= xfer2(:,2) .* exp( i*xfer2(:,3)/180*pi);			% Convert TF to a usable format
		tf2 = [ tf' , fliplr( conj(tf(2:(max(size(tf))-1)))' ) ];	% --
		tf2(1) = tf2(2)/100;
	else
		xfer2 = xferFuncLoad( o2, lchunk, 0);			% Load transfer function
		tf2= xfer2(:,2) .* exp( i*xfer2(:,3)/180*pi);			% Convert TF to a usable format
		tf2=tf2(2:lchunk/2+1)';
		tf2(1) = tf2(2)/100;
	end

	if ( strcmp( network, 'cmn' ) )
		xfer3 = qf1005XferFunc( o3, lchunk/2, 0, sampf/2 );	% Load transfer function
		tf= xfer3(:,2) .* exp( i*xfer3(:,3)/180*pi);			% Convert TF to a usable format
		tf3 = [ tf' , fliplr( conj(tf(2:(max(size(tf))-1)))' ) ];	% --
		tf3(1) = tf3(2)/100;
	else
		xfer3 = xferFuncLoad( o3, lchunk, 0);			% Load transfer function
		tf3= xfer3(:,2) .* exp( i*xfer3(:,3)/180*pi);			% Convert TF to a usable format
		tf3=tf3(2:lchunk/2+1)';
		tf3(1) = tf3(2)/100;
	end


        clear tmp o1 o2 o3


	for ci = 1:nchunks,

	%str=sprintf('Chunk %d out of %d', ci, nchunks);
	%display([str]);

        thistime = day + (ci-1)/nchunks; 
        starti  = 1 + (ci-1)*ndt;
        stopi   = lchunk + (ci-1)*ndt;

        x1 = x(starti:stopi).*ham;
        y1 = y(starti:stopi).*ham;    
        z1 = z(starti:stopi).*ham;

	% Convert from counts to volts and take the FFT.
        fx1 = fft(x1* (40/2^24));
        fy1 = fft(y1* (40/2^24));
        fz1 = fft(z1* (40/2^24));

        % Transfer function compensation
        fx1 = fx1(1:numf)./tf1.';
        fy1 = fy1(1:numf)./tf2.';
        fz1 = fz1(1:numf)./tf3.';
        
        fxy = fx1.*conj(fy1);
        fxz = fx1.*conj(fz1);    
        fyz = fy1.*conj(fz1);
        sg_xyz(ci,:) = abs( fxy.^2 + fxz.^2 + fyz.^2 );

        sg_f1(ci,:)     = abs( fx1 );
        sg_f2(ci,:)     = abs( fy1 );    
        sg_f3(ci,:)     = abs( fz1 );    

	% Calculate means
	if MAKEMEANS,
		display('Making means');
		for ab=1:lchunk/2
			[ my_th(ci,ab), my_ph(ci,ab), my_mag(ci,ab), my_R(ci,ab), my_beta(ci,ab), my_thax(ci,ab) ] =  ...
			  	means2(fy1(ab), -fx1(ab), -fz1(ab) );                
		end
	end

	end	% for ci=1:nchunks

	if MAKEPLOT,
		figure 
   	 	imagesc(tax, fax, log10(sg_xyz')), colorbar, axis xy
	end


	if FINDPC1,
	display('Detecting Pc1s');
	%                 ----  PC1 DETECTION  ----
	%
	med     = median(log10(sg_xyz),1);
%    	fprintf(fid2, '%0.6g ', med.');
%	fprintf(fid2, '\n');

	numpks = zeros(1,nchunks);
	peaks  = [];

	for ci=1:nchunks,
		str=sprintf('Chunk %d out of %d', ci, nchunks);
		display([str]);
    
        	sig = log10(sg_xyz(ci,:))-med;
    
   		sg_pc(ci, find( sig > 3 ) ) = 1;
   		pk_list =  findPeaks2( sig, 0.01, sampf, f1, df, minwid);
   		%figure, plot(  log10(sg_xyz(ci,:))-med  ); hold on
   		%title(['ci: ',num2str(ci)]); 
   		pk_size = size(pk_list);

   		if ~isempty(pk_list),
       			
			for jj = 1:pk_size(1),
                
		                pk_rng = [pk_list(jj,1):pk_list(jj,3)];
                
		                % NB. means2 subroutine
				% ---------------------
				% It's very important the way I pass means2 the x,y,z
				% values.  Currently, the directions are:
				% bt1 = west
				% bt2 = north
				% bt3 = up
				% I want to change to a standard XYZ coordinate system, so
				% the way I will pass signals to means2 is:
				% x = bt2  (North, equiv. to X)
				% y = -bt1 (East, equiv. to Y)
				% z = -bt3 (down, equiv. to Z)
				% there is also a 3 degree offest between bt1, bt2 from
				% true North, but I'm not going to worry about that now.
                
				%[th, ph, mag, R, beta, thax] = means2(fx1(pk_rng), ...
				%    fy1(pk_rng), fz1(pk_rng) );
				[th, ph, mag, R, beta, thax] = means2(fy1(pk_rng), -fx1(pk_rng), -fz1(pk_rng) );                
                    
				peaks = [peaks; day ci pk_list(jj,1:3) th*r2d ph*r2d mag ...
					abs(R) real(beta)*r2d real(thax)*r2d];

				%fprintf(fid, '%0.10g ',[day ci pk_list(jj,1:3) th*r2d ...
				%ph*r2d mag abs(R) real(beta)*r2d real(thax)*r2d]);    

				%fprintf(fid,'\n');    
               
           			%plot( pk_list(jj,1:3), ... 
           			%log10(sg_xyz(ci, pk_list(jj,1:3)))-med(pk_list(jj,1:3)),'r*');
       			
			end	% for jj = 1:pk_size(1)
   		end	% if ~isempty(pk_list)
	end	% for ci=1:nchunks,
	end


	% Some plot diagnostics

	if MAKEPLOT,
    		
		figure 
   	 	imagesc(tax, fax, log10(sg_xyz')), colorbar, axis xy, hold on
		if FINDPC1,
    		plot( tax(peaks(:,2)), fax(peaks(:,3)),'k.' )
    		plot( tax(peaks(:,2)), fax(peaks(:,4)),'m.' )
    		plot( tax(peaks(:,2)), fax(peaks(:,5)),'k.' )
		end
    
		if MAKEMEANS,
		figure
    		subplot(6,1,1),plot(tax,abs(th)/pi*180), ylabel('\theta_k')
    		subplot(6,1,2),plot(tax,abs(ph)/pi*180), ylabel('\phi_k')
    		subplot(6,1,3),plot(tax,log10(abs(mag))), ylabel('mag')
    		subplot(6,1,4),plot(tax,abs(R)), ylabel('R')
    		subplot(6,1,5),plot(tax,abs(beta)/pi*180), ylabel('\beta_{ax}')
    		subplot(6,1,6),plot(tax,abs(thax)/pi*180), ylabel('\theta_{ax}')
		end
	
	end % if MAKEPLOT
            
