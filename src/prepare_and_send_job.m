function [] = prepare_and_send_job(i_job,dirs,program_matlab_name,db_file_path,jobArgs,params,config)
% used in UC_NN main - prepares the job's needed folder structure and input
% files, and sends the job to the cluster
   %% build iteration dir
    relativeIterDir=['/',dirs.job_dirname_prefix,num2str(i_job)];
    localIterDir=[dirs.full_localRun_dir,relativeIterDir];
    remoteIterDir=[dirs.full_remoteRun_dir,relativeIterDir];
    mkdir(localIterDir);
    %% prepere job and send it to cluster
    display([datestr(clock,'yyyy-mm-dd-HH-MM-SS'),' - ',program_matlab_name,' - Sending job num ',num2str(i_job), '...']);
    [argContentFilename] = write_job_contents(localIterDir,i_job,db_file_path,params,config);
    [funcArgs,jobArgs]= prepere_for_sendJob(i_job,argContentFilename,remoteIterDir,jobArgs);
    if(strcmp(config.run_mode,'optimize'))
        sendJob('build_NN_db_job',funcArgs,jobArgs,config);
    else 
        sendJob('test_UC_NN_error_job',funcArgs,jobArgs,config);
    end