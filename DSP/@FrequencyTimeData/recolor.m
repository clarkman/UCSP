function thresh = recolor(obj1, fractionReject)
%
%
% Recolors the current plot based on object's properties.
% The new color scaling ignores one-half of percentReject percent of the
% amplitude points at each end of the color scale (i.e. they get forced
% into the end colors).


histLen = 512;

[h, bins] = hist(obj1.samples(:), histLen);

binsize = bins(2) - bins(1);    % width of each bin

cum = cumsum(h);

% Rescale cum to be 0 to 1
cum = cum/cum(histLen);

% Find where cum crosses the percentReject/2 threshold on either end

for m = 1:histLen
    if cum(m) > fractionReject/2
        break;
    end
end

thresh(1) = bins(m) - binsize/2; % put the threshold between the two bins

for m = histLen : -1 : 1
    if cum(m) < 1 - fractionReject/2
        break;
    end
end

thresh(2) = bins(m) + binsize/2; % put the threshold between the two bins


