argumentFileDir = '/Users/galdalal/mount/PSCC16_continuation/current_version/output/Outage_scheduling/saved_runs/Optimize/optimize_run_2016-08-04-16-24-16--1--case24/iteration_1/plan_1';
argumentFilename = 'optimize_job_content_m_1';
sets_global_constants;
%% load from save
load('test7')
%% or from computer
% nn_database =load(loaded_arguments.db_file_path); % all information needed is in the DB
% %% restore data
% [final_db,sample_matrix] = restoreSplitData([nn_database.dirs.full_remoteRun_dir,'/',nn_database.config.SPLIT_DIR]);
% nn_db.final_db = final_db; nn_db.sample_matrix = sample_matrix;
for i_month=2:8
    argumentFilename(end)=num2str(i_month);
    loaded_arguments =load([argumentFileDir,'/',argumentFilename]);
    [monthlyStats]=simulateMonth(loaded_arguments.i_month,loaded_arguments.maintenancePlan,nn_db,loaded_arguments.params);
    monthlyStats{1}.success_rate
end