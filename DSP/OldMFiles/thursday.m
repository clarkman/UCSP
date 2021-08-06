a = lowpass_data(6034:6044);
for i =1:300:16384+300
    x(i:i+10) = a;
end

X = fft(x);                       %perform FFT on data
n = length(x)/2 +1;
X = X(1:n);                     
magnitude = abs(X);             %magnitude
fs = 3000;                       %sampling rate
freq= (0:length(X)-1)*(fs/2)/(length(X)-1);        %frequency vector
figure;
plot(freq,magnitude);
title('Magnitude vs. Frequency');
xlabel('Frequency');
ylabel('Magnitude');
grid on;
grid minor;

p = unwrap(angle(X));
plot(freq,p*180/pi);