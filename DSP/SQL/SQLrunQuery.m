function objects = SQLrunQuery( queryString, server, user )
%
% text of Matlab bug
% /usr/bin/mysql: /home/matlab/matlab7/sys/os/glnx86/libgcc_s.so.1: version `GCC_3.3' not found (required by /usr/lib/libstdc++.so.6)

NEWLINE = char(10);

[status, tmpDir] = system( 'echo -n $HOME' );
if( length( tmpDir ) == 0 )
    display( 'env must contain $HOME variable' );
    objects = -1;
    return;
end

sNo = rand(1);
tmpDir = [tmpDir, '/tmp'];
success = verifyEnvironment(tmpDir);
TEMP_QUERY_FILE   = [ tmpDir, '/SQLQuery', sprintf('%f',sNo) ];
TEMP_QUERY_SCRIPT   = [ tmpDir, '/SQLScript', sprintf('%f',sNo), '.bash' ];
TEMP_RESULTS_FILE = [ tmpDir, '/SQLResult', sprintf('%f',sNo) ];


% Write the query string to a temporary file TEMP_QUERY_FILE
fid = fopen(TEMP_QUERY_FILE, 'w');
if (fid == -1)
    display(['Unable to create temporary file ', TEMP_QUERY_FILE]);
    objects = -1;
    return
end

fprintf(fid, '%s', queryString);
fclose(fid);


% Invoke MySQL on the temporary file, producing results in another
% temporary file TEMP_RESULTS_FILE
scriptfid = fopen(TEMP_QUERY_SCRIPT, 'w');
if (scriptfid == -1)
    display(['Unable to create temporary script ', TEMP_QUERY_SCRIPT]);
    objects = -1;
    return
end

invokeString = ['/usr/bin/mysql -h ', server, ' -u ', user, ' < ', TEMP_QUERY_FILE, ' > ', TEMP_RESULTS_FILE];
fprintf( scriptfid, '%s', invokeString );
fclose( scriptfid );

chmodStr = [ '!chmod +x ', TEMP_QUERY_SCRIPT ];        
eval(chmodStr);
procStr = [ '!', TEMP_QUERY_SCRIPT ];        
eval(procStr);

% Read the result objects from the TEMP_RESULTS_FILE

objects = readSQLObjectsFromFile(TEMP_RESULTS_FILE);

delete(TEMP_QUERY_FILE);
%delete(TEMP_RESULTS_FILE);
delete(TEMP_QUERY_SCRIPT);


return;




















function objects = SQLrunQueryOLD(queryString)
%
NEWLINE = char(10);

TEMP_QUERY_FILE   = 'SQLtempqueryxyyx.txt';
TEMP_RESULTS_FILE = 'SQLtempresultsxyyx.txt';

DATABASENAME = 'test2';

% Append database to use on the front of the query string
queryString = ['use ', DATABASENAME, NEWLINE, queryString];


% Write the query string to a temporary file TEMP_QUERY_FILE
fid = fopen(TEMP_QUERY_FILE, 'w');

if (fid == -1)
    error(['Unable to create temporary file ', TEMP_QUERY_FILE]);
end

fprintf(fid, '%s', queryString);
fclose(fid);

% Invoke MySQL on the temporary file, producing results in another
% temporary file TEMP_RESULTS_FILE

% Query the DB through the OS shell
invokeString = ['!C:\mysql\bin\mysql.exe -h 192.168.10.156 -u louis < ', TEMP_QUERY_FILE, ' > ', TEMP_RESULTS_FILE];
        
eval(invokeString);


% Read the result objects from the TEMP_RESULTS_FILE

objects = readSQLObjectsFromFile(TEMP_RESULTS_FILE);
