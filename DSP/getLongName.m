function longName = getLongName( shortName )


[status, dbHost] = system( 'echo -n $DB_FULL_HOST' );
if( length( dbHost ) == 0 )
    display( 'env must contain DB_FULL_HOST variable' );
end
[status, dbUser] = system( 'echo -n $DB_FULL_USER' );
if( length( dbUser ) == 0 )
    display( 'env must contain DB_FULL_USER variable' );
end
[status, dbPasswd] = system( 'echo -n $DB_FULL_PASSWORD' );
if( length( dbPasswd ) == 0 )
    display( 'env must contain DB_FULL_PASSWORD variable' );
end

staIdLen=length( shortName );
[staID, count] = sscanf( shortName, '%d' );
if( count > 0 )
    if staIdLen < 4
        shortName = [ '0', shortName ];
    end
else
    if( staIdLen ~= 3 )
        error( 'Improper BK name length' );
    end
end

% Make database connection
try
	mym('open', dbHost, dbUser, dbPasswd );

	% Select database
	mym( 'use', 'xweb' );

	query = [ 'SELECT file_name FROM ground_observatories WHERE sid="', shortName, '"' ];
	longName = mym( query );

	mym('close');
catch
	longName = -1;
end


