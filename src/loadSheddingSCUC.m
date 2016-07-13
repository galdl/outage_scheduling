function [Pg,objective,onoff,y,demandVector,success,windSpilled,loadLost] = loadSheddingSCUC(params,state,dynamicUCParams)
success=0;
i=1;
loadsRemoved=zeros(params.nb,1);
define_constants;
currentBus=params.mpcase.bus;

while (~success)
    loads=currentBus(:,PD);
    positiveLoads=loads(loads>0); %TODO: fix - only positive locations
    if(isempty(positiveLoads))
        break;
    end
    minLoad=min(positiveLoads);
    minLoad=minLoad(1);
    minLoadIdx=find(loads==minLoad);
    minLoadIdx=minLoadIdx(1);
    loadsRemoved(i)=loads(minLoadIdx);
    currentBus(minLoadIdx,PD)=0;
    params.mpcase.bus=currentBus;
    [Pg,objective,onoff,y,demandVector,success,windSpilled] = generalSCUC('not-n1',params,state,dynamicUCParams);
    i=i+1;
end
loadLost=sum(loadsRemoved);
objective=objective+sum(loadsRemoved*params.VOLL);