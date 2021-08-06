function mon = datenum2moniker( dn, doPST )

% Funny kind of floor

atimet = datenum2str(dn);

mon = [ atimet(7:10) atimet(1:2) atimet(4:5) ];




