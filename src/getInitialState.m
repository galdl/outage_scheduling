function state=getInitialState(params)
%% Contingency data structure
state.topology.lineStatus=ones(params.nl,1); %saves the status of each branch
state.topology.lastChange=zeros(params.nl,1); %last time stamp where the asset had been fixed (reset)


if(strcmp(params.caseName,'case24'))
    %round(rand(params.nl,1)*400):
    r = [0.402654502277098;0.278962062420694;0.273829074207491;0.408064436276809;0.349651922094173;0.330304238485074;0.672857794971214;...
        0.235006534361005;0.364146728815232;0.147438420808545;0.204142977400638;0.579836973502882;0.833876975826700;0.147078561241710;...
        0.111538977798415;0.552737956536940;0.877611568283073;0.496569795875847;0.457965261185948;0.209590369467739;0.736143122381643;...
        0.981299025912346;0.634230425589563;0.373293826836583;0.439657414793771;0.169809755337493;0.809974850263107;0.0519041371761544;...
        0.526819743125415;0.863819346049464;0.888595191325048;0.327443199638568;0.0762543302419136;0.0741315460894034;0.917607273475874;...
        0.533362144089113;0.780682730621733;0.217990576282291];
    state.topology.lastChange = -24*365 -r*0.5*24*365;
end

% state.topology.lastChange(1)=-700;
% state.topology.lastChange(2)=-150;
state.topology.lastChange(6)=-2500;
if(strcmp(params.caseName,'case5'))
%     state.topology.lastChange=[-700;-150;-200;-50;-350;-2500];
    state.topology.lastChange(1:6)=[-700;-150;-10000;-50;-350;-10000];
end

state.topology.fixDuration=params.fixDuration*ones(params.nl,1); %duration of time it takes to fix each asset
%% current time. Note that it is overrided by the monthlyStateUpdate func
% state.currTime=params.fixDuration+1; %first hour of the second day. If we use (fixDuration) or less, matintenance will take the assets down
state.currTime=1; %Currently - we want it to take the assets down!

%% initial generator state
state.initialGeneratorState=params.initialGeneratorState;
