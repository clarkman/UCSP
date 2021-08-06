function jobInfo = getJobInfoKey( jobKey, staInfo )
%  $Id: getJobInfoKey.m,v 50956b4903ae 2014/03/19 00:25:36 qcvs $


% Get environment data
[ host, user, passwd ] = getMYSQLenv();
try
  mym('open', host, user, passwd );
  mym('use', 'xweb');
  queryStatement = [ 'SELECT * FROM products_jobs WHERE job_key LIKE ''%', jobKey, '''' ]
  jobInfo = mym( queryStatement );
  mym('close');
catch
  display( 'Could not fetch Job Info ...' );
  display( 'FAILURE' );
  jobInfo = -1;
  return
end

if nargin > 1

  numFound = length(jobInfo.job_output_dir);
  for dir = 1 : numFound
    if( strfind( jobInfo.job_output_dir{dir}, '<STADIR>' ) )
      outDir = jobInfo.job_output_dir{dir};
      slashes = strfind( outDir, '/' );
      jobInfo.job_output_dir{dir} = [ outDir(1:slashes(end)), staInfo.file_name{1} ];
    end
    if( strfind( jobInfo.job_outfile_nameform{dir}, '<STANUM>' ) )
      outForm = jobInfo.job_outfile_nameform{dir};
      dots = strfind( outForm, '.' );
      jobInfo.job_outfile_nameform{dir} = [ outForm(1:dots(1)), staInfo.sid{1}, outForm(dots(2):end) ];
    end
    if( strfind( jobInfo.job_output_dir{dir}, '<DET>' ) )
      outDir = jobInfo.job_output_dir{dir};
      slashes = strfind( outDir, '/' );
      jobInfo.job_output_dir{dir} = [ outDir(1:slashes(1)), jobInfo.job_detector{1}, outDir(slashes(2):end) ];
    end
    if( strfind( jobInfo.job_outfile_nameform{dir}, '<DET>' ) )
      outForm = jobInfo.job_outfile_nameform{dir};
      dots = strfind( outForm, '.' );
      jobInfo.job_outfile_nameform{dir} = [ outForm(1:dots(2)), jobInfo.job_detector{1}, outForm(dots(3):end) ];
    end
  end

end

