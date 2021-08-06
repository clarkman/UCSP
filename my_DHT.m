function X = my_DHT(x)
% This function calculates the Discrete Hartley Transform of a real
% sequence. In this function the time and frequency indices run from 0 to
% N-1. Therefore, when we use this function we consider strictly causal
% signals and only nonnegative frequencies.

% Take advantage of the fact that the input sequence x[n] is real:
X1 = fft(x);
% X1 = fftreal(x);
X = real(X1) - imag(X1);