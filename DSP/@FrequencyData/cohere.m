function [alpha, freqs] = cohere(obj1, obj2)
%
% mx = max(obj, firstFreq, lastFreq)
% Finds the maximum value in the object within the frequency window defined as firstFreq to lastFreq.
%  The window arguments are optional; if omitted, it uses the whole FrequencyData object.
% Returns mx = [amp freq] where amp is the value of the max and freq is
% its frequency


%[alpha, freqs] = cohere(obj1.samples,obj2.samples,length(obj1),3000.3,length(obj1)/4);
[alpha, freqs] = cohere(obj1.samples,obj2.samples,length(obj1.samples),3000.3);
%[alpha, freqs] = cohere(obj1.samples,obj2.samples,16*4096,3000.3,8192);
%[alpha, freqs] = cohere(obj1.samples,obj2.samples,1024,3000.3,5);
