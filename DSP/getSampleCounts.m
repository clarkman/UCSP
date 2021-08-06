function counts =  getSampleCounts( varargin )

counts = zeros(nargin,1);

for ith = 1:nargin
    % Check args
    if( isa( varargin{nargin}, 'TimeData' ) == 0 )
        error('Time Data Objects only');
        return;
    end
    tmp = varargin{ith};
	%plot(tmp);
	counts(ith) = tmp.sampleCount;

end
