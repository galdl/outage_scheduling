function config = configuration(program_name,run_mode)
%% Configuration file is used for setting environment params, such as paths

% set run mode - optimize and find optimal plan, or compare to other
%algorithms
config.program_name = program_name;
config.run_mode = run_mode;
config.remote_cluster = true; %true,false
%% Local paths - on the machine running main
config.LOCAL_DIR_ROOT  = '~/mount/PSCC16_continuation/current_version/'; %'~/mount/ICML16/'
config.JOB_OUTPUT_FILENAME = [config.run_mode,'_job_output'];
config.RTS96_filePath = '/matpower_cases/ieee_RTS96_UW';
config.JOB_DATA_FILENAME = [config.run_mode,'_job_content'];
config.SAVE_FILENAME = [config.run_mode,'_saved_run'];

%% Remote paths - on the server running the jobs 
% (setting whether such server is used is done with 'remote_cluster' variable)
config.REMOTE_DIR_ROOT = '/u/gald/PSCC16_continuation/current_version/';
config.REMOTE_SERVER_MATLAB_WORKPATH = '/u/gald/PSCC16_continuation/current_version/src';
config.REMOTE_SERVER_MATLAB_PROGRAM_PATH = '/usr/local/bin/matlab2016a'; %matlab2015b,matlab2016a
% relative dir is shared among the local and remote dirs. 
if(strcmp(config.program_name,'outage_scheduling'))
    folder = 'Outage_scheduling';
    config.memory_used = 4;
else
    folder = 'UC_NN';
    config.memory_used = 8;
end
config.RELATIVE_DIR_OPTIMIZE    = ['output/',folder,'/saved_runs/Optimize/'];
config.RELATIVE_DIR_COMPARE = ['output/',folder,'/saved_runs/Compare/'];

config.JOB_DIRNAME_PREFIX = 'job_data_';
config.CLUSTER_OUTPUT_DIRNAME = 'output';
config.CLUSTER_ERROR_DIRNAME = 'error';
config.TEMPFILES_DIR = '/tempJobFiles/';
config.JOB_NAME_PREFIX = [config.program_name(1:2),'_',config.run_mode(1:2)];
% the portions of the jobs that returned from the server, to 
config.fraction_of_finished_jobs=0.95;

config.PLAN_DIRNAME_PREFIX = 'plan_';
config.SPLIT_DIR = '/split_data';

