function outdata = changeUnits(obj, conversionFactor, unitName)
%
% Converts the value (y) axis units to those with unitName, using
% conversionFactor = new_units/old_units.
%

% Initialize output to be the same as the input
outdata = obj;

outdata.samples = outdata.samples * conversionFactor;

outdata.valueUnit = unitName;
