classdef QuadrotorOptimizationDispatchAdaptor < handle
    %QUADROTOROPTIMIZATIONDISPATCHADAPTOR 
    
    properties (Access = private)
        outbox      % Connection to send data to the optimizer
        inbox       % Connection to receive data from the optimizer
        
        requestManager
        quadcopterManager
        groundVehicleManager
        
        requestIndexTranslationTable  % List of requests actually sent to the optimizer (for consistency of indexing)
        
        routeTimer  % Timer to ensure that routes do not get set prematurely
    end
    
    properties (SetAccess = private)
        optimalRoutes
        loadouts
        waypointTargets
    end
    
    methods
        function obj = QuadrotorOptimizationDispatchAdaptor(ipAddress, inport, outport,...
                                                            requestManagerIn,...
                                                            quadcopterManagerIn,...
                                                            groundVehicleManagerIn)
            obj.requestManager = requestManagerIn;
            obj.quadcopterManager = quadcopterManagerIn;
            obj.groundVehicleManager = groundVehicleManagerIn;
            
            obj.outbox = EventDispatcher(ipAddress, outport);
            obj.inbox = EventListener('',inport,@obj.processRoute);
            
            obj.routeTimer = timer('Name','OptimizationTimer',...
                                   'TimerFcn',@(~,~)disp('Optimization Incomplete'));
        end
        
        function optimize(obj, delay)
            if strcmp(obj.routeTimer.Running,'off')
                predictedState = obj.generateWorldState;
                predictedState = obj.forwardPredict(predictedState,delay-.2);  % Usually, the simulation can't quite keep up
                obj.sendData(predictedState);
                obj.triggerOptimization(delay);
                set(obj.routeTimer,'StartDelay',delay);
                start(obj.routeTimer);
            end
        end
        
        function delete(obj)
            delete(obj.outbox);
            delete(obj.inbox);
        end
    end
    
    methods (Access = private)
        function sendData(obj, worldState)
            iter = 1;
            for quadcopter = worldState.quadcopters
                obj.outbox.dispatch(QuadrotorOptimizationDispatchAdaptor.quadcopterString(quadcopter,iter));
                iter = iter + 1;
            end
            % Assume ground vehicles are fixed
            iter = 1;
            for groundVehicle = worldState.groundVehicles
                obj.outbox.dispatch(QuadrotorOptimizationDispatchAdaptor.groundVehicleString(groundVehicle,iter));
                iter = iter + 1;
            end
            obj.requestIndexTranslationTable = [];
            requestList = obj.requestManager.getRequests;
            for request = worldState.requests
                if strcmp(request.item.carrier,'Quadcopter')
                    obj.outbox.dispatch(QuadrotorOptimizationDispatchAdaptor.requestString(request,request.ID));
                    obj.requestIndexTranslationTable = [obj.requestIndexTranslationTable, requestList([requestList.ID] == request.ID)];  % Need to convert the struct in world state to a bona fide request
                end
            end
            set(obj.routeTimer,'TimerFcn',@(~,~)disp('Optimization Incomplete'));
        end
        
        function triggerOptimization(obj, delay)
            % The forward prediction predicts that things will be slightly
            % further along than they really will be (due to half legs
            % disappearing at waypoints).  This should roughly negate the
            % delays in transmission and optimization problem setup.  If
            % that assumption is false, subtract some small amount from 
            % 'delay' here to compensate.
            obj.outbox.dispatch(['GO,',num2str(delay-.3)]);
        end
        
        function retval = forwardPredict(~,state,delay)
            retval = state;
            for idx = 1:numel(state.quadcopters)
                dist = delay*QuadCopter.speed;
                location = [state.quadcopters(idx).latitude, state.quadcopters(idx).longitude];
                waypointIdx = 2;    % 1 is the last place it visited

                if size(state.quadcopters(idx).route,1) < 2
                    continue;
                end

                step = norm(location-state.quadcopters(idx).route(waypointIdx,:));
                while waypointIdx<=size(state.quadcopters(idx).route,1) && step<=dist
                    currentTarget = state.quadcopters(idx).waypoints(waypointIdx);
                    if currentTarget == 0       % Ground Vehicle
                        retval.quadcopters(idx).battery = 1;
                    else                        % Request
                        retval.quadcopters(idx).battery = retval.quadcopters(idx).battery - step/QuadCopter.maxRange;
                        % Remove the request
                        retval.requests([retval.requests.ID]==currentTarget) = [];
                    end
                    if waypointIdx>numel(state.quadcopters(idx).loadouts)
                        retval.quadcopters(idx).cargo = ItemFactory.makeItem('empty');
                    else
                        retval.quadcopters(idx).cargo = state.quadcopters(idx).loadouts{waypointIdx};
                    end
                    
                    dist = dist - step;
                    retval.quadcopters(idx).latitude = state.quadcopters(idx).route(waypointIdx,1);
                    retval.quadcopters(idx).longitude = state.quadcopters(idx).route(waypointIdx,2);
                    waypointIdx = waypointIdx + 1;
                    if waypointIdx<=size(state.quadcopters(idx).route,1)
                        step = norm(location-state.quadcopters(idx).route(waypointIdx,:));
                    else
                        break;
                    end
                end
                if waypointIdx > size(state.quadcopters(idx).route,1)
                    retval.quadcopters(idx).latitude = state.quadcopters(idx).route(end,1);
                    retval.quadcopters(idx).longitude = state.quadcopters(idx).route(end,2);
                    continue;
                end
                if step > dist  % We finish the last fragment of a leg
                    direction = state.quadcopters(idx).route(waypointIdx,:)-state.quadcopters(idx).route(waypointIdx-1,:);
                    endpoint = state.quadcopters(idx).route(waypointIdx-1,:)+dist*direction/norm(direction);
                    retval.quadcopters(idx).latitude = endpoint(1);
                    retval.quadcopters(idx).longitude = endpoint(2);
                    retval.quadcopters(idx).battery = retval.quadcopters(idx).battery - dist/QuadCopter.maxRange;
                end
            end
        end
        
        function retval = generateWorldState(obj)
            retval = WorldState;
            for quadcopter = obj.quadcopterManager.getVehicles
                waypointList = [];
                for waypoint = quadcopter.waypointTargets
                    mc = metaclass(waypoint{1});
                    if isequal(mc.Name,'Request') && isvalid(waypoint{1})
                        newWaypoint = waypoint{1}.ID;
                    else
                        newWaypoint = 0;
                    end
                    waypointList = [waypointList newWaypoint];
                end
                newQuadcopter = struct('latitude',{quadcopter.location(1)},...
                                       'longitude',{quadcopter.location(2)},...
                                       'battery',{quadcopter.charge},...
                                       'cargo',{quadcopter.cargo},...
                                       'route',{quadcopter.getRoute},...
                                       'waypoints',{waypointList},...
                                       'loadouts',{quadcopter.loadouts});
                retval.quadcopters = [retval.quadcopters newQuadcopter];
            end
            for groundVehicle = obj.groundVehicleManager.getVehicles
                newVehicle = struct('latitude',groundVehicle.location(1),...
                                    'longitude',groundVehicle.location(2));
                retval.groundVehicles = [retval.groundVehicles newVehicle];
            end
            for request = obj.requestManager.getRequests
                newRequest = struct('latitude',request.location(1),...
                                    'longitude',request.location(2),...
                                    'item',request.item,...
                                    'quantity',request.quantity,...
                                    'isDelivery',request.isDelivery,...
                                    'ID',request.ID);
                retval.requests = [retval.requests newRequest];
            end
        end
        
        function processRoute(obj,msg)
            fields = strsplit(msg,',');
            switch fields{1}
                case 'DONE'
                    set(obj.routeTimer,'TimerFcn',@obj.finalizeRouteData);
                case 'FAILED'
                    disp(fields{2});
                otherwise
                    quadcopterID = str2double(fields{1});
                    obj.optimalRoutes{quadcopterID} = [];
                    obj.loadouts{quadcopterID} = {};
                    idx = 0;
                    for data = fields(2:end)
                        if isempty(data{:})
                            break;
                        else
                            numData = str2double(data{:});
                        end
                        if isnan(numData)
                            obj.loadouts{quadcopterID}{idx} = [obj.loadouts{quadcopterID}{idx} ItemFactory.makeItem(data{1})];
                            if calculateWeight(obj.loadouts{quadcopterID}{idx})>QuadCopter.capacity
                                warning(['Overweight loadout: ' num2str(QuadCopter.capacity-calculateWeight(obj.loadouts{quadcopterID}{idx}))]);
                                obj.loadouts{quadcopterID}{idx} = obj.loadouts{quadcopterID}{idx}(1:end-1);
                            end
                        else
                            obj.optimalRoutes{quadcopterID} = [obj.optimalRoutes{quadcopterID} numData];
                            obj.loadouts{quadcopterID} = [obj.loadouts{quadcopterID} {ItemFactory.makeItem('empty')}];
                            idx = idx + 1;
                        end
                    end
            end
        end
        
        function finalizeRouteData(obj,~,~)
            % Populate waypointTargets
            nodeWaypoints = [num2cell(obj.requestIndexTranslationTable),...
                             num2cell(obj.quadcopterManager.getVehicles),...
                             num2cell(obj.groundVehicleManager.getVehicles)];
            obj.waypointTargets = cellfun(@(idx)nodeWaypoints(idx),obj.optimalRoutes,'UniformOutput',false);
            % Convert optimal routes from node indices to lat/lon
            locations = cell2mat(vertcat({obj.requestIndexTranslationTable.location}',...
                             {obj.quadcopterManager.getVehicles.location}',...
                             {obj.groundVehicleManager.getVehicles.location}'));
            obj.optimalRoutes = cellfun(@(idx)locations(idx,:),obj.optimalRoutes,'UniformOutput',false);
            % loadouts should already be set

            if ~isempty(obj.optimalRoutes) && ...
               ~isempty(obj.waypointTargets) && ...
               ~isempty(obj.loadouts)
                quadcopters = obj.quadcopterManager.getVehicles;
                for quadcopter = 1:numel(quadcopters)
                    quadcopters(quadcopter).setRoute(obj.optimalRoutes{quadcopter});
                    quadcopters(quadcopter).waypointTargets = obj.waypointTargets{quadcopter};
                    quadcopters(quadcopter).loadouts = obj.loadouts{quadcopter};
                end
                obj.optimalRoutes = {};
                obj.waypointTargets = {};
                obj.loadouts = {};
            end
        end
    end
       
    methods (Static)
        function retval = quadcopterString(predictedState, ID)
            retval = ['QC,',sprintf('%d',ID),',',...
                      sprintf('%1.10f',predictedState.latitude),',',...
                      sprintf('%1.10f',predictedState.longitude),',',...
                      sprintf('%1.10f',predictedState.battery)];
            for item = predictedState.cargo
                retval = [retval ',' item.name];
            end
        end
        
        function retval = groundVehicleString(groundVehicle, ID)
            retval = ['GV,',sprintf('%d',ID),',',...
                      sprintf('%1.10f',groundVehicle.latitude),','...
                      sprintf('%1.10f',groundVehicle.longitude)];
        end
        
        function retval = requestString(request, ID)
            retval = ['RQ,',sprintf('%d',ID),',',...
                      sprintf('%1.10f',request.latitude),',',...
                      sprintf('%1.10f',request.longitude),',',...
                              request.item.name,',',...
                      sprintf('%d',request.quantity),',',...
                      sprintf('%d',request.isDelivery)];
        end
    end    
end

