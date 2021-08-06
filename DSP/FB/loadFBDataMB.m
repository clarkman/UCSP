function data = loadFBDataMB( sd, ed, network, site, channels, bands, plotData, smoothData )
%
% function data = loadFBDataMB( sd, ed, network, site, channels, bands, plotData, smoothData )
%
% Purpose: Read into filter bank data from a particular network and site.  You 
%          can select channels and multiple bands.  You specify start time and 
%          end time in date that you want.
%
% Arguments: sd       - Start time (datenum)
%	         ed       - End time (datenum)
%	         network  - Network to get data from (CMN or BK)
%	         site     - the site you want
%	         channels - [1 2 3 4] where 4 is polarization ratio
%	         bands    - [1:13] multiple filter bank bands

% NOTE: This function is an adaptation on loadFBDataSB.m by jwc -- slp

[fbDir] = fbLoadEnvVar( network ); %#ok<NASGU>
if( smoothData )
    rootDir = sprintf('%s/smoothedData',fbDir);
else
    rootDir = fbDir;
end

data1 = [];          % - Initialize data variable
data2 = [];          % - Initialize data variable
data3 = [];          % - Initialize data variable
data4 = [];          % - Initialize data variable

% Constants
NOB = 14;

maxBand = max(bands);

for id=sd:ed
    % Get date into a useful format
    idv = datevec( id ); %#ok<NASGU>
    [yr mo day] = datevec( id );

    % Load in channel data
    %    - Load in normal if 1-3.
    %    - If 4, load in all and do calc
    if ~isempty(find( channels == 1,1 )) || ~isempty(find( channels == 4,1 ))
        if( strcmpi( network, 'CMN' ) ),
            if site<700;
            fn = sprintf( '%s/CMN%d_%s%d/CHANNEL%d/%d%02d%02d.CMN.%d.%02d.fb',...
                rootDir,site,siteNamesNOWS(site),site,1,yr,mo,day,site,1);
            else
            fn = sprintf( '%s/CMN%d_%s/CHANNEL%d/%d%02d%02d.CMN.%d.%02d.fb',...
                rootDir,site,siteNamesNOWS(site),1,yr,mo,day,site,1);
            end
        elseif( strcmpi( network, 'BK' ) || strcmp( network, 'BKQ' ) ),
            fn = sprintf( '%s/%s/BT1/BK_%s_BT1_%d_%02d_%02d.fb', ...
                rootDir, site, site, yr,mo,day );
        end
        td1 = fbloader1( fn );
    else
        td1 = zeros(96,NOB+1);
    end

    if ~isempty(find( channels == 2,1 )) || ~isempty(find( channels == 4,1 ))
        if( strcmpi( network, 'CMN' ) ),
            if site<700;
            fn = sprintf( '%s/CMN%d_%s%d/CHANNEL%d/%d%02d%02d.CMN.%d.%02d.fb',...
                rootDir,site,siteNamesNOWS(site),site,2,yr,mo,day,site,2);
            else
            fn = sprintf( '%s/CMN%d_%s/CHANNEL%d/%d%02d%02d.CMN.%d.%02d.fb',...
                rootDir,site,siteNamesNOWS(site),2,yr,mo,day,site,2);
            end
        elseif( strcmpi( network, 'BK' ) || strcmp( network, 'BKQ' ) ),
            fn = sprintf( '%s/%s/BT2/BK_%s_BT2_%d_%02d_%02d.fb', ...
                rootDir, site, site, yr,mo,day );
        end
        td2 = fbloader1( fn );
    else
        td2 = zeros(96,NOB+1);
    end

    if ~isempty(find( channels == 3,1 )) || ~isempty(find( channels == 4,1 ))
        if( strcmpi( network, 'CMN' ) ),
            if site<700;
            fn = sprintf( '%s/CMN%d_%s%d/CHANNEL%d/%d%02d%02d.CMN.%d.%02d.fb',...
                rootDir,site,siteNamesNOWS(site),site,3,yr,mo,day,site,3);
            else
            fn = sprintf( '%s/CMN%d_%s/CHANNEL%d/%d%02d%02d.CMN.%d.%02d.fb',...
                rootDir,site,siteNamesNOWS(site),3,yr,mo,day,site,3);    
            end
        elseif( strcmpi( network, 'BK' ) || strcmp( network, 'BKQ' ) ),
            fn = sprintf( '%s/%s/BT3/BK_%s_BT3_%d_%02d_%02d.fb', ...
                rootDir, site, site, yr,mo,day );
        end
        td3 = fbloader1( fn );
    else
        td3 = zeros(96,NOB+1);
    end

    if ( ~isempty(find( channels == 4,1 ) ) ),
        %%%%%%%%%%%%%%%%%
        % Addition from loadFBDataSB - Iterate over desired bands
        td4 = zeros(96,NOB+1);         % get right sized array
        for ib = bands
            z = td3(:,ib+1);
            x = td1(:,ib+1);
            y = td2(:,ib+1);
            % Remove negative data to avoid corrupting polar ratio - SLP
            z( z < 0 ) = 0;
            x( x < 0 ) = 0;
            y( y < 0 ) = 0;
            
            den = (x.^2 + y.^2);
            if ( den == 0 ),
                % set to zero
                td4(:,ib+1) = z - z;
            else
                td4(:,ib+1) = sqrt( z.^2 ./ (x.^2 + y.^2) );
            end
        end
        % End changes from loadFBDataSB
        %%%%%%%%%%%%%%%%%
    else
        td4 = zeros(96,NOB+1);
    end

    % Set time stamp
    td1(:,1) = 1/96*(1:96)' + id;     % - Set the correct time stamp (if we're using zeros)
    td2(:,1) = td1(:,1);
    td3(:,1) = td1(:,1);
    td4(:,1) = td1(:,1);

    % Append to data variable
    data1 = [ data1; td1 ];            % - Append channel data to temp data variable
    data2 = [ data2; td2 ];            % - Append channel data to temp data variable
    data3 = [ data3; td3 ];            % - Append channel data to temp data variable
    data4 = [ data4; td4 ];            % - Append channel data to temp data variable

end % end for id=sd:ed
data = zeros(size(data1,1),maxBand+1,4);    % Create an empty array for all 4 channels
data(:,:,1) = data1(:,1:maxBand+1);
data(:,:,2) = data2(:,1:maxBand+1);
data(:,:,3) = data3(:,1:maxBand+1);
data(:,:,4) = data4(:,1:maxBand+1);

if( plotData )
   for ib = bands
       figure(ib)
       clf
       subplot(4,1,1)
       plot(data(:,1,1),data(:,ib+1,1),'-b')
       subplot(4,1,2)
       plot(data(:,1,2),data(:,ib+1,2),'-b')
       subplot(4,1,3)
       plot(data(:,1,3),data(:,ib+1,3),'-b')
       subplot(4,1,4)
       plot(data(:,1,4),data(:,ib+1,4),'-b')
   end
end