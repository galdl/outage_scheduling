function [upper_perc_err,lower_perc_err] = calc_percentiles(data,upper_perc,lower_perc)
%calculate percentile values (to be for asymmetric errorbars, instead of
%std) 
if(nargin<=1)
    upper_perc = 0.5+0.341;
    lower_perc = 0.5-0.341;
end
upper_perc_err = zeros(size(data,1),1);
lower_perc_err = zeros(size(data,1),1);
for i_row = 1:size(data,1)
    curr_row = data(i_row,:);
    sorted_data = sort(curr_row);
    upper_perc_err(i_row) = sorted_data(round(length(sorted_data)*upper_perc)) - median(curr_row);
    lower_perc_err(i_row) = median(curr_row) - sorted_data(round(length(sorted_data)*lower_perc));
end
