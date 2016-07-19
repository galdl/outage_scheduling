function [dirs,config] = build_dirs(prefix_num,config,caseName)
% builds all directory structure for current run
% INPUT:
% prefix_num - integer used to distinguish different instances of the
% algorithms from the cluster's point of view
local_dir_root  = config.LOCAL_DIR_ROOT;

if(config.remote_cluster)
    remote_dir_root = config.REMOTE_DIR_ROOT;
else
    remote_dir_root  = config.LOCAL_DIR_ROOT;
end

if (strcmp(config.run_mode,'optimize'))
    relative_dir = config.RELATIVE_DIR_OPTIMIZE;
else relative_dir = config.RELATIVE_DIR_COMPARE;
end;

dirs.job_dirname_prefix = config.JOB_DIRNAME_PREFIX;
run_dir=[config.run_mode,'_run_',datestr(clock,'yyyy-mm-dd-HH-MM-SS'),'--',num2str(prefix_num),'--',caseName];

dirs.full_localRun_dir  = [local_dir_root,relative_dir,run_dir];
if(isempty(dir(dirs.full_localRun_dir)))
    mkdir(dirs.full_localRun_dir);
end

dirs.full_remoteRun_dir = [remote_dir_root,relative_dir,run_dir];

local_tempFiles_dir = '';
remote_tempFiles_dir = '';

if(config.remote_cluster && isempty(dir(dirs.full_remoteRun_dir)))
    mkdir(dirs.full_localRun_dir,config.CLUSTER_OUTPUT_DIRNAME);
    mkdir(dirs.full_localRun_dir,config.CLUSTER_ERROR_DIRNAME);
    local_tempFiles_dir = [dirs.full_localRun_dir,config.TEMPFILES_DIR];
    remote_tempFiles_dir = [dirs.full_remoteRun_dir,config.TEMPFILES_DIR];
    mkdir(local_tempFiles_dir);
end
    
config.full_localRun_dir = dirs.full_localRun_dir;
config.full_remoteRun_dir = dirs.full_remoteRun_dir;

config.local_tempFiles_dir = local_tempFiles_dir;
config.remote_tempFiles_dir = remote_tempFiles_dir;

dirs.job_data_filename = config.JOB_DATA_FILENAME;
dirs.job_output_filename = config.JOB_OUTPUT_FILENAME;