function hists = getStrengthBins( tds )

szData = size(tds);
numExps = szData(1);
numSens = szData(2);
numChns = szData(3);

numSampls = 48000;
numSlices = 8;
sliceLen  = numSampls / numSlices;
offset    = 0.5;
offStep   = sliceLen * offset;
numBins   = ( numSlices / offset ) - 1;

histsTmp = cell( numExps, numSens, numChns );

for d = 1 : numExps
	for s = 1 : numSens
		for c = 1 : numChns
			histSummary = zeros(8,numBins)-9999; % mean, median, std, rms
			td = tds{d,s,c};
			if isempty(td)
				warning(sprintf('Skipping %d/%d/%d',d,s,c))
				histsTmp{d,s,c} = histSummary;
				continue
			end
			samps = td.samples;
			numSamps = length(samps);
			for binth = 1 : numBins
				firstIdx = (binth-1)*offStep+1;
				finalIdx = firstIdx + sliceLen - 1;
				if finalIdx > numSamps
					warning( sprintf( 'Shortened samples (%d) out of %d.', numSamps, numSampls ) )
					break;
				end
				seg = samps(firstIdx:finalIdx);
				histSummary(1,binth) = mean(seg);
				histSummary(2,binth) = median(seg);
				histSummary(3,binth) = std(seg);
				histSummary(4,binth) = rms(seg);
				histSummary(5,binth) = skewness(seg);
				histSummary(6,binth) = kurtosis(seg);
				histSummary(7,binth) = min(seg);
				histSummary(8,binth) = max(seg);
			end
			histsTmp{d,s,c} = histSummary;
		end
	end
end

hists = histsTmp;