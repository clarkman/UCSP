function dn = time_t2datenum( time_t )

dn = time_t .* (1.0/86400) + str2datenum('1970/01/01 00:00:00');
