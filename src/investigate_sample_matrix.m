%% how many failed solutions
first_row = sample_matrix(1,:);
sum(isnan(first_row))/length(first_row)
sample_matrix_b = sample_matrix;

t=1:length(first_row);
modulated_idx = 1+mod(t-1,length(params.categories));
no_nan_idx = find(~isnan(first_row));
modulated_idx_no_nan = modulated_idx(no_nan_idx);
sample_matrix = sample_matrix(:,no_nan_idx);
final_db_b = final_db;
final_db(find(isnan(first_row)))=[];

no_success = [];
for i_sample = 1:length(final_db)
    if(~final_db{i_sample}.success)
        no_success = [no_success,i_sample];
    end
end
length(no_success)/length(final_db)
final_db(no_success) = [];
sample_matrix(:,no_success) = [];

%% check cost behavior compared to a specific line_status
% line_status = [0;0;1;1;0;ones(params.nl-5,1)];
% % vec_sample = [uc_sample.line_status(:);uc_sample.windScenario(:);uc_sample.demandScenario(:)];
% vec_sample = line_status;
% 
% status_diff_mat = sample_matrix(1:params.nl,:)-repmat(vec_sample,[1,size(sample_matrix,2)]);
% status_dist = sum(abs(status_diff_mat),1);
% figure;
% % hist(status_dist,100);
% dist_idx_vals = zeros(7,2);
% for d=1:7
%     curr_idx = find(status_dist==d);
%     temp_obj_vec = [];
%     for i_sample=curr_idx
%         temp_obj_vec = [temp_obj_vec,final_db{i_sample}.objective];
%     end
%     dist_idx_vals(d,1) = mean(temp_obj_vec);
%     dist_idx_vals(d,2) = std(temp_obj_vec);
% end
% errorbar(dist_idx_vals(:,1),dist_idx_vals(:,2));
% sample_matrix_a = sample_matrix;
% status_sample_matrix_a = status_sample_matrix;
% K=3e3;
% status_sample_matrix = zeros(params.nl,K);
% for k=1:K
%     status_sample_matrix(:,k) = draw_contingencies(params);
% end
%% check cost behavior of all unique line_status values
j=1;
%         (1+mod(i_job-1,length(params.categories)));

status_sample_matrix = sample_matrix(1:params.nl,:);
[C,ia,ic] = unique(status_sample_matrix','rows');
C=C';
unique_status_amount = size(C,2);
amount_of_each_type = zeros(unique_status_amount,1);
cost_stats = zeros(unique_status_amount,2,length(params.categories));
for i_curr_status=1:unique_status_amount
    curr_status = C(:,i_curr_status);
    status_diff_mat = status_sample_matrix -repmat(curr_status,[1,size(status_sample_matrix,2)]);
    status_dist = sum(abs(status_diff_mat),1);
    curr_idx = find(status_dist==0);
    amount_of_each_type(i_curr_status)=length(curr_idx);
    category_stats=cell(length(params.categories),1);
    for i_sample=curr_idx
        cat = find(params.categories == final_db{i_sample}.category);
        category_stats{cat} = [category_stats{cat},final_db{i_sample}.objective];
    end
    for cat = 1:length(params.categories)
        cost_stats(i_curr_status,1,cat) = mean(category_stats{cat});
        cost_stats(i_curr_status,2,cat) = std(category_stats{cat});
    end
end
%% plot std of cost for different line_status, across different categories
figure;
j=1:7;

status_cost = nanmean(cost_stats(:,1,j),3); %averaged over demand-wind categories
[status_cost_sorted,status_cost_idx] = sort(status_cost);
status_cost_std = nanstd(cost_stats(:,1,j),[],3);
errorbar(status_cost_sorted,status_cost_std(status_cost_idx),'rx') ;
figure;
plot(params.nl-sum(C(:,status_cost_idx))); %shows the number of contingencies as the cost increases
%% plot std of cost for different line_status, for the same category
figure;
for j=1:length(params.categories)
    status_cost = cost_stats(:,1,j); %averaged over demand-wind categories
    status_cost = status_cost(~isnan(status_cost));
    status_cost_std = cost_stats(:,2,j);
    status_cost_std = status_cost_std(~isnan(status_cost_std));
    
    [status_cost_sorted,status_cost_idx] = sort(status_cost);
    subplot(3,3,j);
    errorbar(status_cost_sorted,status_cost_std(status_cost_idx),'rx') ;
end

%% plot std of cost for different line_status, for all categories

s_handles = zeros(length(params.categories),1);
figure;
for j=1:length(params.categories)
    status_cost = nanmean(cost_stats(:,1,j),3); %averaged over demand-wind categories
    [status_cost_sorted,status_cost_idx] = sort(status_cost);
    status_cost_std = nanstd(cost_stats(:,1,j),[],3);
    s_handles(j) = subplot(3,3,j);
    errorbar(status_cost_sorted,status_cost_std(status_cost_idx)) ;
    ylim([0,4e6]);
end
% linkaxes(s_handles,'xy');

% errorbar(cost_stats(:,1),cost_stats(:,2),'rx');

% bar(amount_of_each_type);
% figure;
% hist(amount_of_each_type,100);

%% plot cost scatter of exact vs. NN - varying train size
%% use only the train set by splitting to test and train (possible since we only care about the cost now)
final_db_cost_vals = zeros(length(final_db),1);
% for i_sample = 1:length(final_db)
%     final_db_cost_vals(i_sample) = final_db{i_sample}.objective;
% end
permuted_idx = randperm(size(sample_matrix,2));
test_size = 1000;
test_idx = permuted_idx(1:test_size);
test_final_db = final_db(test_idx); % not to be confused with final_db_test
test_sample_matrix = sample_matrix(:,test_idx);
train_size_vec = [100,500,1e3:1e3:(length(final_db)-test_size)];
if(strcmp(params.caseName,'case24'))
    train_size_vec = [100,300,600,1000,1500,2000,2500,3500,4500,6000];
    case_title = 'IEEE-RTS79';
else
    case_title = 'IEEE-RTS96';
end
relative_error_vec = zeros(length(train_size_vec),2);
correlation_vec = zeros(length(train_size_vec),1);
average_NN_distance_vec = zeros(length(train_size_vec),1);

for i_size = 1:length(train_size_vec) 
    train_idx = permuted_idx(test_size+1:test_size+1+train_size_vec(i_size));
    train_final_db = final_db(train_idx);
    train_sample_matrix = sample_matrix(:,train_idx);
    [relative_error,correlation,average_NN_distance] = compute_regression_error(train_final_db,train_sample_matrix,test_final_db,params,false,case_title);
    relative_error_vec(i_size,:) = relative_error;
    correlation_vec(i_size) = correlation;
    average_NN_distance_vec(i_size) = average_NN_distance;
end
%% plot as a function of train set size
font_size=17;
figure;
xHandles(1)=subplot(3,1,1);
errorbar(train_size_vec,relative_error_vec(:,1),relative_error_vec(:,2));
title([case_title,' - average relative error as function train set size'],'FontSize', font_size);
set(gca,'fontsize',font_size);
xlim([0,train_size_vec(end)+200]);
xlabel('Train set size');
ylabel('Average relative error');

xHandles(2)=subplot(3,1,2);
plot(train_size_vec,correlation_vec);
title([case_title,' linear correlation as function train set size'],'FontSize', font_size);
set(gca,'fontsize',font_size);
xlim([0,train_size_vec(end)+200]);
xlabel('Train set size');
ylabel('Linear correlation');

xHandles(3)=subplot(3,1,3);
plot(train_size_vec,average_NN_distance_vec);
title([case_title,' average NN distance as function train set size'],'FontSize', font_size);
set(gca,'fontsize',font_size);
xlim([0,train_size_vec(end)+200]);
xlabel('Train set size');
ylabel('Average NN distance');
%% plot overall 
[relative_error,correlation] = compute_regression_error(train_final_db,train_sample_matrix,test_final_db,params,true,case_title);

% linkaxes(xHandles,'xy');


% subplot(3,1,3);
% % plot(train_size_vec/(length(final_db)-test_size));
% plot(train_size_vec);
% title('ac','FontSize', font_size);
% set(gca,'fontsize',font_size);

