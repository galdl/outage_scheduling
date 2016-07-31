function yearly_plan = generateYearlyPlan(p,epsilon,params)
ro = params.requested_outages;
% non_null_plan = zeros(num_assets,size(p,2));
yearly_plan=zeros(size(p));
% indexMat=reshape(1:length(p(:)),size(p));
shrinkage_vec = ones(1,size(p,2));
for i_asset=find(ro)'
    [drawn_row,shrinkage_vec] = draw_row(p(i_asset,:),ro(i_asset),shrinkage_vec,epsilon,params);
    yearly_plan(i_asset,:) = drawn_row;
end