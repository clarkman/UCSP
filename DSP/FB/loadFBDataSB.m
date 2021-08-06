function [ data1 data2 data3 data4 ] = loadFBDataSB( sd, ed, network, site, channels, band )
%
% function [ data1 data2 data3 data4 ] = loadFBDataSB( sd, ed, network, site, channels, band )
%
% Purpose: Read into filter bank data from a particular network and site.  You 
%          can select channels and a single band.  You specify start time and 
%          end time in date that you want.
%
% Arguments: sd       - Start time
%	         ed       - End time
%	         network  - Network to get data from (CMN or BK)
%	         site     - the site you want
%	         channels - [1 2 3 4] where 4 is polarization ratio
%	         band     - single filter bank band

[fbDir fbStatDir kpTxtFileName kpMatFileName] = fbLoadEnvVar( network );

data1 = [];          % - Initialize data variable
data2 = [];          % - Initialize data variable
data3 = [];          % - Initialize data variable
data4 = [];          % - Initialize data variable


for id=sd:ed		
		% Get date into a useful format
		idv = datevec( id );
		[yr mo day] = datevec( id );

		% Load in channel data
		%    - Load in normal if 1-3.
		%    - If 4, load in all and do calc
		if ~isempty(find( channels == 1 )) | ~isempty(find( channels == 4 ))
			if( strcmp( network, 'CMN' ) ),
				fn = sprintf( '%s/CMN%d_%s%d/CHANNEL%d/%d%02d%02d.CMN.%d.%02d.fb',...
					          fbDir,site,siteNamesNOWS(site),site,1,yr,mo,day,site,1);
			elseif( strcmp( network, 'BK' ) || strcmp( network, 'BKQ' ) ),
				fn = sprintf( '%s/%s/BT1/BK_%s_BT1_%d_%02d_%02d.fb', ...
							  fbDir, site, site, yr,mo,day );
			end
			td1 = fbloader1( fn );
		else
			td1 = zeros(96,14);	
		end

		if ~isempty(find( channels == 2 )) | ~isempty(find( channels == 4 ))
			if( strcmp( network, 'CMN' ) ),
				fn = sprintf( '%s/CMN%d_%s%d/CHANNEL%d/%d%02d%02d.CMN.%d.%02d.fb',...
					          fbDir,site,siteNamesNOWS(site),site,2,yr,mo,day,site,2);
			elseif( strcmp( network, 'BK' ) || strcmp( network, 'BKQ' ) ),
				fn = sprintf( '%s/%s/BT2/BK_%s_BT2_%d_%02d_%02d.fb', ...
							  fbDir, site, site, yr,mo,day );
			end
			td2 = fbloader1( fn );
		else
			td2 = zeros(96,14);	
		end

		if ~isempty(find( channels == 3 )) | ~isempty(find( channels == 4 ))
			if( strcmp( network, 'CMN' ) ),
				fn = sprintf( '%s/CMN%d_%s%d/CHANNEL%d/%d%02d%02d.CMN.%d.%02d.fb',...
					          fbDir,site,siteNamesNOWS(site),site,3,yr,mo,day,site,3);
			elseif( strcmp( network, 'BK' ) || strcmp( network, 'BKQ' ) ),
				fn = sprintf( '%s/%s/BT3/BK_%s_BT3_%d_%02d_%02d.fb', ...
							  fbDir, site, site, yr,mo,day );
			end
			td3 = fbloader1( fn );
		else
			td3 = zeros(96,14);	
		end

		if ( ~isempty(find( channels == 4 ) ) ),
			td4 = td1;			% Get us the right sized array, only going to 
			                    % change one column, band + 1
			z = td3(:,band+1);
			x = td1(:,band+1);
			y = td2(:,band+1);
			den = (x.^2 + y.^2);
			if ( den == 0 ),
				% set to zero
				td4(:,band+1) = z - z;
			else
				td4(:,band+1) = sqrt( z.^2 ./ (x.^2 + y.^2) );
			end
		else
			td4 = zeros(96,14);	
		end

		% Set time stamp
		td1(:,1) = [1:1:96]/96 + id;     % - Set the correct time stamp (if we're using zeros)
		td2(:,1) = td1(:,1);
		td3(:,1) = td1(:,1);
		td4(:,1) = td1(:,1);

		% Append to data variable
		data1 = [ data1; td1 ];            % - Append channel data to temp data variable
		data2 = [ data2; td2 ];            % - Append channel data to temp data variable
		data3 = [ data3; td3 ];            % - Append channel data to temp data variable
		data4 = [ data4; td4 ];            % - Append channel data to temp data variable

end % end for id=sd:ed
