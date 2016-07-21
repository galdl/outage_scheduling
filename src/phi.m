function [f,g,H] = phi(t)
if(t>=-0.5)
    f=0.5*t.^2+t;
    if (nargout>1)
        g=t+1;
    end
    if (nargout>2)
        H=1;
    end
else
    f=-0.25*log10(-2*t)-3/8;
    if (nargout>1)
        g=0.5/((log(10)*(-2*t)));
    end
    if (nargout>2)
        H=0.25/(log(10)*(t^2));
    end
end
end