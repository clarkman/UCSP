function vel = hydrovelocity( temp, eng )
% 

tVec = 40:1:120;

if nargin < 2 % Default is metric
  h2oTmp = [ 0 5 10 20 30 40 50 60 70 80 90 100 ];
  h2oVel = [ 1403 1427 1447 1481 1507 1526 1541 1552 1555 1555 1550 1543 ];
  airTmp = [ -40 0 5 10 15 20 25 30 40 50 60 70 80 90 100 200 300 400 500 1000 ];
  airVel = [ 306.2 331.4 334.4 337.4 340.4 343.3 346.3 349.1 354.7 360.3 365.7 371.2 376.6 381.7 386.9 434.5 476.3 514.1 548.8 694.8];
  xLab = 'Degrees Centigrade';
  yLab = 'Meters/sec';
  tVec = ( tVec - 32 ) .* 5/9;
else
  h2oTmp = [ 32 40 50 60 70 80 90 100 120 140 160 180 200 212 ];
  h2oVel = [ 4603 4672 4748 4814 4871 4919 4960 4995 5049 5091 5101 5095 5089 5062 ];
  airTmp = [ -40 -20 0 10 20 30 40 50 60 70 80 90 100 120 140 160 180 200 300 400 500 750 1000 1500 ];
  airVel = [ 1004 1028 1051 1062 1074 1085 1096 1106 1117 1128 1138 1149 1159 1180 1200 1220 1239 1258 1348 1431 1509 1685 1839 2114 ];
  xLab = 'Degrees Farenheit';
  yLab = 'Feet/sec';
end

[ph2o,Sh2o] = polyfit(h2oTmp,h2oVel,2);
[pair,Sair] = polyfit(airTmp,airVel,2);

vel = polyval(ph2o,temp);

tVec
if 1 % dev plot
  yair = polyval(pair,tVec);
  yh2o = polyval(ph2o,tVec);
  figure
  ratio = yh2o ./ yair;
  plot(tVec,ratio)
%  hold on;
%  plot(tVec,yh2o)

  margin = 1.01;
  set(gca,'YLim',[min(ratio)/margin,max(ratio)*margin]);
  %set(gca,'YLim',[min(Vel)/1.1,max(Vel)*1.1]);
  set(gca,'XLim',[min(tVec),max(tVec)]);

  set(gca,'XGrid','on');
  set(gca,'YGrid','on');

  xlabel(xLab);
  ylabel( [ 'water velocity / air velocity' ]);
  title('Ratio of sound velocity water/air vs. temperature')
end