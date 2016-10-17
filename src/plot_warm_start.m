%% for OPTIMIZE data
if(strcmp(config.run_mode,'optimize'))
    solution_time_vec = zeros(length(test_final_db),2);
    for i_sample = 1:length(test_final_db)
        solution_time_vec(i_sample,:) = test_final_db{i_sample}.solution_time([1,3]);
    end
else
    %% for COMPARE data
    % length(finished_idx)/length(uc_samples)
    % uc_samples = uc_samples(finished_idx);
    solution_time_vec = zeros(length(uc_samples),3);
    net_demand = zeros(length(uc_samples),1);
    sum_line_status = zeros(length(uc_samples),1);
    for i_sample = 1:length(uc_samples)
        solution_time_vec(i_sample,:) = uc_samples{i_sample}.solution_time;
        net_demand(i_sample) = sum(sum(uc_samples{i_sample}.demandScenario - uc_samples{i_sample}.windScenario));
        sum_line_status(i_sample) = sum(uc_samples{i_sample}.line_status);
    end
    
    %% compuation time ratio comparison
    ratio = solution_time_vec(:,1)./solution_time_vec(:,2);
    figure;
    [v,i] = sort(ratio);
    hist(100*ratio(i(1:end-3)),length(uc_samples));
    xlim([0,700]);
    
    accelerated_portion = length(ratio(ratio>1))/length(ratio);
    acceleration_average = mean(ratio(ratio>1));
    slowDown_average = mean(ratio(ratio<=1));
    display([params.caseName,': ',num2str(accelerated_portion),' of the samples were accelerated. Average acceleration (percentage): ',  num2str(100*acceleration_average-100)]);
    display([params.caseName,': ',num2str(1 - accelerated_portion),' of the samples were decelerated. Average acceleration (percentage): ',  num2str(100*slowDown_average-100)]);
    
    
    %% overall compuation time comparison
    figure;
    handles=zeros(2,1);
    handles(1) = subplot(2,1,1);
    hist(solution_time_vec(:,1),300);
    mean(solution_time_vec(:,1))
    median(solution_time_vec(:,1))
    
    handles(2) = subplot(2,1,2);
    hist(solution_time_vec(:,2),300);
    mean(solution_time_vec(:,2))
    median(solution_time_vec(:,2))
    
    % linkaxes(handles,'xy');
    
    
    
    %% categorize according to line_status
    figure;
    plot(sort(sum_line_status));
    figure;
    k=7;
    [line_categories,line_C] = kmeans(sum_line_status,k);
    plot(sort(line_C));
    
    figure;
    line_category_type = unique(line_categories);
    handles=zeros(length(line_category_type),1);
    for i_category = 1:length(line_category_type)
        handles(i_category) = subplot(2,4,i_category);
        %     i_category
        vals=ratio(line_categories==i_category);
        accelerated_portion = length(vals(vals>1))/length(vals)
        %     mean()
        %     median(ratio(categories==i_category))
        hist(vals,sum((line_categories==i_category)));
        xlim([0,2]);
    end
    
    
    %% categorize according to net demand
    
    figure;
    plot(sort(net_demand));
    figure;
    k=8;
    [categories,C] = kmeans(net_demand,k);
    plot(sort(C));
    
    figure;
    category_type = unique(categories);
    handles=zeros(length(category_type),1);
    for i_category = 1:length(category_type)
        handles(i_category) = subplot(2,4,i_category);
        %     i_category
        vals=ratio(categories==i_category);
        accelerated_portion = length(vals(vals>1))/length(vals)
        %     mean()
        %     median(ratio(categories==i_category))
        hist(vals,sum((categories==i_category)));
        xlim([0,2]);
    end
    % linkaxes(handles,'xy');
end

