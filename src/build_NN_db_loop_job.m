function []=build_NN_db_loop_job(argeumentFileDir,argeumentFilename)
addHermesPaths;
if(strcmp('/u/gald/PSCC16_continuation/current_version',eval('pwd')))
    addpath(genpath('/u/gald/Asset_Management/matlab/matpower5.1/'));
    set_global_constants;
end
rng('shuffle');
%% load arguments
loaded_arguments =load([argeumentFileDir,'/',argeumentFilename]);
split_data_loc = [argeumentFileDir,'/..',loaded_arguments.config.SPLIT_DIR];

%% constantly gather more and more samples and save them to the DB
i=0;
while(true)
    i=i+1;
    sample_db = build_NN_db(loaded_arguments.params);
    sample_matrix = nan(calculate_sample_matrix_size(loaded_arguments.params,1));
    final_db = cell(size(sample_matrix,2),1);
    for i_sample = 1:length(sample_db)
        vec = [sample_db{i_sample}.line_status;sample_db{i_sample}.windScenario(:);sample_db{i_sample}.demandScenario(:)];
        sample_matrix(:,i_sample)=vec;
        final_db{i_sample} = sample_db{i_sample};
    end
    
    add_data_chunk(final_db,sample_matrix,split_data_loc);
    display(['Finished running iteration ',num2str(i)]);
end
