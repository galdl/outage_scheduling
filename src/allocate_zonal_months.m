function [zonal_month_allocation,common_outages] = allocate_zonal_months(p,ro)
% For each zone, add all probabilities of outages that are distinct per
% each zone. Then, allocate months according to those zones (since we do
% not mix outages of different zones in the same month)


[r,c] = find(ro);
y = zeros(size(r));
for i = 1:length(r)
    y(i) = sum(r==r(i));
end



% 
common_outages = unique(r(find(y>1)));
likely_months_probabilities = zeros(size(ro,2),size(p,2));
for i_zone = 1:size(ro,2)
    r = setdiff(find(ro(:,i_zone)),common_outages);
    likely_months_probabilities(i_zone,:) = sum(p(r,:),1);
end

%currently, simply choose max four of each zone and allocate months
%accordingly (each zone gets equal amount of months)
zonal_month_allocation = zeros(size(ro,2),round(size(p,2)/size(ro,2)));
free_months = 1:size(p,2);
for i_zone = 1:size(ro,2)
    [~,idx] = sort(likely_months_probabilities(i_zone,free_months),'descend');
    inner_sorted = free_months(idx);
    zonal_month_allocation(i_zone,:) = inner_sorted(1:size(zonal_month_allocation,2));
    free_months = setdiff(free_months,zonal_month_allocation(i_zone,:));
end