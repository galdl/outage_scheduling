%% Configuration file is used for setting environment params, such as paths

% set run mode - optimize and find optimal plan, or compare to other
%algorithms
config.run_mode = 'optimize'; %'optimize','compare'
config.remote_cluster = true; %true,false
%% Local paths - on the machine running main
config.LOCAL_DIR_ROOT  = '~/mount/PSCC16_continuation/current_version/'; %'~/mount/ICML16/'
config.JOB_OUTPUT_FILENAME = [config.run_mode,'-job_output.mat'];
config.RTS96_filePath = '/matpower_cases/ieee_RTS96_UW';
config.JOB_DATA_FILENAME = [config.run_mode,'_job_content'];
config.SAVE_FILENAME = [config.run_mode,'_saved_data'];

%% Remote paths - on the server running the jobs 
% (setting whether such server is used is done with 'remote_cluster' variable)
config.REMOTE_DIR_ROOT = '/u/gald/PSCC16_continuation/current_version/';

% relative dir is shared among the local and remote dirs. 
config.RELATIVE_DIR_OPTIMIZE    = 'output/UC_NN/saved_runs/Optimize/';
config.RELATIVE_DIR_COMPARE = 'output/UC_NN/saved_runs/Compare/';

config.JOB_DIRNAME_PREFIX = 'job_data_';
config.CLUSTER_OUTPUT_DIRNAME = 'output';
config.CLUSTER_ERROR_DIRNAME = 'error';
config.TEMPFILES_DIR = '/tempJobFiles';
config.JOB_NAME_PREFIX = [config.run_mode,'_job'];
% the portions of the jobs that returned from the server, to 
config.fraction_of_finished_jobs=0.95;
