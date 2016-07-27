function [] = add_data_chunk(curr_final_db,curr_sample_mat,split_data_loc)
% add a data chunk when running a continuous loop bdb job

list = what(split_data_loc);
i_chunk = length(list.mat)+1;
save([split_data_loc,'/data_chunk_',num2str(i_chunk)],'curr_sample_mat','curr_final_db');
