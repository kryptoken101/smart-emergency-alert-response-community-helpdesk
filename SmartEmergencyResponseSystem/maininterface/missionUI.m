function mainFig = missionUI(backgroundImage,...
                             nodeTable,...
                             requestManager,...
                             groundVehicleManager,...
                             quadcopterManager,...
                             kukaManager,...
                             biobotManager,...
                             atlasManager,...
                             fixedWingManager,...
                             deploymentManager,...
                             graph,...
                             stationOptimizer,...
                             quadcopterOptimizer,...
                             theaterXlim,...
                             theaterYlim)

mainFig = figure(...
'Alphamap',[0 0.0159 0.0317 0.0476 0.0635 0.0794 0.0952 0.1111 0.127 0.1429 0.1587 0.1746 0.1905 0.2063 0.2222 0.2381 0.254 0.2698 0.2857 0.3016 0.3175 0.3333 0.3492 0.3651 0.381 0.3968 0.4127 0.4286 0.4444 0.4603 0.4762 0.4921 0.5079 0.5238 0.5397 0.5556 0.5714 0.5873 0.6032 0.619 0.6349 0.6508 0.6667 0.6825 0.6984 0.7143 0.7302 0.746 0.7619 0.7778 0.7937 0.8095 0.8254 0.8413 0.8571 0.873 0.8889 0.9048 0.9206 0.9365 0.9524 0.9683 0.9841 1],...
'Color',[0.941176470588235 0.941176470588235 0.941176470588235],...
'Colormap',[0 0 0.5625;0 0 0.625;0 0 0.6875;0 0 0.75;0 0 0.8125;0 0 0.875;0 0 0.9375;0 0 1;0 0.0625 1;0 0.125 1;0 0.1875 1;0 0.25 1;0 0.3125 1;0 0.375 1;0 0.4375 1;0 0.5 1;0 0.5625 1;0 0.625 1;0 0.6875 1;0 0.75 1;0 0.8125 1;0 0.875 1;0 0.9375 1;0 1 1;0.0625 1 1;0.125 1 0.9375;0.1875 1 0.875;0.25 1 0.8125;0.3125 1 0.75;0.375 1 0.6875;0.4375 1 0.625;0.5 1 0.5625;0.5625 1 0.5;0.625 1 0.4375;0.6875 1 0.375;0.75 1 0.3125;0.8125 1 0.25;0.875 1 0.1875;0.9375 1 0.125;1 1 0.0625;1 1 0;1 0.9375 0;1 0.875 0;1 0.8125 0;1 0.75 0;1 0.6875 0;1 0.625 0;1 0.5625 0;1 0.5 0;1 0.4375 0;1 0.375 0;1 0.3125 0;1 0.25 0;1 0.1875 0;1 0.125 0;1 0.0625 0;1 0 0;0.9375 0 0;0.875 0 0;0.8125 0 0;0.75 0 0;0.6875 0 0;0.625 0 0;0.5625 0 0],...
'IntegerHandle','off',...
'InvertHardcopy',get(0,'defaultfigureInvertHardcopy'),...
'KeyPressFcn',[],...
'MenuBar','none',...
'Name','MissionUI',...
'NumberTitle','off',...
'PaperPosition',get(0,'defaultfigurePaperPosition'),...
'Position',[50 50 1750 1027],...
'HitTest','off',...
'UserData',[],...
'Visible','on',...
'CreateFcn', [],...
'CloseRequestFcn',@cleanup);

%============================= Map ==================================
mainMapPanel = uipanel(...
'Parent',mainFig,...
'Title',blanks(0),...
'Clipping','on',...
'Position',[0.103428571428571 0.0316091954022988 0.894285714285714 0.901340996168582]);

mainMap = axes(...
'Parent',mainMapPanel,...
'Position',[0 0 1 1],...
'LooseInset',[0.108274411204147 0.096423165532088 0.0791236081876461 0.0657430674082418],...
'XTick',[],...
'YTick',[],...
'XLim',theaterXlim,...
'YLim',theaterYlim,...
'XLimMode','manual',...
'YLimMode','manual',...
'SortMethod','ChildOrder');

mapImage = image('CData',backgroundImage,...
                 'parent',mainMap,...
                 'hittest','off',...
                 'ydata',linspace(theaterYlim(2),theaterYlim(1),size(backgroundImage,1)),...
                 'xdata',linspace(theaterXlim(1),theaterXlim(2),size(backgroundImage,2)));

%================================ Overlays ===============================
defaultArcOverlayVisibilityValue = true; % JZA: modifies to true 
defaultQuadcopterRouteVisibilityValue = true;
arcOverlay = TransitGraphArcOverlay(mainMap,...
                                    nodeTable,...
                                    graph,...
                                    groundVehicleManager,...
                                    defaultArcOverlayVisibilityValue);
nodeOverlay = TransitGraphNodeOverlay(mainMap,...
                                      nodeTable,...
                                      deploymentManager);
quadcopterRouteOverlay = QuadCopterRouteOverlay(mainMap,...
                                                quadcopterManager,...
                                                defaultQuadcopterRouteVisibilityValue);
                                   

%============================= Graph Manipulation ========================
graphEditToolbar = uipanel(...
'Parent',mainFig,...
'Title',blanks(0),...
'Clipping','on',...
'Position',[0.103428571428571 0.933908045977011 0.346857142857143 0.0651340996168588]);

addDeploymentsToggle = uicontrol(...
'Parent',graphEditToolbar,...
'Units','normalized',...
'BackgroundColor',[0.94 0.94 0.94],...
'Callback',@addDeploymentsToggleCallback,...
'CData',imread('deployTruck.png'),...
'Position',[0.467874794069193 0.088235294117644 0.0922570016474464 0.823529411764706],...
'String',' ',...
'Style','togglebutton',...
'TooltipString','Choose Possible Deployment Nodes');

%============================= Google Earth Interface ====================

openGoogleEarth = uicontrol(...
'Parent',mainFig,...
'Units','normalized',...
'BackgroundColor',[0.94 0.94 0.94],...
'Callback',@openGoogleEarthCallback,...
'CData',imread('googleEarth.png'),...
'Position',[0.450857142857143 0.933787731256086 0.0394285714285714 0.0652385589094453],...
'String',blanks(0),...
'TooltipString','Connect to Google Earth',...
'Style','togglebutton');

%============================= Overlay control ===========================
displaySelectionToolbar = uipanel(...
'Parent',mainFig,...
'ShadowColor',[0.7 0.7 0.7],...
'Title',blanks(0),...
'Clipping','on',...
'BackgroundColor',[0.94 0.94 0.94],...
'Position',[0.725142857142857 0.933908045977011 0.274857142857143 0.0651340996168587]);

displayNodesCheck = uicontrol(...
'Parent',displaySelectionToolbar,...
'Units','normalized',...
'Callback',[],...
'FontSize',9,...
'Position',[0.0210526315789474 0.5 0.186842105263158 0.338235294117648],...
'String','Nodes',...
'Style','checkbox',...
'Value',0);
% Because setting the value doesn't fire the callback
addlistener(displayNodesCheck,'Value','PostSet',@(~,~)displayNodesCheckCallback(displayNodesCheck,[]));

displayArcsCheck = uicontrol(...
'Parent',displaySelectionToolbar,...
'Units','normalized',...
'Callback',@displayArcsCheckCallback,...
'FontSize',9,...
'Position',[0.0236842105263158 0.0882352941176471 0.184210526315789 0.338235294117648],...
'String','Arcs',...
'Style','checkbox',...
'Value',0);

displayDeploymentsCheck = uicontrol(...
'Parent',displaySelectionToolbar,...
'Units','normalized',...
'Callback',@displayDeploymentsCheckCallback,...
'Position',[0.451106459330144 0.499999999999997 0.263494318181818 0.338235294117648],...
'String','Deployments',...
'Style','checkbox',...
'Value',0);
% Because setting the value doesn't fire the callback
addlistener(displayDeploymentsCheck,'Value','PostSet',@(~,~)displayDeploymentsCheckCallback(displayDeploymentsCheck,[]));

displayGVRoutesCheck = uicontrol(...
'Parent',displaySelectionToolbar,...
'Units','normalized',...
'Callback',@displayGVRoutesCheckCallback,...
'Position',[0.726315789473684 0.485294117647059 0.242105263157895 0.338235294117648],...
'String','GV Routes',...
'Style','checkbox',...
'Value',defaultArcOverlayVisibilityValue);

displayRCRoutesCheck = uicontrol(...
'Parent',displaySelectionToolbar,...
'Units','normalized',...
'Callback',@displayRCRoutesCheckCallback,...
'Position',[0.726315789473684 0.0882352941176471 0.242105263157895 0.338235294117648],...
'String','RC Routes',...
'Style','checkbox',...
'Value',defaultQuadcopterRouteVisibilityValue);

%====================== Listings ================================
listingsPanel = uipanel(...
'Parent',mainFig,...
'ShadowColor',[0.7 0.7 0.7],...
'Clipping','on',...
'BackgroundColor',[0.686274509803922 0.752941176470588 0.929411764705882],...
'Position',[-0.000571428571428571 0.0383141762452107 0.104 0.89367816091954]);

%=================== Operations ===========================
operationsHeader = uicontrol(...
'Parent',listingsPanel,...
'Units','normalized',...
'BackgroundColor',[0.372549019607843 0.509803921568627 0.862745098039216],...
'FontName','Times New Roman',...
'FontSize',12,...
'Position',[-0.00662251655629139 0.972101887559751 1 0.0278670953912111],...
'String','Operations',...
'Style','text' );

% reconnaissanceButton = uicontrol(...
% 'Parent',listingsPanel,...
% 'Units','normalized',...
% 'Callback',[],...
% 'Position',[0.0384615384615385 0.930332261521972 0.752747252747253 0.030010718113612],...
% 'String','Reconnaissance',...
% 'TooltipString','Set Waypoints for Fixed Wing Aircrafts',...
% 'Style','pushbutton' );
% 
deployButton = uicontrol(...
'Parent',listingsPanel,...
'Units','normalized',...
'Callback',@(~,~)stationOptimizer.planRoutes(graph,deploymentManager,groundVehicleManager.getVehicles),...
'Position',[0.0384615384615385 0.892818863879957 0.752747252747253 0.030010718113612],...
'String','Deploy Stations',...
'TooltipString','Solve Optimization to Deploy Ground Vehicles',...
'Style','pushbutton' );

deliveryButton = uicontrol(...
'Parent',listingsPanel,...
'Units','normalized',...
'Callback',@(~,~)quadcopterOptimizer.optimize(5),...
'Position',[0.0384615384615385 0.857449088960343 0.752747252747253 0.030010718113612],...
'String','Deliver Supplies',...
'TooltipString','Solve Optimization for Quadcopter Delivery',...
'Style','pushbutton' );
% 
% reconnaissanceExportButton = uicontrol(...
% 'Parent',listingsPanel,...
% 'Units','normalized',...
% 'Callback',[],...
% 'Position',[0.796703296703297 0.930332261521972 0.17032967032967 0.030010718113612],...
% 'String','>>',...
% 'TooltipString','Send the Fixed Wing Aircraft Waypoints to Simulink',...
% 'Style','pushbutton' );
% 
% deployExportButton = uicontrol(...
% 'Parent',listingsPanel,...
% 'Units','normalized',...
% 'Callback',[],...
% 'Position',[0.796703296703297 0.892818863879957 0.17032967032967 0.030010718113612],...
% 'String','>>',...
% 'TooltipString','Send the Ground Vehicle Waypoints to Simulink',...
% 'Style','pushbutton');
% 
% deliveryExportButton = uicontrol(...
% 'Parent',listingsPanel,...
% 'Units','normalized',...
% 'Callback',[],...
% 'Position',[0.796703296703297 0.857449088960343 0.17032967032967 0.030010718113612],...
% 'String','>>',...
% 'TooltipString','Send the Quadcopter Waypoints to Simulink',...
% 'Style','pushbutton' );
% 
%=================== Fleet ===========================
fleetHeader = uicontrol(...
'Parent',listingsPanel,...
'Units','normalized',...
'BackgroundColor',[0.372549019607843 0.509803921568627 0.862745098039216],...
'FontName','Times New Roman',...
'FontSize',12,...
'Position',[-0.00662251655629139 0.819741547566942 1 0.0278670953912111],...
'String','Fleet',...
'Style','text' );

vehicleSelector = VehicleTypeSelector({groundVehicleManager,quadcopterManager,kukaManager,biobotManager,atlasManager},...
                                      listingsPanel,...
                                      [0.0384615384615385 0.7502679528403 0.92 0.030010718113612]);

fleetList = uicontrol(...
'Parent',listingsPanel,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'Callback',[],...
'Position',[0.0384615384615385 0.662379421221865 0.92 0.0889603429796356],...
'Style','listbox',...
'Max',0,...     % Disable multi-select
'Min',0,...
'String',{},...
'Value',1);

addVehicleToggle = uicontrol(...
'Parent',listingsPanel,...
'Units','normalized',...
'Callback',@addVehicleToggleCallback,...
'Position',[0.0384615384615385 0.782422293676313 0.92 0.030010718113612],...
'String','Add Vehicle',...
'Style','togglebutton',...
'TooltipString','Add Vehicle to the Fleet');

% %=================== Items ===========================
% itemListHeader = uicontrol(...
% 'Parent',listingsPanel,...
% 'Units','normalized',...
% 'BackgroundColor',[0.372549019607843 0.509803921568627 0.862745098039216],...
% 'FontName','Times New Roman',...
% 'FontSize',12,...
% 'Position',[-0.00662251655629139 0.62768168236474 1 0.0278670953912111],...
% 'String','Item List',...
% 'Style','text');
% 
% itemTypeSelector = uicontrol(...
% 'Parent',listingsPanel,...
% 'Units','normalized',...
% 'BackgroundColor',[1 1 1],...
% 'Callback',[],...
% 'Position',[0.0384615384615385 0.561629153269025 0.604395604395604 0.030010718113612],...
% 'String','List',...
% 'Style','popupmenu',...
% 'Value',1);
% 
% itemCountSelector = uicontrol(...
% 'Parent',listingsPanel,...
% 'Units','normalized',...
% 'BackgroundColor',[1 1 1],...
% 'Callback',[],...
% 'Position',[0.675824175824176 0.561629153269025 0.274725274725275 0.030010718113612],...
% 'String',['1';'2';'3';'4';'5';'6';'7';'8';'9'],...
% 'Style','popupmenu',...
% 'Value',1);
% 
% itemList = uicontrol(...
% 'Parent',listingsPanel,...
% 'Units','normalized',...
% 'BackgroundColor',[1 1 1],...
% 'Callback',@(hObject,eventdata)MissionUI_export('itemSlider_Callback',hObject,eventdata,guidata(hObject)),...
% 'Position',[0.0384615384615385 0.465166130760986 0.92 0.0975348338692391],...
% 'String','First-Aid',...
% 'Style','listbox',...
% 'Value',1);
% 
resetButton = uicontrol(...
'Parent',listingsPanel,...
'Units','normalized',...
'Callback',@(~,~)cellfun(@feval,{@requestManager.reset,@groundVehicleManager.reset,@quadcopterManager.reset,@biobotManager.reset,@kukaManager.reset,@atlasManager.reset,@deploymentManager.reset}),...
'Position',[0.0384615384615385 0.593783494105037 0.92 0.030010718113612],...
'String','Reset',...
'TooltipString','Enter a New Item',...
'Style','pushbutton');

%=================== Requests ===========================
currentRequestsHeader = uicontrol(...
'Parent',listingsPanel,...
'Units','normalized',...
'BackgroundColor',[0.372549019607843 0.509803921568627 0.862745098039216],...
'FontName','Times New Roman',...
'FontSize',12,...
'Position',[-0.00662251655629139 0.429188651436147 1 0.0278670953912111],...
'String','Current Requests',...
'Style','text');

itemTypeSelector = uicontrol(...
'Parent',listingsPanel,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'Callback',[],...
'Position',[0.0384615384615385 0.357984994640943 0.576923076923077 0.030010718113612],...
'String',ItemFactory.getCatalog,...
'Style','popupmenu',...
'Value',1);

itemDeliveryPickupSelector =  uicontrol(...
'Parent',listingsPanel,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'Callback',[],...
'Position',[0.647733061640347 0.358385918719249 0.298013245033112 0.03],...
'String',{'D','P'},...
'Style','popupmenu',...
'TooltipString','Delivery or Pick Up Request',...
'Value',1);

requestList = uicontrol(...
'Parent',listingsPanel,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'Callback',[],...
'Position',[0.0384615384615385 0.22508038585209 0.92 0.129689174705252],...
'String',{},...
'Style','listbox',...
'Value',1);

addRequestToggle = uicontrol(...
'Parent',listingsPanel,...
'Units','normalized',...
'Callback',@addRequestToggleCallback,...
'Position',[0.0384615384615385 0.393354769560557 0.92 0.030010718113612],...
'String','Enter Request',...
'Style','togglebutton',...
'TooltipString','Enter a Request Manually');

% %=================== Simulation ===========================

simPanel = uicontrol(...
'Parent',listingsPanel,...
'Units','normalized',...
'BackgroundColor',[0.372549019607843 0.509803921568627 0.862745098039216],...
'FontName','Times New Roman',...
'FontSize',12,...
'Position',[0.00549450549450549 0.190782422293676 1 0.0278670953912112],...
'String','Simulation',...
'Style','text');

simButtonGroup = uibuttongroup(...
'Parent',listingsPanel,...
'ShadowColor',[0.7 0.7 0.7],...
'UserData',[],...
'Clipping','on',...
'BackgroundColor',[0.94 0.94 0.94],...
'Position',[0.0384615384615385 0.121114683815648 0.92 0.0621650589496249],...
'SelectedObject',[],...
'Visible','off',...
'SelectionChangeFcn',@simTypeCallback,...
'OldSelectedObject',[]);

simSelectSL = uicontrol(...
'Parent',simButtonGroup,...
'Units','normalized',...
'Callback',[],...
'CData',[],...
'Position',[0.1 0.1 0.8 0.5],...
'String','Simulink Dynamics',...
'Style','radiobutton',...
'Tag','Simulink',...
'TooltipString','Simulate Vehicle Dynamics in Simulink',...
'UserData',[]);

simSelectML = uicontrol(...
'Parent',simButtonGroup,...
'Units','normalized',...
'Callback',[],...
'CData',[],...
'Position',[0.1 0.5 0.8 0.5],...
'String','MATLAB Kinematics',...
'Style','radiobutton',...
'Tag','MATLAB',...
'Value',1,...
'TooltipString','Simulate Vehicle Kinematics in Matlab',...
'UserData',[]);

playToggle = uicontrol(...
'Parent',listingsPanel,...
'Units','normalized',...
'Callback',[],...
'Position',[0.0384615384615385 0.082529474812433 0.92 0.030010718113612],...
'String','Play',...
'Enable','on',...
'Style','togglebutton',...
'TooltipString','Run the Simulation',...
'Callback',@simPlayPauseCallback);

messageKUKAEdit = uicontrol(...
'Parent',listingsPanel,...
'Units','normalized',...
'Callback',[],...
'Position',[0.0384615384615385 0.0139335476956056 0.92 0.030010718113612],...
'String','',...
'Style','edit');

messageKUKAButton = uicontrol(...
'Parent',listingsPanel,...
'Units','normalized',...
'Callback',@(~,~)kukaManager.getVehicles.send([datestr(now) ': Message from command: ' get(messageKUKAEdit,'String')]),...
'Position',[0.0384615384615385 0.0482315112540193 0.92 0.030010718113612],...
'String','Notify Kuka');

%============================= Initial Vehicles ==========================
% JZA: showing the GV routes on the map by default 
% arcOverlay.showGroundVehicleRoutes; 

initialGroundVehicles = groundVehicleManager.getVehicles;
for ii = 1:numel(initialGroundVehicles)
    newGroundVehicleEventHandler(initialGroundVehicles(ii));
end
initialQuadcopters = quadcopterManager.getVehicles;
for ii = 1:numel(initialQuadcopters)
    newQuadcopterEventHandler(initialQuadcopters(ii));
end
initialKukas = kukaManager.getVehicles;
for ii = 1:numel(initialKukas)
    newKukaEventHandler(initialKukas(ii));
end
initialBiobots = biobotManager.getVehicles;
for ii = 1:numel(initialBiobots)
    newBiobotEventHandler(initialBiobots(ii));
end
initialAtlas = atlasManager.getVehicles;
for ii = 1:numel(initialAtlas)
    newAtlasEventHandler(initialAtlas(ii));
end
initialRequests = requestManager.getRequests;
for ii = 1:numel(initialRequests)
    newRequestEventHandler(initialRequests(ii));
end

%==========================================================================
%                              LISTENERS
%==========================================================================
gvlis = addlistener(groundVehicleManager,'vehicleAdded',@(~,event)newGroundVehicleEventHandler(event.ID));
qclis = addlistener(quadcopterManager,'vehicleAdded',@(~,event)newQuadcopterEventHandler(event.ID));
kulis = addlistener(kukaManager,'vehicleAdded',@(~,event)newKukaEventHandler(event.ID));
bblis = addlistener(biobotManager,'vehicleAdded',@(~,event)newBiobotEventHandler(event.ID));
atlis = addlistener(atlasManager,'vehicleAdded',@(~,event)newAtlasEventHandler(event.ID));
rqlis = addlistener(requestManager,'requestAdded',@(~,event)newRequestEventHandler(event.ID));

% End of Function, missionUI.  Everything below this is nested function
% definitions.
%==========================================================================
%                             CALLBACKS
%==========================================================================

    function cleanup(src,~)
        delete(gvlis);
        delete(qclis);
        delete(kulis);
        delete(bblis);
        delete(atlis);
        delete(rqlis);
        if isvalid(src)
            delete(src);
        end
    end

    function addDeploymentsToggleCallback(src,~)
        switch get(src,'Value')
            case get(src,'Max')
                set(displayNodesCheck,'Value',get(displayNodesCheck,'Max'));
                set(displayDeploymentsCheck,'Value',get(displayDeploymentsCheck,'Max'));
                nodeOverlay.enableDeploymentSelection;
            case get(src,'Min')
                set(displayNodesCheck,'Value',get(displayNodesCheck,'Min'));
                nodeOverlay.disableDeploymentSelection;
        end
    end

    function displayNodesCheckCallback(src,~)
        switch get(src,'Value')
            case get(src,'Max')
                nodeOverlay.showNodes;
            case get(src,'Min')
                nodeOverlay.unshowNodes;
        end        
    end

    function displayDeploymentsCheckCallback(src,~)
        switch get(src,'Value')
            case get(src,'Max')
                nodeOverlay.showDeployments;
            case get(src,'Min')
                nodeOverlay.unshowDeployments;
        end        
    end

    function displayArcsCheckCallback(src,~)
        switch get(src,'Value')
            case get(src,'Max')
                arcOverlay.showArcs;
            case get(src,'Min')
                arcOverlay.unshowArcs;
        end        
    end

    function displayGVRoutesCheckCallback(src,~)
        switch get(src,'Value')
            case get(src,'Max')
                arcOverlay.showGroundVehicleRoutes;
            case get(src,'Min')
                arcOverlay.unshowGroundVehicleRoutes;
        end        
    end

    function displayRCRoutesCheckCallback(src,~)
        switch get(src,'Value')
            case get(src,'Max')
                quadcopterRouteOverlay.showRoutes;
            case get(src,'Min')
                quadcopterRouteOverlay.unshowRoutes;
        end
    end

    function addVehicleToggleCallback(src,~)
        switch get(src,'Value')
            case get(src,'Max')
                % Turn off request entering
                set(addRequestToggle,'Value',get(addRequestToggle,'Min'));
                set(mainMap,'ButtonDownFcn',@addVehicleAtMouseClick);
            case get(src,'Min')
                set(mainMap,'ButtonDownFcn',[]);
        end         
    end

    function addRequestToggleCallback(src,~)
        switch get(src,'Value')
            case get(src,'Max')
                % Turn off vehicle entering
                set(addVehicleToggle,'Value',get(addVehicleToggle,'Min'));
                set(mainMap,'ButtonDownFcn',@addRequestAtMouseClick);
            case get(src,'Min')
                set(mainMap,'ButtonDownFcn',[]);
        end
    end

    function openGoogleEarthCallback(src,~)
        
        switch get(src,'Value')
            case get(src,'Max')                
                GeCommunicator(groundVehicleManager,...
                                 quadcopterManager,...
                                 biobotManager,...
                                 atlasManager,...
                                 kukaManager);
                
            case get(src,'Min')
                try
                    evalin('base','delete(GE)');
                catch
                end
        end
    end

    function simTypeCallback(~,eventdata)
       % Force MATLAB Kinematics
       switch get(eventdata.NewValue,'Tag')
           case 'Simulink'
               % If SL dynamics is chosen force MATLAB Kinematics
               %fprintf('Simulink Dynamics is not baked,\nSwitching to MATLAB Kinematics\n')
               fprintf('Simulink Dynamics is chosen\n');
               %set(simSelectML,'Value',1)
       end
    end

    function simPlayPauseCallback(src,~)
    
        %Kinematics
                 simMission1 = Simulator(groundVehicleManager,...
                             quadcopterManager,...
                             requestManager,...
                             biobotManager,...
                             kukaManager,...
                             atlasManager,...  
                             fixedWingManager,...
                             0.99 ); %0.01 % JZA: Higher value for speeding up the debugging. 
                                        
                             DSim(groundVehicleManager,...
                                  quadcopterManager);
        
        %Kinematics                            
        switch get(src,'Value')
            case get(src,'Min')
                set(src,'String','Play')
                 simMission1.stop;               
            case get(src,'Max')
                set(src,'String','Pause')
                 simMission1.start;
                %simMission2.start;
                
       end     
    end

%==========================================================================
%                         HELPER FUNCTIONS
%==========================================================================
    function addVehicleAtMouseClick(src,~)
        currentPoint = get(src,'currentPoint');
        % Remember that x/y corresponds to lon/lat, not lat/lon.
        vehicleSelector.selectedVehicleManager.addVehicle(currentPoint([3,1]));
    end

    function addRequestAtMouseClick(src,~)
        currentPoint = get(src,'currentPoint');
        itemList = get(itemTypeSelector,'String');
        itemDeliveryPickupList = get(itemDeliveryPickupSelector,'String');
        % Remember that x/y corresponds to lon/lat, not lat/lon.
        requestManager.addRequest(currentPoint([3,1]),...
                                  ItemFactory.makeItem(itemList(get(itemTypeSelector,'Value'))),...
                                  'Operator',...
                                  10,...
                                  now,...
                                  now,...
                                  1,...
                                  strcmp(itemDeliveryPickupList(get(itemDeliveryPickupSelector,'Value')),'D'),...
                                  strcmp(itemDeliveryPickupList(get(itemDeliveryPickupSelector,'Value')),'P'));                                
    end

    function newGroundVehicleEventHandler(newGroundVehicle)
        DeploymentTruckSprite(mainMap,newGroundVehicle);
        set(fleetList,'string',[get(fleetList,'string');groundVehicleManager.vehicleTypeName]);
    end

    function newQuadcopterEventHandler(newQuadcopter)
        QuadCopterSprite(mainMap,newQuadcopter);
        set(fleetList,'string',[get(fleetList,'string');quadcopterManager.vehicleTypeName]);
    end

    function newBiobotEventHandler(newBiobot)
        BiobotSprite(mainMap,newBiobot);
        set(fleetList,'string',[get(fleetList,'string');biobotManager.vehicleTypeName]);
    end

    function newKukaEventHandler(newKuka)
        KukaSprite(mainMap,newKuka);
        set(fleetList,'string',[get(fleetList,'string');kukaManager.vehicleTypeName]);
    end

    function newAtlasEventHandler(newAtlas)
        AtlasSprite(mainMap,newAtlas);
        set(fleetList,'string',[get(fleetList,'string');atlasManager.vehicleTypeName]);
    end

    function newRequestEventHandler(newRequest)
        RequestMarker(mainMap,newRequest);
        set(requestList,'string',[get(requestList,'string');newRequest.item.name]);
    end
end

