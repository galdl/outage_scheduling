function []=simulateMonth_job(argumentFileDir,argumentFilename)
addHermesPaths;
if(strcmp('/u/gald/PSCC16_continuation/current_version',eval('pwd')))
    addpath(genpath('/u/gald/Asset_Management/matlab/matpower5.1/'));
end
set_global_constants;
rng('shuffle');
%% load arguments
loaded_arguments =load([argumentFileDir,'/',argumentFilename]);
nn_database =load(loaded_arguments.db_file_path); % all information needed is in the DB
%% restore data
[final_db,sample_matrix] = restoreSplitData([nn_database.dirs.full_remoteRun_dir,'/',nn_database.config.SPLIT_DIR]);
nn_db.final_db = final_db; nn_db.sample_matrix = sample_matrix;
%% call the function
[monthlyStats]=simulateMonth(loaded_arguments.i_month,loaded_arguments.maintenancePlan,nn_db,loaded_arguments.params)

%% save output to file
clear nn_db
save([loaded_arguments.remotePlanDir,'/',loaded_arguments.config.JOB_OUTPUT_FILENAME,'_m_',num2str(loaded_arguments.i_month)],'monthlyStats');
