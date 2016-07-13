function jobName=buildJobName(i_CE,i_plan,i_month,jobNamePrefix)
jobName=[jobNamePrefix , '-' , num2str(i_CE) , '-' , num2str(i_plan) , '-' , num2str(i_month)];