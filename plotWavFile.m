function [td1, td2] = plotWavFile( fileName, offset )

if nargin < 2
    offset = 0;
end

% Read file
[chans, FS]=audioread( fileName );
sz = size(chans);
if( sz(2) ~= 2 )
    error( 'Only tested with 2 channels' )
end

% Calculate time vector
t=0:1/FS:sz(1)/FS; t=t(1:end-1);

figure;
plot(chans(:,1),'Color','r');
%plot(t,chans(:,1),'Color','r');
hold on;
plot(chans(:,2),'Color','b');
%plot(t,chans(:,2),'Color','b');
xlabel('samples');
%xlabel('secs')
ylabel('amplitude');

td1=TimeData;
td2=TimeData;
td1.sampleRate = FS;
td2.sampleRate = FS;
td1.samples = chans(:,1);
td2.samples = chans(:,2);
td1.source = [ fileName, ' 1' ];
td2.source = [ fileName, ' 2' ];


