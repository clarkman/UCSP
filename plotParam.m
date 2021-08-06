function plotParam(tok,idx,titl)

typer = { 'sid', 'mean', 'std dev', 'noise vs fullscale', 'noise vs fullscale', 'skewness' };
units = { 'id', 'WAV units', 'dBFS', 'WAV units', 'dBFS', '3rd moment' };

[params,fn] = sigChar( tok );

plot(params(:,idx),'Marker','o');
hold on;
plot(params(:,3),'Marker','o');


set(gca,'XTick',[1:119]);set(gca,'XTickLabel',fn,'XTickLabelRotation',45);
set(gcf, 'OuterPosition', [ 400 500 1920 1280 ] )
%set(gca, 'YScale', 'log' )
set(gca, 'YGrid', 'on' )
set(gca, 'XGrid', 'on' )

ylabel( [ typer{idx}, ' - ', units{idx} ', FS = +/- 1.0'] )
xlabel( 'Sensor Friendly Number' )

if isempty(tok)
  tok = 'Audio';
end

legend({' = 20 * log10( ( Max - Min ) / 2.0 )',' = 20 * log10( ( 2 * sqrt(2) * StdDev ) / 2.0 )'})

title( [ tok, ' ', typer{idx}, titl ] )
