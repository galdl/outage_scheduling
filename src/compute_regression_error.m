function [relative_error,correlation,average_NN_distance] = compute_regression_error(train_final_db,train_sample_matrix,test_final_db,params,plot_mode,case_title)
params.KNN=1;

x_vals = zeros(length(test_final_db),1);
y_vals = zeros(length(test_final_db),1);
NN_distances = zeros(length(test_final_db),1);
for i_sample=1:length(test_final_db)
    curr_sample = test_final_db{i_sample};
    x_vals(i_sample) = curr_sample.objective;
    [NN_uc_sample_vec,~,NN_distance] = get_uc_NN(train_final_db,train_sample_matrix,curr_sample,params);
    y_vals(i_sample) = NN_uc_sample_vec{1}.objective;
    NN_distances(i_sample) = NN_distance;
end

error_vec = abs(y_vals - x_vals)./x_vals;
relative_error(1) = mean(error_vec);
relative_error(2) = std(error_vec);
[correlation,~] = corr(x_vals,y_vals);

if(plot_mode)
    figure;
    scatter(x_vals,y_vals,3);
    font_size=17;
    title([case_title,' - cost scatter of exact vs. NN'],'FontSize', font_size);
    xlabel('Exact UC solution [$]', 'FontSize', font_size)
    ylabel('NN UC solution cost [$]', 'FontSize', font_size)
    set(gca,'fontsize',font_size);
end

average_NN_distance = mean(NN_distances);