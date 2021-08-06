function outObj = flatten( inObj )


avgSpect = getAverageSpectrum( inObj, 2.5*3600, 3.5*3600 )

plot( avgSpect );


outObj = -1;
