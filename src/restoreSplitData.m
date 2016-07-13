function [final_db,sample_matrix] = restoreSplitData(split_data_loc,num_data_chunks)

final_db = [];
sample_matrix = [];

for i_chunk=1:num_data_chunks
    load([split_data_loc,'/data_chunk_',num2str(i_chunk),'.mat'],'curr_sample_mat','curr_final_db');
    sample_matrix=[sample_matrix,curr_sample_mat];
    final_db = [final_db;curr_final_db];
end