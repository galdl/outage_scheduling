function newInitialState = getInitialGeneratorState_oneStep( onoff,initialState,params )
ng=size(onoff,1);
newInitialState=initialState;
for g=1:ng
    if(onoff(g)==1 && initialState(g)>0)
        newInitialState(g)=newInitialState(g)+1;
    elseif(onoff(g)==1 && initialState(g)<0)
        newInitialState(g)=1;
    elseif(onoff(g)==0 && initialState(g)>0)
        newInitialState(g)=-1;
    else newInitialState(g)=newInitialState(g)-1;
    end
end
newInitialState=max(-params.horizon,newInitialState);
newInitialState=min(params.horizon,newInitialState);
