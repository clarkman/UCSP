function station = getStationID( network, site )
%
% function station = getSiteNumBK( network, site )
%
% Purpose: 
% For the CMN network, site is the station number and this function returns
% the station name associated with that number. 
% For the BK network, not quite sure what this function will do yet
%
% Input Arguments: 
%   network - CMN, BK, or BKQ
%   site    - CMN: station number (600, 601, etc); BK/BKQ: ?
% 
% BK/BKQ sites with stats:
% PKD
% PKD1
% SAO
% JRSC

% Process Input Arguments

% Network
NETWORKS = {'BK' 'BKQ' 'CMN'};
network = upper(network);
if( isempty( find( strcmpi( NETWORKS, network ) ) ) )
    station = 'ERROR';
    display([ 'Unknown network: ' network ] );
    display('USAGE')
    return
end

if( strcmpi( network, 'CMN' ) )
    switch site
        case 600
            station = 'Healdsburg';
        case 601
            station = 'PortolaValley';
        case 602
            station = 'Honeydew';
        case 603
            station = 'Mettler';
        case 604
            station = 'LeBec';
        case 605
            station = 'Julian';
        case 606
            station = 'OcotilloWells';
        case 607
            station = 'Yucaipa';
        case 608
            station = 'Corona';
        case 609
            station = 'EastMilpitas';
        otherwise
            station = 'Unknown';
            display(sprintf('Warning: Unknown input site number %d',site))
    end
else
    display('Function not compatible with BK or BKQ networks yet')
    station = 'Undefined';
end % if( strcmpi( network, 'CMN' ) )

return