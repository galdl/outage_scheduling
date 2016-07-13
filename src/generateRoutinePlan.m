function maintainRoutinePlan=generateRoutinePlan(params)
maintainRoutinePlan=zeros(params.nl,params.numOfMonths);
for i_m=1:params.numOfMonths
    maintainRoutinePlan(mod(i_m-1,params.nl)+1,i_m)=1;
end