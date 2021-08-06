%king.m
%code for 24jul2314 roughly 231450 to 231550, roughly one min
%perform detect filtering

%ingesting
samples = textread('MG150HSFullLighting124Jul2314R2.txt');
numSamples = length(samples);
magSamples = samples(1:200000,2);
plot(magSamples);
title('data vs. sample number');
grid on;

%DC offset shift
Q = 0;
P = 0;
for i = 1:length(magSamples)
    if magSamples(i) == 0
    else 
       Q = Q + 1;
       P = P + magSamples(i);
    end
end

avg = P/Q;

for i = 1:length(magSamples)
    if magSamples(i) ==0
    else magSamples(i) = magSamples(i) - avg;
    end
end

y=magSamples;

figure;
plot(y);
title('data vs. sample number after shift');
grid on;

%square mag data
for i = 1:length(y)
    y(i) = y(i)^2;
end
figure;
plot(y);
grid on;
title('data squared');

%low pass. pass 1/2 of bandwidth and less
%fs = 500;
lowpass_filter = fir1(255, 75/250, 'low');
%lowpass_filter = fir1(1023, 10/(fs/2), 'low');
lowpass_data = filter(lowpass_filter,[1],y); %lowpass filtered data
figure;
plot(lowpass_data);            %plot data after bandpass, squares, and lowpass
title('after lowpass filter');
xlabel('sample number');
grid on;
