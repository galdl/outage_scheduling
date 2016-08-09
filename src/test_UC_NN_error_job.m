function []=test_UC_NN_error_job(argumentFileDir,argumentFileName)
addHermesPaths;
if(strcmp('/u/gald/PSCC16_continuation/current_version',eval('pwd')))
    addpath(genpath('/u/gald/Asset_Management/matlab/matpower5.1/'));
end
set_global_constants;
rng('shuffle');
%% load arguments
loaded_arguments =load([argumentFileDir,'/',argumentFileName]);
nn_database =load(loaded_arguments.db_file_path); % all information needed is in the DB
%% restore data
[final_db,sample_matrix] = restoreSplitData([nn_database.dirs.full_remoteRun_dir,'/',nn_database.config.SPLIT_DIR]);
%% call the function
[difference_vector,uc_samples] = test_UC_NN_error( final_db , sample_matrix , nn_database.params)
display('finished test_UC_NN_error');
%% save output to file
clear final_db sample_matrix
display('finished clear');
save([argumentFileDir ,'/', loaded_arguments.config.JOB_OUTPUT_FILENAME],'difference_vector','uc_samples');
display('finished save');

