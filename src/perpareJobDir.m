function  [argContentFilename] = perpareJobDir(localIterDir,i_job,GENERAL_JOB_FILENAME,params,config)
%% write input file
% argContentFilename=[GENERAL_JOB_FILENAME,'_n_',num2str(i_job)];
argContentFilename = GENERAL_JOB_FILENAME;
save([localIterDir,'/',argContentFilename],'params','config');

