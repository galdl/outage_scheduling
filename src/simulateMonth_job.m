function []=simulateMonth_job(argumentFileDir,argumentFilename)
addHermesPaths;
if(strcmp('/u/gald/PSCC16_continuation/current_version',eval('pwd')))
    addpath(genpath('/u/gald/Asset_Management/matlab/matpower5.1/'));
end
sets_global_constants;
rng('shuffle');
%% load arguments
loaded_arguments =load([argumentFileDir,'/',argumentFilename]);
%% call the function
[monthlyStats]=simulateMonth(loaded_arguments.i_month,loaded_arguments.maintenancePlan,loaded_arguments.db_file_path,loaded_arguments.params)

%% save output to file
save([loaded_arguments.mPlanDir ,loaded_arguments.config.JOB_OUTPUT_FILENAME,'_m_', num2str(i_month)],'monthlyStats');

% save([argeumentFileDir ,'/', loaded_arguments.config.JOB_OUTPUT_FILENAME],'difference_vector','uc_samples');
