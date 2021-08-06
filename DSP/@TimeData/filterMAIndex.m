function outobj = filterMAIndex(obj, MAIndex)
%
% outobj = filterMAIndex(obj, MAIndex);
% Filters the input object according to the Magnetic Activity index. This
% function chooses the filter pass band and filter length according to the
% MAIndex number.

switch MAIndex
    case 1
        f1 = 0.00056;
        f2 = 0.0017;
        filtlen = 511;
        decimationFactor = 100;
    case 2
        f1 = 0.0017;
        f2 = 0.0033;
        filtlen = 511;
        decimationFactor = 100;
    case 3
        f1 = 0.0033;
        f2 = 0.0067;
        filtlen = 511;
        decimationFactor = 100;
    case 4
        f1 = 0.0067;
        f2 = 0.010;
        filtlen = 8191;
        decimationFactor = 100;
    case 5
        f1 = 0.010;
        f2 = 0.022;
        filtlen = 8191;
        decimationFactor = 100;
    case 6
        f1 = 0.022;
        f2 = 0.05;
        filtlen = 4095;
        decimationFactor = 100;
    case 7
        f1 = 0.05;
        f2 = 0.10;
        filtlen = 2047;
        decimationFactor = 50;
    case 8
        f1 = 0.10;
        f2 = 0.20;
        filtlen = 1023;
        decimationFactor = 25;
    case 9
        f1 = 0.20;
        f2 = 0.50;
        filtlen = 511;
        decimationFactor = 10;
    case 10
        f1 = 0.50;
        f2 = 1.00;
        filtlen = 255;
        decimationFactor = 1;
    case 11
        f1 = 1.00;
        f2 = 2.00;
        filtlen = 255;
        decimationFactor = 1;
    case 12
        f1 = 2.00;
        f2 = 6.00;
        filtlen = 127;
        decimationFactor = 1;
    case 13
        f1 = 6.00;
        f2 = 10.00;
        filtlen = 127;
        decimationFactor = 1;
    otherwise
        error('An invalid MA index was input.'); 
end


centerFreq = (f1 + f2) / 2;

bandwidth = f2 - f1;


%outobj = freqTranslate(obj, centerFreq);

%outobj = lowpass(obj,

% if( decimationFactor > 1 )
%   obj = decimate( obj, decimationFactor );
% end

outobj = bandpass(obj, centerFreq, bandwidth, filtlen);




