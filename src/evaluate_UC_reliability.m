function [reliability,n1_matrix,connected] = evaluate_UC_reliability(uc_sample,params)
%% initialize
run('get_global_constants.m')
mpopt = mpoption('out.all', 0,'verbose', 0,'pf.alg','NR'); %NR(def), FDXB, FDBX, GS
cont_list_length = params.nl+1;
sz = [cont_list_length,params.horizon];
reliability = zeros(1,params.horizon);
pf_success = zeros(sz);
pf_violation = zeros(sz);
pg_prec_violation = zeros(sz);
n1_matrix = zeros(sz);
connected=1;
%% iterate on all hours of the day
for t = 1:params.horizon
    updatedMpcase = get_hourly_mpcase( t , uc_sample.onoff , uc_sample.Pg , uc_sample.windSpilled ,...
        uc_sample.demandScenario , uc_sample.windScenario , uc_sample.line_status, params , uc_sample.voltage_setpoints );
    %% N-1 criterion - N(=nl) possible single line outage
    for i_branch = 1:cont_list_length
        %     display(['i_branch value: ',num2str(i_branch)])
        newMpcase=updatedMpcase;
        if(~strcmp('case96',params.caseName))
            if(~checkConnectivity(newMpcase,params))
                display(['Not Connected for ',num2str(i_branch)]);
                if(i_branch==1)
%                     connected=0;
                    connected=1; %currently drop the 'connected' concept. Always assume connected, and set reliability to be 0
                    reliability=0;
                    return;
                end
            end
        end
        if(i_branch>1)
            %for i_branc==1, no contingencies.
            %for i_branc==2, 1st contingency, etc..
            newMpcase.branch(i_branch-1,BR_STATUS)=0;
        end
        if(sum(newMpcase.branch(:,BR_STATUS))==0)
            pfRes.success=0;
        else
            try
                pfRes=rundcpf(newMpcase,mpopt);
%                 pfRes=runpf(newMpcase,mpopt);
                
            catch
            end
        end
        pf_success(i_branch,t)=pfRes.success;
        if(pfRes.success)
            idx=find(uc_sample.onoff(:,t));
            pg_prec_violation(i_branch,t)=sum(abs(pfRes.gen(idx,PG)-newMpcase.gen(idx,PG)))/sum(newMpcase.gen(idx,PG));
            pf_violation(i_branch,t)=pfConstraintViolation(pfRes,params);
        end
    end
    
    n1_matrix(:,t) = pf_violation(:,t) | (1-pf_success(:,t));
    reliability(t)=1-mean(pf_violation(:,t) | (1-pf_success(:,t)));
    % OPF case: i think there has to be no violation in case there's success
end
end

%consider using matpower bult-in function:
%function [Fv, Pv, Qv, Vv] = checklimits(mpc, ac, quiet)
function violation = pfConstraintViolation(pfRes,params)
percentageTolerance=50; %how much of a percentage violation do we tolerate
[Fv, Pv] = checklimits(pfRes, 1, 1);
violation=1-(isempty(Fv.p) || max(Fv.p) <= percentageTolerance)*...
    (isempty(Pv.p) || max(Pv.p) <= percentageTolerance)*...
    (isempty(Pv.P) || max(Pv.P) <= percentageTolerance);
%Fv is flow violations, Fv.p is max flow percentage violations, Pv is
%generator violations (real power), Pv.p and Pv.P are upper and lower
%limit violations.
end

function updatedMpcase = get_hourly_mpcase( current_hour , onoff , Pg , windSpilled , demandScenario , windScenario ...
    , line_status, params ,voltage_setpoints )
%% initialize
run('get_global_constants.m');
mpcase = params.mpcase;
updatedMpcase = mpcase;

%% remove objective
updatedMpcase.gencost(:,2:end)=zeros(size(mpcase.gencost(:,2:end)));

%% set net demand
netDemand = demandScenario(:,current_hour) - (windScenario(:,current_hour) - windSpilled(:,current_hour));
updatedMpcase.bus(:,PD) = max(netDemand,0);

%% set generation commitment and levels
updatedMpcase.gen(:,GEN_STATUS) = onoff(:,current_hour);
updatedMpcase.gen(:,PG) = Pg(:,current_hour);
%% set voltage set points for case of runopf day-ahead plan - currently just for case96
if(~isempty(voltage_setpoints))
    updatedMpcase.gen(:,VG)=voltage_setpoints(:,current_hour);
end
%% set topology
updatedMpcase.branch(:,BR_STATUS)=line_status;
end
