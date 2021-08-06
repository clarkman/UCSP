function  [ residual, meta, numQuald ] = detectTFS( seg, detector, meta, fid, filtr, outages );
%
% Works with pulseWalker.m 
%
%  $Id: detectTFS.m,v 18843475ee7b 2014/11/14 22:54:45 qcvs $

residual = -1;
%metaOut = meta;
segLenSecs = lengthSecs( seg );
if( segLenSecs <= ( detector.duration_min - 1 ) / seg.sampleRate )
    return
end

begT=datenum2str(seg.DataCommon.UTCref);
finT=datenum2str(seg.DataCommon.UTCref+segLenSecs/86400);
display( [ 'Computing filter banks for: ', seg.DataCommon.station, ' ', seg.DataCommon.channel, ' from: ', begT, ' -to- ', finT ] );

for band = 1 : 13 
  [f1, f2] = getMAFreqs( band );
  ctrfreq = ( f1 + f2 ) / 2;
  passbandwidth = f2 - f1;
  fs = obj.sampleRate;


window = [ctrfreq - passbandwidth/2, ctrfreq + passbandwidth/2];  % in Hz
window = window / (fs/2);  % Convert to Matlab units

filt = fir1(filtlen-1, window, 'scale');   % fir1 takes the filter order = length-1

end

% Do outages
if ~isempty( outages )
  sz = size(outages);
  numOutages = sz(1);
  display( [ 'Applying ', sprintf( '%d', numOutages ), ' outages for site: ', staNum, ' chan: ', ch, ' for detector: ', detName ] );
  rowObj = PulseData( detector.name, sid, channel, rows );
  rowObj = filterOutages( rowObj, outages, 1 );
  rows = getPulses( rowObj );
  sz = size(rows);
%  display( [ 'Pulses found after outages applied = ', sprintf( '%d/%d', sz(1), totalFound ), ' for: ', detName ] );
  totalFound = sz(1);
else
%  display( [ 'Pulses found, no outages applied = ', sprintf( '%d', totalFound ), ' for: ', detName ] );
end

% Write 'em all ...
for p = 1 : totalFound
fwrite(fid, rows(p,:), 'double');
end
numQuald = totalFound;

%{
draw = 1;
if draw
  sz=size(rows);
  figure
  plot(seg);
  for p = 1 : sz(1)
    dc = seg.DataCommon;
    s=(rows(p,1)-dc.UTCref)*86400;
    pT=(rows(p,10)-dc.UTCref)*86400;
    f=s+rows(p,2);
    %f=s+rows(p,2)/86400;
    line([pT,pT],get(gca,'YLim'),'Color',[0 0 0 ]);
    line([s,s],get(gca,'YLim'),'Color',[0.618 0 0 ]);
    line([f,f],get(gca,'YLim'),'Color',[0 0.618 0 ]);
    text((f+s)/2,rows(p,7)/2,sprintf('peak=%f\nsumMag=%f\nmag=%f\npLen=%d',rows(p,7),rows(p,11),rows(p,12),rows(p,6)))
  end
  s=(min(rows(:,1))-dc.UTCref)*86400;
  f=(max(rows(:,1))-dc.UTCref)*86400+rows(p,2);
  lineHiStyle = '--';
  lineLoStyle = '--';
  line(get(gca,'XLim'),[thrLo, thrLo],'LineStyle',lineLoStyle,'Color',[0.2,0.2,0.2]);
  line(get(gca,'XLim'),[thrHi, thrHi],'LineStyle',lineHiStyle,'Color',[0.2,0.2,0.2]);
  set(gca,'XLim',[s-10,f+10])
  btn = 1;
  while btn == 1
    [xi,yi,btn] = ginput(1)
    if( btn == 3 )
  %    close('all')
      break
    end
  end
end
%}



