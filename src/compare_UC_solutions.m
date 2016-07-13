function [reliability_difference,n1_matrix_difference,reliability_orig,reliability_NN,connected] = compare_UC_solutions(uc_sample_orig , uc_sample_NN_vec , params , KNN)   
[reliability_orig,n1_matrix_orig,connected1] = evaluate_UC_reliability(uc_sample_orig,params);
reliability_NN = [];
for i_NN = 1:KNN
    if(KNN==1)
        curr_sample = uc_sample_NN_vec;
    else curr_sample = uc_sample_NN_vec{i_NN};
    end
    [reliability_NN_single,n1_matrix_NN,connected2] = evaluate_UC_reliability(curr_sample,params);
    reliability_NN_single = mean(reliability_NN_single);
    reliability_NN=[reliability_NN,reliability_NN_single];
end
reliability_difference = norm(reliability_orig-reliability_NN_single(1));
n1_matrix_difference = norm(n1_matrix_orig-n1_matrix_NN);
reliability_orig = mean(reliability_orig);
connected = connected1*connected2;