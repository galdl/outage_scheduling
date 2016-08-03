figure(1);
for d=1:3
    try
    sr = success_rate(1+(d-1)*120:d*120);
    subplot(1,3,d);
    hist(sr);
    catch
    end
end