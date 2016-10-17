function [final_db_test,uc_samples] = restoreSplitData_compare(split_data_loc)

final_db_test = [];
uc_samples = [];

list = what(split_data_loc);
    
for i_file=1:length(list.mat)
    if(regexp(list.mat{i_file},'data_chunk')==1)
        load([split_data_loc,'/',list.mat{i_file}],'curr_uc_samples','curr_final_db_test');
        uc_samples=[uc_samples,curr_uc_samples];
        final_db_test = [final_db_test;curr_final_db_test];
    end
%     i_file
end

% split_data_loc = [split_data_loc,'_extra'];
% list = what(split_data_loc);
% for i_file=1:length(list.mat)
%     if(regexp(list.mat{i_file},'data_chunk')==1)
%         load([split_data_loc,'/',list.mat{i_file}],'curr_sample_mat','curr_final_db');
%         sample_matrix=[sample_matrix,curr_sample_mat];
%         final_db = [final_db;curr_final_db];
%     end
%     i_file
% end