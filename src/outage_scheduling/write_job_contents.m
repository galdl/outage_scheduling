function  [argContentFilename] = write_job_contents(localPlanDir,i_month,maintenancePlan,db_file_path,params,config)
%% write input file
argContentFilename = config.JOB_DATA_FILENAME;
save([localPlanDir,'/',argContentFilename],'i_month','maintenancePlan','db_file_path','params','config');
