function startDatenum = getStartDate( station )


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

staIdLen=length( station );
[staID, count] = sscanf( station, '%d' );
if( count > 0 )
    if staIdLen < 4
        station = [ '0', station ];
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

	query = [ 'SELECT first_data_start FROM ground_observatories WHERE sid="', station, '"' ];
	startDate = mym( query );

	mym('close');

    startDatenum = str2datenum( sql2stdDate( startDate{1} ) );
catch
	startDatenum = -1;
end


