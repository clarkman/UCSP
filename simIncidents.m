function simIncidents()


maxn = 20;
v = zeros( maxn, 2 );
for n = 3 : maxn
	v(n,1) = n;
	v(n,2) = nchoosek( n, 3 );
end

plot( v(:,1), v(:,2) )
