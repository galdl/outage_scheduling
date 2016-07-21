%can operate element-wise on vectors
function [f,g,H] = phi_p(t,p,lambda)
f=zeros(size(t));
g=f;
H=g;
%a loop is necessary since phi operates differently in 2 seperate regions
for i=1:length(t)
    [f(i),g(i),H(i)]=phi(p*t(i));
    f(i)=(f(i)/p)*lambda(i);
    g(i)=g(i)*lambda(i);
    H(i)=H(i)*p*lambda(i);
end
end
