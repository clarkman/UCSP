function outObj = cleanTones( obj )

% 5. Compute mean spectrum properties
width=4;
lengthOfSum = length(obj)
binsPerHertz = 1.0 / obj.freqResolution;
halfWidth = width/2;
numBinsWide = halfWidth * binsPerHertz;
numBinsWide = floor(numBinsWide)+1; % Round UP.

outObj = obj;
%meanObj = mean(obj.samples);

if 1
% 6. Filter out 100hz & foldovers by creating mask
oneHundredHzBlot = 26;
maxPoint = max(obj, 1399.8, 1400.2)
fourteenthHarmonic = maxPoint(2);
%fbase = fourteenthHarmonic / 14 - (meanSpectrum.freqResolution/2); % find fundamental
fbase = fourteenthHarmonic/14; % find fundamental
%fbase = 100.0 % find fundamental
fs = 1.0e7/3333; % 3000.300030003000...
fmax = 4500;
hmax = floor( fmax / fbase );
hvec = 1:hmax;
freqs = hvec * fbase;
freqs = ( freqs/fs - floor(freqs/fs) ) * fs;
for kk = 1:hmax
    if( freqs(kk) > fs )
        freqs(kk) = freqs(kk) - fs;    
    elseif( freqs(kk) > fs/2 )
        freqs(kk) = fs - freqs(kk);    
    end
end
num100hzfreqs = length(freqs);
mask = ones(lengthOfSum,1); % Create a mask to be used for tone analysis
meanSamps = obj.samples;
for tth = 1:num100hzfreqs
    % Compute which-th bin this frequency is found in
    freqth = round(freqs(tth)*binsPerHertz+1);
    %freqth = round(freqs(tth)*binsPerHertz+1);
    %mask(freqth-3:freqth+3) = 0;
    loer=round(freqth-oneHundredHzBlot);
    if( loer < 1 )
        loer = 1;
    end
    hier=round(freqth+oneHundredHzBlot);
    if( hier > lengthOfSum )
        hier = lengthOfSum;
    end
    mask(loer:hier) = 0;
    %harmon = round(freqs(tth)/100)
    %mask(freqth-(oneHundredHzBlot*harmon):freqth+(oneHundredHzBlot*harmon)) = 0;
end

	% 6a. Filter out 50hz & foldovers by creating mask
	fiftyHzBlot = 27;
	maxPoint = max(obj, 1349.8, 1350.2)
	twentySeventhHarmonic = maxPoint(2);
	%fbase = fourteenthHarmonic / 14 - (meanSpectrum.freqResolution/2); % find fundamental
	fbase = twentySeventhHarmonic/27; % find fundamental
	%fbase = 100.0 % find fundamental
	fs = 1.0e7/3333; % 3000.300030003000...
	fmax = 4500;
	hmax = floor( fmax / fbase );
	hvec = 1:hmax;
	freqs = hvec * fbase;
	freqs = ( freqs/fs - floor(freqs/fs) ) * fs;
	for kk = 1:hmax
        if( freqs(kk) > fs )
            freqs(kk) = freqs(kk) - fs;    
        elseif( freqs(kk) > fs/2 )
            freqs(kk) = fs - freqs(kk);    
        end
	end
	num50hzfreqs = length(freqs);
	for tth = 1:num50hzfreqs
        % Compute which-th bin this frequency is found in
        freqth = round(freqs(tth)*binsPerHertz+1);
        %freqth = round(freqs(tth)*binsPerHertz+1);
        %mask(freqth-3:freqth+3) = 0;
        loer=round(freqth-fiftyHzBlot);
        if( loer < 1 )
            loer = 1;
        end
        hier=round(freqth+fiftyHzBlot);
        if( hier > lengthOfSum )
            hier = lengthOfSum;
        end
        mask(loer:hier) = 0;
        %harmon = round(freqs(tth)/100)
        %mask(freqth-(oneHundredHzBlot*harmon):freqth+(oneHundredHzBlot*harmon)) = 0;
	end
end

% 7. Add 600 & 1200 hz to mask
maxPoint = max(obj, 599.8, 600.2); % "600"
sixHundred = maxPoint(2);
sixHundredBlot = 125;
loer = ((sixHundred)*binsPerHertz+1) - sixHundredBlot;
hier = ((sixHundred)*binsPerHertz+1) + sixHundredBlot;
mask(loer:hier) = 0;
maxPoint = max(obj, 1199.8, 1200.2); % "1200"
twelveHundred = maxPoint(2);
twelveHundredBlot = 2 * sixHundredBlot;  % Seems to fit the harmonic role
loer = ((twelveHundred)*binsPerHertz+1) - twelveHundredBlot;
hier = ((twelveHundred)*binsPerHertz+1) + twelveHundredBlot;
mask(loer:hier) = 0;

buff = obj.samples;

%length(buff)
%length(mask)

if 0
	inNotch = 0;
	startNotch = -1;
	startNotchVal = 0;
	stopNotch = -1;
	stopNotchVal = 0;
	for ith = 1 : lengthOfSum
        if( mask(ith) == 0 )
            if( ~inNotch )
                inNotch = 1;
                startNotch = ith-1;
                startNotchVal = buff(ith-1);
            end
            buff(ith) = 0.0;
        else
            if( inNotch )
                inNotch = 0;
                stopNotch = ith+1;
                stopNotchVal = buff(ith+1);
            end
            for rth = startNotch+1:stopNotch-1
            end
        end
	end
else
	lastx=0.0;
	for ith = 1 : lengthOfSum
        if( mask(ith) == 0 )
            buff(ith) = lastx;
        else
            lastx = buff(ith);
        end
	end
end


outObj.samples = buff;
