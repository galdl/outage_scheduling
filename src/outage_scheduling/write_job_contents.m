function  [argContentFilename] = write_job_contents(localPlanDir,remotePlanDir,i_month,maintenancePlan,db_file_path,params,config)
%% write input file
argContentFilename = [config.JOB_DATA_FILENAME,'_m_', num2str(i_month)];
save([localPlanDir,'/',argContentFilename],'remotePlanDir','i_month','maintenancePlan','db_file_path','params','config');
