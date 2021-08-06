function [f1, f2] = getMAFreqs(MAIndex)
% [f1 f2] = getMAFreqs(MAIndex);
% Returns the frequency band for the given MA Index number.
%  f1 = the lower band edge of the passband
%  f2 = the upper band edge of the passband

switch MAIndex
    case 1
        f1 = 0.00056;
        f2 = 0.0017;
    case 2
        f1 = 0.0017;
        f2 = 0.0033;
    case 3
        f1 = 0.0033;
        f2 = 0.0067;
    case 4
        f1 = 0.0067;
        f2 = 0.010;
    case 5
        f1 = 0.010;
        f2 = 0.022;
    case 6
        f1 = 0.022;
        f2 = 0.05;
    case 7
        f1 = 0.05;
        f2 = 0.10;
    case 8
        f1 = 0.10;
        f2 = 0.20;
    case 9
        f1 = 0.20;
        f2 = 0.50;
    case 10
        f1 = 0.50;
        f2 = 1.00;
    case 11
        f1 = 1.00;
        f2 = 2.00;
    case 12
        f1 = 2.00;
        f2 = 6.00;
    case 13
        f1 = 6.00;
        f2 = 10.00;
    otherwise
        error('An invalid MA index was input.'); 
end






