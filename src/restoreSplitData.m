function [final_db,sample_matrix] = restoreSplitData(split_data_loc)

final_db = [];
sample_matrix = [];

list = what(split_data_loc);
    
for i_file=1:length(list.mat)
    if(regexp(list.mat{i_file},'data_chunk')==1)
        load([split_data_loc,'/',list.mat{i_file}],'curr_sample_mat','curr_final_db');
        sample_matrix=[sample_matrix,curr_sample_mat];
        final_db = [final_db;curr_final_db];
    end
end