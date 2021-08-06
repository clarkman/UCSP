function statTS = buildStatTimeSeries( sd, ed, statInfo, kpMatFileName );

CHANNELS = [1:4];
STATS    = [1:5];

% Load in the Kp data
eval( sprintf('load %s;', kpMatFileName ) );
% Adjust kp for 8 time diffence in our analysis, PDT
kpdtnum = kpdtnum - 8/24;

% Populate a time series with expected values
for id=sd:ed		                    % - Loop through days

	[y,m,d,h,mi,s] = datevec(id);       % - Get date vector (month, day, etc)
	season = ceil((mod(m+6,12)+1)/3);   % - Calculate season param

	% Loop through time of days
	for it=[1:1:96]

		% Calculate time stamp
		t = id + it/96;      

		% Look up kp
		thisKp = kp( closest( kpdtnum,t ) );
		if ~isempty(thisKp)
			switch floor(thisKp),
				case {0,1}
					kp_tmp = 1;
				case {2,3}
					kp_tmp = 2;
				case {4,5}
					kp_tmp = 3;
				case {6,7,8,9}
					kp_tmp = 4;
			end % switch
		end     % if ~isempty(thisKp)

		statTS( (id-sd)*96 + it, :, :, : ) = statInfo( it, :, :, season, kp_tmp, : );
%		for channel=CHANNELS,
%			for stat=STATS,
%			end % for stat=STATS,
%		end % for channel=CHANNELS,

	end % end: for it=[1:1:96]
end % end: for id=sd:ed		
