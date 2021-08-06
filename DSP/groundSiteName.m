function name = groundSiteName(sitenumber)
% name = groundSiteName(siteNumber);
% Returns the name of the QF ground sensor site, given its site number.
% This uses a hard-coded look-up table.


%
% The following data is from the STATIONS.TXT file on the Master2 QF ground
% sensor network master computer

if sitenumber == 0
    
    name = 'Master Computer';
    
elseif sitenumber > 0 && sitenumber <= 36
    
    sitenames = {
        'Portola Valley'
        'Hollister'
        'Pacifica'
        'Los Gatos'
        'Hearst Castle'
        'Timber Cove'
        'Pinnacles'
        'Sea Ranch' 
        'Parkfield' 
        'Corralitos (Rt152)'
        'San Jose'
        'Crystal Springs' 
        'Mammoth Lakes'
        'Gilroy ' 
        'Black Pt.' 
        'Bodega Bay'
        'Bolinas' 
        'Coalinga'
        'Ukiah' 
        'Rocky Butte' 
        'Ferndale' 
        'Shandon'
        'Bitterwater'
        'Tom''s Place'
        'Petrolia (Triple Junction)' 
        'Hayward-2' 
        'Oakland' 
        'Fremont' 
        'Test' 
        'Santa Rosa'
        'Petaluma' 
        'Pt. Arena'
        'Napa' 
        'Carrizo Plain'
        'Pleasanton' 
        'Templeton' };
    
    name = sitenames{sitenumber};
    
elseif sitenumber == 40
    
    name = 'Long Beach';
    
elseif sitenumber == 777
    
    name = 'QF1003-777'
    
else
    name = 'Unknown Site Name';
end

