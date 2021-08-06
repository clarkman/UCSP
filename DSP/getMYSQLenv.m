function [ host, user, passwd ] = getMYSQLenv()
% Get QFDC paths, etc.

%[status, host] = system( 'echo -n $DB_FULL_HOST' );
host = getenv( 'DB_FULL_HOST' );
if( length( host ) == 0 )
  error( 'getMYSQLenv(): env must contain DB_FULL_HOST variable' );
end

%[status, user] = system( 'echo -n $DB_FULL_USER' );
user = getenv( 'DB_FULL_USER' );
if( length( user ) == 0 )
  error( 'getMYSQLenv(): env must contain DB_FULL_USER variable' );
end

%[status, passwd] = system( 'echo -n $DB_FULL_PASSWORD' );
passwd = getenv( 'DB_FULL_PASSWORD' );
if( length( passwd ) == 0 )
  sprintf( 'status=%d, passwd=%s', status, passwd )
  [status, passwd] = system( 'echo -n $DB_FULL_PASSWORD' )
  error( 'getMYSQLenv(): env must contain DB_FULL_PASSWORD variable' );
end
