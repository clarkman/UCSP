function fbstatplots( data, kp_arr, season, dat, stat, fileName )
% FBstats
%
% This file will simply look at all the statistics off the FB caclulations,
% plot various distributions, etc.  It's assumed that FBmedian has already
% been run.
%
% J. Bortnik Nov. 17th 2005


% FLAGS
LOAD_KS=0;
STAT1 = 1;  % entire dataset stats, all bands, all coils
STAT2 = 0;  % effect of Kp on 1 FB band
STAT3 = 0;  % effect of season on 1 FB band
STAT4 = 0;  % now in logarithmic space
STAT5 = 0;  % effect of time of day (not log for speed)
STAT6 = 0;  % Look at at stats before high Ks events in PKD
STAT6b= 0;  % run this ONLY after running STAT6, plots gaussian properties.
STAT7 = 0;  % Plot kp characteristics of "dat" data block
STAT8 = 0;  % Plot season characteristics of "dat" data block

targObs ='PKD';

% Figure labels
% ma bands
figlabs = [ 'FB1: 0.001-0.002'; ...
            'FB2: 0.002-0.003'; ...
            'FB3: 0.003-0.007'; ...
            'FB4: 0.007-0.010'; ...
            'FB5: 0.010-0.022'; ...
            'FB6: 0.022-0.050'; ...
            'FB7: 0.050-0.100'; ...
            'FB8: 0.100-0.200'; ...
            'FB9: 0.200-0.500'; ...
            'FB10:0.500-1.000'; ...
            'FB11:1.000-2.000'; ...
            'FB12:2.000-6.000'; ...
            'FB13:6.000-10.00'; ...
            'RMS             '      ] ; 
% Kp labels
kplab   = [ 'kp = 1,2' ; ...
            'kp = 3,4' ; ...
            'kp = 5,6' ; ...
            'kp > 6  ' ] ;
            
% seasons
seasonlab=[ 'Summer'; ...
            'Autmun'; ...
            'Winter'; ...
            'Spring' ];
% sectors of day        
sectorlab=[ 'dawn '; ...
            'noon '; ...
            'dusk '; ...
            'night' ];
            
bt_colors = ['rgbm'];
            
            
if ~exist('data'),
    disp('Variable ''data'' is missing, please run FBmedian');
end

% Convert data to nT.  Data is in pT^2/Hz.  So take sqrt, multiple
% times 1000 to get pT.  Multiple by bandwidth
for li=2:14
	for lj=1:4
		[f1 f2] = getUCBMAFreqs(li-1);
		bw = f2 - f1;
		tmp = sqrt(data(:,li,lj)) / 1000 * bw;
		data2(:,li,lj) = tmp;
	end
end
data2(:,1,:) = data(:,1,:);		 % Set the time column.
negIndices = find(data==-1);	 % Get rid of -1 entries, ie no data.  Set to 0.
data2(negIndices)=0;

% Convert statistics to nT.  Values are in pT^2/Hz.
if 0,
for li=1:48
	for lj=1:13
		for lk=1:4
			for ll=1:4
				for lm=1:4
					for ln=1:6
						[f1 f2] = getUCBMAFreqs(lj);
						bw = f2 - f1;
						tmp = sqrt(dat(li,lj,lk,ll,lm,ln)) / 1000 * bw;
						dat(li,lj,lk,ll,lm,ln) = tmp;
					end
				end
			end
		end
	end
end
end

	for lj=1:13
						[f1 f2] = getUCBMAFreqs(lj);
						bw = f2 - f1;
						tmp = sqrt(dat(:,lj,:,:,:,:)) / 1000 * bw;
						dat(:,lj,:,:,:,:) = tmp;
	end

% Load Ks data 
if LOAD_KS & ~exist('kssize'),
    ksfilename = 'c:\qf\data\Ks\ks4.prn';
    [ksnum,kssize,ksdate,kstime,mag,depth,dist,obs] = ...
        textread(ksfilename, '%n %n %010s %05s %n %n %n %s');
    ksdt = zeros( length(ksnum), 6 );
    PKDhit = zeros( size(ksnum) );
    % get date as a string
    for ksii = 1:length(ksnum),
        ksdt(ksii,:) = datevec( [ cell2mat(ksdate(ksii)), ' ',  ...
            cell2mat(kstime(ksii)) ] );
        kstmp = cell2mat( obs(ksii) );
        % identify Ks at PKD
        if length(kstmp)==3 & kstmp==targObs, PKDhit(ksii) = 1; end
    end
end % if load Ks


    
sdat = size(data2);
len = sdat(1);



% STAT1
% This take the entire dataset stats and plots relative frequency functions
% for each band, and per coil
if (stat == 1),
    figure
    resol = 0.00001;
    ulimit = 1;
    for whichma=1:12;
        subplot(4,3,whichma)
        %figure
        for whichbt=1:3;
            divs = [0:resol:ulimit];
            lendiv = length(divs);
            distrib = zeros(lendiv,1);

            for ii = 1:len,
                %divind = round( sqrt(data(ii,whichma+1,whichbt))*0.001/resol )+1;
                divind = round( data2(ii,whichma+1,whichbt)/resol )+1;
                if divind<lendiv & divind>=1,
                    distrib(divind) = distrib(divind) + 1;
                end
            end
            distrib = distrib / sum(distrib);

            semilogx(divs, distrib,bt_colors(whichbt)), hold on
            xlim([resol 12])
            % axis tight
            xlabel('Amplitude [nT]')
            ylabel('Relative frequency')
            %title(['FB: ',num2str(whichma)])
            title(figlabs(whichma,:))
        end % for whichbt
    end % for whichma
end     % if STAT1



% STAT2
% Looks at the effect of Kp on one ma band
if (stat == 2),
    figure
    resol = 0.00001;
    divs = [0:resol:2];
    lendiv = length(divs);
    whichma=5;
    for whichkp=1:4;
        subplot(2,2,whichkp)
        for whichbt=1:3;
            
            distrib = zeros(lendiv,1);

            for ii = 1:len,
                divind = round( data2(ii,whichma+1,whichbt)/resol )+1;
                % now we add with a condition
                condition = divind<lendiv       & ...
                            divind>=1           & ...
                            kp_arr(ii)==whichkp;
                  
                if condition,
                    distrib(divind) = distrib(divind) + 1;
                end
            end
            distrib = distrib / sum(distrib);

            semilogx(divs, distrib,bt_colors(whichbt)), hold on
            xlabel('Amplitude [nT]')
            ylabel('Relative frequency')
            %title(['FB: ',num2str(whichma)])
            title([figlabs(whichma,:),', ',kplab(whichkp,:)])
        end % for whichbt
    end % for whichkp
end     % if STAT2




% STAT3
% Looks at the effect of season on one ma band
if (stat == 3 ),
    figure
    resol = 0.00001;
    divs = [0:resol:2];
    lendiv = length(divs);
    whichma=5;
    for whichseason = 1:4;
        subplot(2,2,whichseason)
        for whichbt=1:3;
            
            distrib = zeros(lendiv,1);

            for ii = 1:len,
                divind = round( data2(ii,whichma+1,whichbt)/resol )+1;
                % now we add with a condition
                condition = divind<lendiv       & ...
                            divind>=1           & ...
                            season(ii)==whichseason;
                  
                if condition,
                    distrib(divind) = distrib(divind) + 1;
                end
            end
            distrib = distrib / sum(distrib);

            semilogx(divs, distrib,bt_colors(whichbt)), hold on
            xlabel('Amplitude [nT]')
            ylabel('Relative frequency')
            %title(['FB: ',num2str(whichma)])
            title([figlabs(whichma,:),', ',seasonlab(whichseason,:)])
        end % for whichbt
    end % for whichkp
end     % if STAT3



% STAT4
% Redo the analysis now with logarithmic space
if (stat == 4 ),
    figure
    botlog = -6;
    toplog = 1;
    numpts = 500;
    resol  = (toplog-botlog)/numpts;
    divs = [botlog:resol:toplog];
    lendiv = length(divs);
    whichma=5;
    for whichseason = 1:4;
        subplot(2,2,whichseason)
        for whichbt=1:3;
            
            distrib = zeros(lendiv,1);

            for ii = 1:len,
                divind = ...
                    round( (log10(data2(ii,whichma+1,whichbt)+eps)-botlog)/resol )+1;
                % now we add with a condition
                condition = divind<lendiv       & ...
                            divind>=1           & ...
                            season(ii)==whichseason;
                  
                if condition,
                    distrib(divind) = distrib(divind) + 1;
                end
            end
            %distrib = distrib / sum(distrib);

            semilogx((10.^divs), distrib,bt_colors(whichbt)), hold on
            xlabel('Amplitude [nT]')
            ylabel('Relative frequency')
            %title(['FB: ',num2str(whichma)])
            title([figlabs(whichma,:),', ',seasonlab(whichseason,:)])
        end % for whichbt
    end % for whichkp
end     % if STAT4



% STAT5
% Looks at the effect of time of day
if ( stat == 5 ),
    figure
    resol = 0.00001;
    divs = [0:resol:2];
    lendiv = length(divs);
    whichma=5;
    for whichsector = 1:4;
        subplot(2,2,whichsector)
        for whichbt=1:3;
            
            distrib = zeros(lendiv,1);

            for ii = 1:len,
                divind = round( data2(ii,whichma+1,whichbt)/resol )+1;
                
                sector = floor((mod(data2(ii,1,1)-3/24,1))/.25)+1;
                
                % now we add with a condition
                condition = divind<lendiv       & ...
                            divind>=1           & ...
                            sector==whichsector;
                  
                if condition,
                    distrib(divind) = distrib(divind) + 1;
		end
            end
            distrib = distrib / sum(distrib);

            semilogx(divs, distrib,bt_colors(whichbt)), hold on
            xlabel('Amplitude [nT]')
            ylabel('Relative frequency')
            %title(['FB: ',num2str(whichma)])
            title([figlabs(whichma,:),', ',sectorlab(whichsector,:)])
        end % for whichbt
    end % for whichsector
end     % if STAT5




% STAT6
% We're now looking at one day before earthquakes - taken from Ks list
% done in logarithmic space
if ( stat == 6 ),
     
    PKDind = find(PKDhit);
    PKDtimes = datenum( ksdt(PKDind,:) );
    
    botlog = -6;
    toplog = 1;
    numpts = 500;
    numdays = 16;
    nummas = 12;
    resol  = (toplog-botlog)/numpts;
    divs = [botlog:resol:toplog];
    lendiv = length(divs);
    startday = -6;
    stopday = -8;
    dday = 2;
    a = zeros( numdays, nummas, nbt );
    mu = zeros( numdays, nummas, nbt );    
    sigma = zeros( numdays, nummas, nbt );
    a2 = zeros( numdays, nummas, nbt );
    mu2 = zeros( numdays, nummas, nbt );    
    sigma2 = zeros( numdays, nummas, nbt );
    
    for whichma=5:5;
    %for whichma = 1:nummas,    
        figure
    for whichdays = 1:numdays;
        subplot(4,4,whichdays)
    
        daylow = 2+2*(whichdays-1);     % looking at the period of time from 
        dayhigh = 0+2*(whichdays-1);    % dayquake-low to dayquake-dayhigh        

        % Look after the quake too!    
        daylow = startday +dday*(whichdays-1);  % looking at the period of time from 
        dayhigh =stopday  +dday*(whichdays-1);  % dayquake-low to dayquake-dayhigh 
        
        
        
        for whichbt=1:nbt;
            
            distrib = zeros(lendiv,1);

            for ii = 1:len,
                divind = ...
                    round( (log10(data2(ii,whichma+1,whichbt)+eps)-botlog)/resol )+1;
                % now we add with a condition
                dayCheck = any( PKDtimes > (data2(ii,1,1)+dayhigh) & ...
                    PKDtimes < (data2(ii,1,1)+daylow) ) & ...
                    kp_arr(ii)<=2;
                
                condition = divind<lendiv       & ...
                            divind>=1           & ...
                            dayCheck;
                  
                if condition,
                    distrib(divind) = distrib(divind) + 1;
                end
            end
            distrib = distrib / sum(distrib);
            [a(whichdays,whichma, whichbt), ...
             mu(whichdays,whichma,whichbt), ...
             sigma(whichdays,whichma,whichbt) ] =  fitgauss( distrib, divs' );
            
            mu2(whichdays,whichma,whichbt) = sum(distrib.*divs');
            sigma2(whichdays,whichma,whichbt) = sqrt( sum(distrib'.* ...
                (divs - mu2(whichdays,whichma,whichbt) ).^2) );
            aveind = closest(divs, mu2(whichdays,whichma,whichbt) );
            a2(whichdays,whichma,whichbt) = mean(distrib(aveind-5:aveind+5));    
            
            semilogx((10.^divs), distrib,bt_colors(whichbt)), hold on
            axis([10^botlog 10^toplog  0 0.02])
            %ylim([0 0.02])
            %xlim([10^botlog 10^toplog]);
            xlabel('Amplitude [nT]')
            ylabel('Relative frequency')
            %title(['FB: ',num2str(whichma)])
            title([figlabs(whichma,:),', day: ', ...
                num2str(-daylow),' to ',num2str(-dayhigh)])
            drawnow
        end % for whichbt
        
    end % for whichdays
    
end % for whichma
   
end     % if STAT6


% STAT6b
% This plots the Gaussian properties calc'ed in STAT6, such as a, mu and
% sigma.  Run STAT6b only after running STAT6.
if STAT6b,
    
    % plot amplitude "a"
    figure
    for whichma=1:12,
        subplot(4,3,whichma),
        midday_arr = [7:-2:-23];   
        plot(midday_arr,a2(:,whichma,1),'b', ...
             midday_arr,a2(:,whichma,2),'r', ...
             midday_arr,a2(:,whichma,3),'g' )
         axis tight,
         title([figlabs(whichma,:)])
         xlabel('Days to quake')
         ylabel('Amplitude')
    end
    
    % plot standard deviation "sigma"
    figure
    for whichma=1:12,
        subplot(4,3,whichma),
        midday_arr = [7:-2:-23];   
        plot(midday_arr,sigma2(:,whichma,1),'b', ...
             midday_arr,sigma2(:,whichma,2),'r', ...
             midday_arr,sigma2(:,whichma,3),'g' )
         axis tight,
         title([figlabs(whichma,:)])
         xlabel('Days to quake')
         ylabel('Std. Dev.')
    end    

    % plot mean "mu"
    figure
    for whichma=1:12,
        subplot(4,3,whichma),
        midday_arr = [7:-2:-23];   
        plot(midday_arr,mu2(:,whichma,1),'b', ...
             midday_arr,mu2(:,whichma,2),'r', ...
             midday_arr,mu2(:,whichma,3),'g' )
         axis tight,
         title([figlabs(whichma,:)])
         xlabel('Days to quake')
         ylabel('mean')
    end    
    
    
end     % if STAT6b



% STAT7
% This plots kp characteristics of the "dat" data block, as part of the
% residual section
if ( stat == 7 ),
    
   % effect of Kp on daily values
   whichseas= 1;
   whichval = 3;  % 3=median, 1=mean, etc.
   whichbt  = 2;
   LT   = [0:0.5:23.5];
   
   
   % Plot of all FB's on BT1
   figure
   for whichma=1:13,
       subplot(7,2,whichma)

	   semilogy( LT, dat(:, whichma, whichbt, whichseas, 1, whichval),'r' ), hold on
	   semilogy( LT, dat(:, whichma, whichbt, whichseas, 2, whichval),'g' )
	   semilogy( LT, dat(:, whichma, whichbt, whichseas, 3, whichval),'b' )   
	   semilogy( LT, dat(:, whichma, whichbt, whichseas, 4, whichval),'m:' )
   
	   axis tight
	   %xlabel('Local time [hrs]')
	   title([figlabs(whichma,:)])
	   ylabel('B-field [nT]')
	   %Title('Effect of Kp on daily medians [BT1, summer]')
   end
   
if 0,   
    % Plot of all FB's on BT1^2 + BT2^2 (Horizontal component)
   figure
   for whichma=1:13,
       subplot(7,2,whichma)
   %for whichma=5:5

   semilogy( LT, dat(:, whichma, whichbt, whichseas, 1, whichval).^2 + ...
       dat(:, whichma, whichbt+1, whichseas, 1, whichval).^2 ,'r' ), hold on
   semilogy( LT, dat(:, whichma, whichbt, whichseas, 2, whichval).^2 + ...
       dat(:, whichma, whichbt+1, whichseas, 2, whichval).^2 ,'g' )
   semilogy( LT, dat(:, whichma, whichbt, whichseas, 3, whichval).^2 + ...
       dat(:, whichma, whichbt+1, whichseas, 3, whichval).^2 ,'b' )
   semilogy( LT, dat(:, whichma, whichbt, whichseas, 4, whichval).^2 + ...
       dat(:, whichma, whichbt+1, whichseas, 4, whichval).^2 ,'m:' ) 
   axis tight
   %xlabel('Local time [hrs]')
   title([figlabs(whichma,:)])
   ylabel('B-field [nT]')
   %Title('Effect of Kp on daily medians [Horizontal component, summer]')
   end
   
   % Plot of one FB on BT1
   figure
   for whichma=5:5
   plot( LT, dat(:, whichma, whichbt, whichseas, 1, whichval),'r' ), hold on
   plot( LT, dat(:, whichma, whichbt, whichseas, 2, whichval),'g' )
   plot( LT, dat(:, whichma, whichbt, whichseas, 3, whichval),'b' )   
   plot( LT, dat(:, whichma, whichbt, whichseas, 4, whichval),'m:' )
   
   axis tight
   xlabel('Local time [hrs]')
   title(['B-field [nT], ', figlabs(whichma,:)])
   ylabel('B-field [nT]')
   %Title('Effect of Kp on daily medians [BT1, summer]')
   end   
end
  
end


% STAT8
% Plots season and FB characteristics of data block "dat"
if ( stat == 8 ),
    
    % season
    whichma     = 5;
    whichval    = 3;  % 3=median, 1=mean, etc.
    whichbt     = 1;
    whichkp     = 1;
    LT   = [0:0.5:23.5];
    for whichseas=1:4,
    plot( LT, dat(:, whichma, whichbt, whichseas, whichkp, whichval), ...
        bt_colors(whichseas) ), hold on
    plot( LT, dat(:, whichma, whichbt, whichseas, whichkp, whichval), ...
        bt_colors(whichseas) )
    plot( LT, dat(:, whichma, whichbt, whichseas, whichkp, whichval), ...
        bt_colors(whichseas) )   
    plot( LT, dat(:, whichma, whichbt, whichseas, whichkp, whichval), ...
        bt_colors(whichseas) )
    end
   axis tight
   xlabel('Local time [hrs]')
   title(['Seasonal effect, ', figlabs(whichma,:)])
   ylabel('B-field [nT]')
    
   
   % FB channel characteristics
   figure
   whichtod = 2;
   plot( dat(whichtod,1:13,1,1,4,3),'m' )
   hold on
   plot( dat(whichtod,1:13,1,1,3,3),'g' )
   plot( dat(whichtod,1:13,1,1,2,3),'r' )
   plot( dat(whichtod,1:13,1,1,1,3),'b' )
   axis tight
   xlabel('FB index')
   ylabel('B-field [nT]')
   title('Effect of Kp on FB')
   %whichtod = 2;
   %plot( dat(whichtod,1:13,1,1,4,3),'m--' )
   %hold on
   %plot( dat(whichtod,1:13,1,1,3,3),'g--' )
   %plot( dat(whichtod,1:13,1,1,2,3),'r--' )
   %plot( dat(whichtod,1:13,1,1,1,3),'b--' )
        
end

if ( fileName ~= 0 )
        display( ['Saving: ' fileName]);
%	fn = sprintf( '%s.jpg', fileName );
%        print('-djpeg60', '-noui', fn)
%	fn = sprintf( '%s.eps', fileName );
%        print('-deps', fn )
	fn = sprintf( '%s.png', fileName );
        print('-dpng', fn )

end



