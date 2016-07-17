function []=test_UC_NN_error_job(argumentFileDir,argumentFileName)
addHermesPaths;
if(strcmp('/u/gald/PSCC16_continuation/current_version',eval('pwd')))
    addpath(genpath('/u/gald/Asset_Management/matlab/matpower5.1/'));
end
sets_global_constants;
rng('shuffle');
%% load arguments
loaded_arguments =load([argumentFileDir,'/',argumentFileName]);
nn_database =load(loaded_arguments.db_file_path); % all information needed is in the DB
%% restore data
[final_db,sample_matrix] = restoreSplitData([nn_database.full_remoteRun_dir,'/',nn_database.config.SPLIT_DIR]...
    ,nn_database.num_data_chunks);
%% call the function
[difference_vector,uc_samples] = test_UC_NN_error( final_db , sample_matrix , nn_database.params)

%% save output to file
save([argumentFileDir ,'/', nn_database.config.JOB_OUTPUT_FILENAME],'difference_vector','uc_samples');
