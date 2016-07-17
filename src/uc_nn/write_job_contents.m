function  [argContentFilename] = write_job_contents(localIterDir,i_job,db_file_path,params,config)
%% write input file
argContentFilename = config.JOB_DATA_FILENAME;
save([localIterDir,'/',argContentFilename],'db_file_path','params','config');

