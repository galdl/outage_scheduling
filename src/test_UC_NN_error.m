function [difference_vector,uc_samples] = test_UC_NN_error( final_db , sample_matrix , params)
% column 1 : norm of reliability vector difference across different trials
% column 2 : norm of N-1 matrix difference across different trials
% column 3 : norm of reliability vector difference across different trials
% - db random mode
% column 4 : norm of N-1 matrix difference across different trials - db
% random mode
%% test how feasible NN solutions are
N_test = params.N_samples_test;
N_test = 1;
if(params.db_rand_mode)
    vec_size = 7+params.KNN;
else vec_size = 3+params.KNN; 
end
difference_vector = nan(N_test,vec_size);
mod_interval=50;
state = getInitialState(params);
isStochastic=1;
uc_samples = cell(N_test,3);
for j=1:N_test
    try
    if(mod(j,mod_interval)==1)
        display(['Test iteration ',num2str(j),' out of ',num2str(N_test)]);
        tic
    end
    %% draw stochastic variables of the new sample
    [demandScenario,windScenario] = generateDemandWind_with_category(1:params.horizon,params,state,isStochastic);
    uc_sample_orig.windScenario = windScenario;
    uc_sample_orig.demandScenario = demandScenario;
    uc_sample_orig.line_status = draw_contingencies(params);
    
    %% find K nearest neighbours
    [NN_uc_sample_vec,NN_uc_sample_rand]= get_uc_NN(final_db,sample_matrix,uc_sample_orig,params);
    tic
    % compute optimal UC plan for the drawn case
    uc_sample_orig = run_UC(params.n1_str , state , uc_sample_orig.demandScenario , uc_sample_orig.windScenario , uc_sample_orig.line_status, params);
    uc_samples{j,1} = uc_sample_orig;
    uc_samples{j,2} = NN_uc_sample_vec;
    uc_samples{j,3} = NN_uc_sample_rand;
    %till this point - no crashes
    %% compute the difference in reliability for the two plans (do it twice in db rand mode)
    if(uc_sample_orig.success)
        display([datestr(clock,'yyyy-mm-dd-HH-MM-SS'),'-success in iteration ',num2str(j)]);

        [reliability_difference1,n1_matrix_difference1,reliability_orig,reliability_NN,connected_nn] = ...
            compare_UC_solutions(uc_sample_orig , NN_uc_sample_vec , params , params.KNN);
        if(connected_nn)
            difference_vector(j,1:3+params.KNN) = [reliability_difference1,n1_matrix_difference1,reliability_orig,reliability_NN]';
        end

        % if db rand NN mode, return also its difference for comparison with actual NN
        if(params.db_rand_mode)
            [reliability_difference_rand,n1_matrix_difference_rand,reliability_orig_rand,reliability_NN_rand,connected_rand] = ...
                compare_UC_solutions(uc_sample_orig , NN_uc_sample_rand , params , 1);
            if(connected_rand)
                difference_vector(j,4+params.KNN:7+params.KNN) = [reliability_difference_rand,n1_matrix_difference_rand,reliability_orig_rand,reliability_NN_rand]';
            end
            
        end
    end
     catch ME
         program_path = strsplit(mfilename('fullpath'),'/');
        program_matlab_name = program_path{end};
        warning(['Problem using ',program_matlab_name,' for iteration = ' num2str(j)]);
        msgString = getReport(ME);
        display(msgString);
    end
     display('here1');
    if(mod(j,mod_interval)==0)
        toc
    end
end
