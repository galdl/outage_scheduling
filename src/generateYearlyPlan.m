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
    for i_asset=find(ro(:,1))'
        [drawn_row,shrinkage_vec] = draw_row(p(i_asset,:),ro(i_asset,1),shrinkage_vec,epsilon,params);
        yearly_plan(i_asset,:) = drawn_row;
    end
else
    for i_asset=find(ro)'
        [drawn_row,shrinkage_vec] = draw_row(p(i_asset,:),ro(i_asset),shrinkage_vec,epsilon,params);
        yearly_plan(i_asset,:) = drawn_row;
    end
end