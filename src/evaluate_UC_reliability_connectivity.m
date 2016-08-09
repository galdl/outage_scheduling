function [reliability,n1_matrix,connected] = evaluate_UC_reliability_connectivity(uc_sample,params)
run('get_global_constants.m')

cont_list_length = params.nl;
success = zeros(cont_list_length,1);
updatedMpcase = params.mpcase;
updatedMpcase.branch(:,BR_STATUS)=uc_sample.line_status;
connected=1;
reliability=zeros(1,params.horizon);
n1_matrix=0;

%% if with no contingency it is not connected - finish
if((~strcmp('case96',params.caseName) && ~checkConnectivity(updatedMpcase,params)))
    display('Not Connected for no contingencies!');
    connected=1; %currently drop the 'connected' concept. Always assume connected, and set reliability to be 0
    return;
end
%% N-1 criterion - N(=nl) possible single line outage
for i_branch = 1:cont_list_length
    newMpcase=updatedMpcase;
    newMpcase.branch(i_branch,BR_STATUS)=0;
    success(i_branch)=checkConnectivity(newMpcase,params);
end

reliability=mean(success)*ones(1,params.horizon);
