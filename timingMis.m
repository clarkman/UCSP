function [ output_args ] = timingMis( arr, tWind )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% Gather ye facts
sz = size(arr);
numRows = sz(1);
numCols = sz(2);
vSound = 1126; % ft/s
vSndDay = vSound*86400 % ft/day


% Make play space, incidents & LOS only
timel = zeros(numRows,2);
for r = 1 : numRows
    timel(r,1) = arr{r,3};  % incident ID
    timel(r,2) = arr{r,11}; % LOS bool
end
incidentIdxs = find( timel(:,1) > 0 & timel(:,2) > 0 );
numIncidents = length( incidentIdxs );
timel = zeros(numIncidents,12);
for inc = 1 : numIncidents
    id = incidentIdxs(inc);
    timel(inc,1) = arr{id,1}; % FP
    timel(inc,2) = arr{id,2}; % shot
    timel(inc,3) = arr{id,3}; % incident ID
    timel(inc,4) = arr{id,4}; % PulseDateTime
    timel(inc,5) = arr{id,9}; % Range
    if strcmp( arr{id,6}, 'ISU-00-BEN-0063' ) % Is DQV
        timel(inc,6) = 1;
    end
end



meatInds = find( timel(:,4) > tWind(1) & timel(:,4) < tWind(2) );

rows = extractRows( timel, meatInds );

combos = unique(rows(:,1:2),'rows');

sz = size(combos);

numCombos = sz(1);

deltaTs = zeros(numRows,2)
dtCtr = 0;
for c = 1 : numCombos
    shotIdxs = find( rows(:,1) == combos(c,1) & rows(:,2) == combos(c,2) );
    shots = extractRows( rows, shotIdxs );
    dqvInd = find( shots(:,6) > 0 );
    if isempty(dqvInd)
        error('DQV squatch')
    end
    notDQVs = extractNotRows( shots, dqvInd );
    sz = size(notDQVs);
    numNotDQVs = sz(1);
    if length(dqvInd) > 1
        warning('Two or more DQV triggers');
        dqvTrgs = extractRows( shots, dqvInd );
        [ tval, idx ] = min( dqvTrgs(:,4) );
        dqvInd = find( shots(:,6) > 0 & shots(:,4) == tval );
        shots(:,3)
        if isempty(dqvInd)
            error('DQV scratch');
        end
    end
    % d = vt; d/v = t
    trutime = shots(dqvInd,4) - shots(dqvInd,5)/vSndDay
    for ndqv = 1 : numNotDQVs
        dtCtr = dtCtr + 1;
        deltaTs(dtCtr,1)=trutime;
        deltaTs(dtCtr,2)=notDQVs(ndqv,4)-notDQVs(ndqv,5)/vSndDay-trutime;
    end
end

deltaTs = deltaTs(1:dtCtr,:);

figure;
stem(deltaTs(:,1),deltaTs(:,2)*86400*1000); % milliseconds
ylabel('ms')
xlabel('PDT')
title( [ 'ArtFusion Clock diffs, ', datestr(tWind(1)), ' to ' datestr(tWind(2)) ] )
datetick('x','HH:MM');
set(gcf, 'OuterPosition', [ 400 500 1280 960 ] )
set(gca,'YLim',[-200 50])


