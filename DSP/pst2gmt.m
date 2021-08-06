function gmtTime = pst2gmt( pstTime )
%
%Convert from GMT to PST time zone

gmtTime = pstTime + 1/3;