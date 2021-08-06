function out = joinData( in1, in2 )
%JOINDATA Joind two arrays created by readLabeledCSV and pluckData
%   Detailed explanation goes here


sz1 = size( in1 );
sz2 = size( in2 );

if sz1 ~= sz2 
	error('Size mismatch')
end

numElms = sz1(1);
out = in1;
for n = 1 : numElms
    arr1 = in1{n};
    arr2 = in2{n};
    outArr = [ arr1 ; arr2 ]
    out{n} = outArr;
end
