function yearly_plan = generateYearlyPlan(p,epsilon,params)
ro = params.requested_outages;
% non_null_plan = zeros(num_assets,size(p,2));
yearly_plan=zeros(size(p));
% indexMat=reshape(1:length(p(:)),size(p));
shrinkage_vec = ones(1,size(p,2));
%% check weird plans
% if(rand<0.5)
%     shrinkage_vec(1:round(length(shrinkage_vec)/2))=0.05;
% else
%     shrinkage_vec(round(length(shrinkage_vec)/2):end)=0.05;
% end
%%
if(strcmp(params.caseName,'case96'))
    %when dealing with the zonal case, first allocate exclusive months per each zone
    [zonal_month_allocation,common_outages] = allocate_zonal_months(p,ro);
    %then, generate the plan per each zone the same way we do for the
    %non-zonal case (e.g. case24), solely for the allocated months
    for i_zone = 1:size(ro,2)
        shrinkage_vec = ones(1,size(zonal_month_allocation,2));
        for i_asset=setdiff(find(ro(:,i_zone))',common_outages)
            [drawn_row,shrinkage_vec] = draw_row(p(i_asset,zonal_month_allocation(i_zone,:)),ro(i_asset,i_zone),shrinkage_vec,epsilon,params);
            yearly_plan(i_asset,zonal_month_allocation(i_zone,:)) = drawn_row;
        end
    end
    %lastly, for the shared outages, perform the usual procedure without
    %month allocation
    shrinkage_vec = ones(1,size(p,2));
    for i_asset=common_outages'
        [drawn_row,shrinkage_vec] = draw_row(p(i_asset,:),ro(i_asset,1),shrinkage_vec,epsilon,params);
        yearly_plan(i_asset,:) = drawn_row;
    end
else
    for i_asset=find(ro)'
        [drawn_row,shrinkage_vec] = draw_row(p(i_asset,:),ro(i_asset),shrinkage_vec,epsilon,params);
        yearly_plan(i_asset,:) = drawn_row;
    end
end