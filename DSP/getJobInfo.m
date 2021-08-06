function jobInfo = getJobInfo( jobName, staInfo )
%  $Id: getJobInfo.m,v 50956b4903ae 2014/03/19 00:25:36 qcvs $


% Get environment data
[ host, user, passwd ] = getMYSQLenv();
try
  mym('open', host, user, passwd );
  mym('use', 'xweb');
  queryStatement = [ 'SELECT * FROM products_jobs WHERE job_name=''', jobName, '''' ];
  jobInfo = mym( queryStatement );
  mym('close')
catch
  display( 'Could not fetch Job Info ...' );
  display( 'FAILURE' );
  jobInfo = -1;
end

if nargin > 1

  numFound = length(jobInfo.job_output_dir);
  for dir = 1 : numFound
    if( strfind( jobInfo.job_output_dir{dir}, '<STADIR>' ) )
      outDir = jobInfo.job_output_dir{dir};
      slashes = strfind( outDir, '/' );
      if( iscell( staInfo.file_name ) )
        jobInfo.job_output_dir{dir} = [ outDir(1:slashes(end)), staInfo.file_name{1} ];
      else
        jobInfo.job_output_dir{dir} = [ outDir(1:slashes(end)), staInfo.file_name ];
      end
    end
  end

end


