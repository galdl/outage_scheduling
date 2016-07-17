%% Configuration file is used for setting environment params, such as paths

% set run mode - optimize and find optimal plan, or compare to other
%algorithms
config.application = 'uc_nn'; %'outage_scheduling','uc_nn'
config.run_mode = 'optimize'; %'optimize','compare' (also referred to as 'train' and 'evaluate' in the code)
config.remote_cluster = true; %true,false
%% Local paths - on the machine running main
config.LOCAL_DIR_ROOT  = '~/mount/PSCC16_continuation/current_version/'; %'~/mount/ICML16/'
config.JOB_OUTPUT_FILENAME = [config.run_mode,'_job_output.mat'];
config.RTS96_filePath = '/matpower_cases/ieee_RTS96_UW';
config.JOB_DATA_FILENAME = [config.run_mode,'_job_content'];
config.SAVE_FILENAME = [config.run_mode,'_saved_run'];

%% Remote paths - on the server running the jobs 
% (setting whether such server is used is done with 'remote_cluster' variable)
config.REMOTE_DIR_ROOT = '/u/gald/PSCC16_continuation/current_version/';
config.REMOTE_SERVER_MATLAB_WORKPATH = '/u/gald/PSCC16_continuation/current_version/src';
% relative dir is shared among the local and remote dirs. 
if(strcmp(config.application,'outage_scheduling'))
    folder = 'Outage_scheduling';
else
    folder = 'UC_NN';
end
config.RELATIVE_DIR_OPTIMIZE    = ['output/',folder,'/saved_runs/Optimize/'];
config.RELATIVE_DIR_COMPARE = ['output/',folder,'/saved_runs/Compare/'];

config.JOB_DIRNAME_PREFIX = 'job_data_';
config.CLUSTER_OUTPUT_DIRNAME = 'output';
config.CLUSTER_ERROR_DIRNAME = 'error';
config.TEMPFILES_DIR = '/tempJobFiles/';
config.JOB_NAME_PREFIX = [config.application(1:2),'_',config.run_mode(1:3)];
% the portions of the jobs that returned from the server, to 
config.fraction_of_finished_jobs=0.95;

config.PLAN_DIRNAME_PREFIX = 'plan_';
config.SPLIT_DIR = '/split_data';