function line_status = draw_contingencies(params)
get_global_constants
line_status = (rand(params.nl,1)>params.failure_probability);
%% keep only the contingencies that are relevant for the needed outages
if(sum(params.requested_outages)>0)
    possible_outages = (params.requested_outages>0);
    line_status(logical(1-possible_outages)) = 1;
end

line_status(params.mpcase.branch(:,BR_STATUS)==0) = 0 ;