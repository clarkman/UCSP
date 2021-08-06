function alpha = corrcoef(obj1, obj2)
%
% mx = max(obj, firstFreq, lastFreq)
% Finds the maximum value in the object within the frequency window defined as firstFreq to lastFreq.
%  The window arguments are optional; if omitted, it uses the whole FrequencyData object.
% Returns mx = [amp freq] where amp is the value of the max and freq is
% its frequency

sampls1 = obj1(1:end);
sampls2 = obj2(1:end);

alpha = corrcoef(sampls1,sampls2);
