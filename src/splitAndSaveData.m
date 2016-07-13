function [split_data_loc,num_data_chunks] = splitAndSaveData(final_db,sample_matrix,fullLocalParentDir,split_dir)
chunk_length = 5e3; %empirically, this length results in ~200MB for final_db and ~70MB for sample_matrix
split_data_loc = [fullLocalParentDir,'/',split_dir];
mkdir(split_data_loc);

overall_length = length(sample_matrix); %should be identical to the length of final_db
splits_num = floor(overall_length/chunk_length);
split_length_last = mod(overall_length,chunk_length);
num_data_chunks = splits_num;
% [~,sample_matrix_split_dimension] = max(size(sample_matrix));
% [~,final_db_split_dimension] = max(size(final_db));

for i_chunk=1:splits_num
    curr_idx = 1 + chunk_length*(i_chunk-1):chunk_length*i_chunk;
    curr_sample_mat =  sample_matrix(:,curr_idx);
    curr_final_db = final_db(curr_idx);
    save([split_data_loc,'/data_chunk_',num2str(i_chunk)],'curr_sample_mat','curr_final_db');
end

if(split_length_last>0)
    num_data_chunks = num_data_chunks+1;
    curr_sample_mat =  sample_matrix(:,curr_idx(end)+1:curr_idx(end)+1+split_length_last-1);
    curr_final_db = final_db(curr_idx(end)+1:curr_idx(end)+1+split_length_last-1);
    save([split_data_loc,'/data_chunk_',num2str(i_chunk+1)],'curr_sample_mat','curr_final_db');
end
