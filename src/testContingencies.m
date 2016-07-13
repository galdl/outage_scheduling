H =  @(t, sigmat,eta,alpha,gamma, s) (1-exp(-eta*(alpha*exp(gamma*sigmat)*t)^s));
% based on the "Monte Carlo Simulation of the time dependent failure of
% bundles of parallel fibers.pdf"
eta = 0.005; alpha = 0.1; gamma=0.012; s=0.05; t = 1; sigmat = 12*30*24; 
if(true)
figure(1);
    etas = 0:eta/100:eta*3;
    res = nan(size(etas));
    for i = 1:length(etas)
        teta = etas(i);
        res(i) = H(t,sigmat,teta,alpha,gamma, s);
    end
    subplot(5,1,1); plot(etas,res); title('eta')

    alphas = 0.000001:alpha/100:alpha*3;
    res = nan(size(alphas));
    for i = 1:length(alphas)
        talpha = alphas(i);
        res(i) = H(t,sigmat,eta,talpha,gamma, s);
    end
    subplot(5,1,2); semilogx(alphas,res); title('alpha')

    gammas = 0:gamma/100:gamma*3;
    res = nan(size(gammas));
    for i = 1:length(gammas)
        tgamma = gammas(i);
        res(i) = H(t,sigmat,eta,alpha,tgamma, s);
    end
    subplot(5,1,3); plot(gammas,res); title('gamma')

    ss = 0:s/100:s*3;
    res = nan(size(ss));
    for i = 1:length(ss)
        ts = ss(i);
        res(i) = H(t,sigmat,eta,alpha,gamma, ts);
    end
    subplot(5,1,4); plot(ss,res); title('s')

    sigmats = 0:sigmat/100:sigmat*3;
    res = nan(size(sigmats));
    for i = 1:length(sigmats)
        tsigmat = sigmats(i);
        res(i) = H(t,tsigmat,eta,alpha,gamma, s);
    end
    subplot(5,1,5); plot(sigmats,res); title('sigmat')
end

if(false)
    nepocs = 100;
    res = nan(nepocs,length(ts));
    for epoc = 1:nepocs
        sigma_t = 0;
        ts = 1:500;
        for i = ts
            pl = 15*rand;
            rating = 3;
%             sigma_t = sigma_t+pl/rating;
            sigma_t = sigma_t+t;
            res(epoc,i) = rand < H(1, sigma_t, eta, alpha, gamma, s);
        end
    end
    figure(2);
    m = mean(res)';
    s = std(res)';
    plot(ts,nepocs*[m,min(m+s,1),max(m-s,0)])
end