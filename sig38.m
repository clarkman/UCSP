function sig38( file )

% Read file
vals=readFltFile( file, 3 );

% Make time vector
Fg=200000; % Sample rate
t=0:1/Fg:240000/Fg; t=t(1:end-1);

if 0 % Time of arrival compare
  plot(t,vals(1,:),'Color',[0.618 0 0])
  hold on;
  plot(t,vals(2,:),'Color',[0 0.618 0])
  plot(t,vals(3,:),'Color',[0 0 0.618])
  hold off
end

% Convert
g1=TimeData
g1.sampleRate=200000;
g1.samples=vals(1,:);
g1.samples=vals(1,:)';
g2=TimeData
g2.sampleRate=200000;
g2.samples=vals(2,:)';
g3=TimeData
g3.sampleRate=200000;
g3.samples=vals(3,:)';

if 0 
  plot(log10(spectrogram(zeroCenter(g3),2048,0.75)))
end
