function line_status = draw_contingencies(params)
get_global_constants
% line_status = (rand(params.nl,1)>params.failure_probability); %non-uniform, low failure probability 
line_status = (rand(params.nl,1)>0.5); %uniform failure probability. not changing the actual parameter since we still want params.failure_probability to be low
num_of_zones = size(params.requested_outages,2);
outage_zone = randsample(num_of_zones,1);
no_outage_zone = setdiff(1:num_of_zones,outage_zone);
%% keep only the contingencies that are relevant for the needed outages
if(sum(params.requested_outages)>0)
    possible_outages = (params.requested_outages>0);
    line_status(logical(1-possible_outages(:,outage_zone))) = 1;
end

line_status(params.mpcase.branch(:,BR_STATUS)==0) = 0 ;
%% o
% line_status=ones(params.nl,1);
% num_outage_sets = 2^(sum(params.requested_outages>0));
% dec_num = randsample(num_outage_sets,1);
% chosen_status = params.binary_mat(dec_num,:);
% line_status((params.requested_outages>0)) = chosen_status;
% mat=dec2bin(0:num_outage_sets-1)-'0';
% bin_num = dec2bin(dec_num);
% padded_bin_num = [zeros(1,numel(num2str(dec2bin(num_outage_sets-1))) - numel(num2str(bin_num))),bin_num];
% line_status(params.mpcase.branch(:,BR_STATUS)==0) = 0 ;

