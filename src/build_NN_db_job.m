function []=build_NN_db_job(argeumentFileDir,argeumentFilename)
addHermesPaths;
if(strcmp('/u/gald/PSCC16_continuation/current_version',eval('pwd')))
    addpath(genpath('/u/gald/Asset_Management/matlab/matpower5.1/'));
    set_global_constants;
end
rng('shuffle');
%% load arguments
loaded_arguments =load([argeumentFileDir,'/',argeumentFilename]);
%% call the function
sample_db = build_NN_db(loaded_arguments.params);

%% save output to file
save([argeumentFileDir ,'/', loaded_arguments.config.JOB_OUTPUT_FILENAME]);