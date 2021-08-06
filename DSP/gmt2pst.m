function pstTime = gmt2pst( gmtTime )
%
%Convert from GMT to PST time zone

pstTime = gmtTime - 1/3;