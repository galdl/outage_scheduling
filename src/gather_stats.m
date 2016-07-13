N=length(final_db);
empties = nan(N,1);
successes = nan(N,1);
for i = 1:N
    empties(i) = isempty(final_db{i});
    if(~empties(i))
        successes(i) = final_db{i}.success;
    end
end
display(['Portion of empty trails: ',num2str(mean(empties))]);
display(['Portion of successes out of the good trails: ',num2str(mean(successes(~isnan(successes))))]);