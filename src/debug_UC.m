load '/Users/galdalal/mount/PSCC16_continuation/current_version/output/UC_NN/saved_runs/Compare/compare_run_2016-07-25-10-49-55--1--case24/compare_saved_run'
load 'test2.mat'
sets_global_constants;
%% restore data
[final_db,sample_matrix] = restoreSplitData([nn_database.dirs.full_remoteRun_dir,'/',nn_database.config.SPLIT_DIR]);
%% call the function
[difference_vector,uc_samples] = test_UC_NN_error( final_db , sample_matrix , nn_database.params)

