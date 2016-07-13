function []=test_UC_NN_error_job(argeumentFileDir,argeumentFilename)
addHermesPaths;
if(strcmp('/u/gald/PSCC16_continuation/current_version',eval('pwd')))
    addpath(genpath('/u/gald/Asset_Management/matlab/matpower5.1/'));
    sets_global_constants;
end
rng('shuffle');
%% load arguments
loaded_arguments =load(argeumentFilename); % not really argument file name, but a hack to commonly load the same file
%% restore data
[final_db,sample_matrix] = restoreSplitData([loaded_arguments.fullRemoteParentDir,'/',loaded_arguments.split_dir]...
    ,loaded_arguments.num_data_chunks);
%% call the function
[difference_vector,uc_samples] = test_UC_NN_error( final_db , sample_matrix , loaded_arguments.params)

%% save output to file
save([argeumentFileDir , '/test_UC_NN_error_output.mat'],'difference_vector','uc_samples');