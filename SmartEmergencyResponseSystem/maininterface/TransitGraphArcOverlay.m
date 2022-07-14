classdef TransitGraphArcOverlay < handle
    %% Visual representation of a GroundTransportationGraph for main UI
    
    properties (Access = private)
        nodeTable       % Instance of NodeTable
        carManager      % Instance of GroundVehicleManager
        graph           % Instance of GroundTransportationGraph
        
        parentAxes      % Axes object containing this object
        lines           % Vector of handles to lines for the background as well as each vehicle
        colorIndices    % Vector of integers counting the number of lines of each color
        backgroundLine  % Line containing all the edges
        
        routeUpdater    % Listener for route updates
        vehicleAddUpdater % Updates for new vehicles
        vehicleRemoveUpdater % Updates for vehicles getting removed
        
        ownedEdgesMask  % 3*numEdges(graph) x numel(lines) logical
        nodeXData       % xdata for the background edges
        nodeYData       % ydata for the background edges
        
        showingAllGVRoutes = false % boolean, needed in case cars are added after showRoutes is called
    end
    
    methods
        function obj = TransitGraphArcOverlay(parentAxesIn, ...
                                              nodeTableIn, ...
                                              graphIn, ...
                                              carManagerIn, ...
                                              showingAllRoutesIn)
            obj.parentAxes    = parentAxesIn;
            obj.nodeTable     = nodeTableIn;
            obj.carManager    = carManagerIn;
            obj.graph         = graphIn;
            obj.colorIndices  = zeros(size(get(obj.parentAxes,'colororder'),1),1);
            obj.showingAllGVRoutes = showingAllRoutesIn;
            obj.ownedEdgesMask = zeros(3*obj.graph.numArcs,0);
            
            for thisCar = obj.carManager.getVehicles
                obj.makeLine(thisCar.ID);
                obj.updateRoute(thisCar);
            end
            
            if ~isempty(obj.carManager.getVehicles)
                obj.routeUpdater = addlistener(obj.carManager.getVehicles,...
                                               'routeChanged',...
                                               @(src,~)obj.updateRoute(src));
            end
            obj.vehicleAddUpdater = addlistener(obj.carManager,...
                                                'vehicleAdded',...
                                                @obj.newCarHandler);
            obj.vehicleRemoveUpdater = addlistener(obj.carManager,...
                                                   'vehicleRemoved',...
                                                   @obj.deleteCarHandler);
                                               
            % X and Y appear to be backwards here since nodeLocations are
            % in the order lat/lon.
            obj.nodeXData = nan(obj.graph.numArcs*3,1);
            obj.nodeYData = nan(obj.graph.numArcs*3,1);
            edgeList = obj.graph.getEdgeList;
            for e = 1:size(edgeList,1)
                obj.nodeXData(3*e-2) = obj.nodeTable.nodeLocations(edgeList(e,1),2);
                obj.nodeYData(3*e-2) = obj.nodeTable.nodeLocations(edgeList(e,1),1);
                obj.nodeXData(3*e-1) = obj.nodeTable.nodeLocations(edgeList(e,2),2);
                obj.nodeYData(3*e-1) = obj.nodeTable.nodeLocations(edgeList(e,2),1);
            end
            
            obj.backgroundLine = line('xdata',[],'ydata',[],...
                                      'parent',obj.parentAxes,...
                                      'marker','none',...
                                      'linewidth',4,...
                                      'color','b',...
                                      'visible','off');
                                  
            obj.refreshBackground;
        end
        
        function delete(obj)
            delete(obj.routeUpdater);
            delete(obj.vehicleAddUpdater);
            delete(obj.vehicleRemoveUpdater);
        end
        
        function showGroundVehicleRoutes(obj)
            set(obj.lines,'visible','on');
            obj.showingAllGVRoutes = true;
            obj.refreshBackground;
        end
        
        function unshowGroundVehicleRoutes(obj)
            set(obj.lines,'visible','off');
            obj.showingAllGVRoutes = false;
            obj.refreshBackground;
        end
        
        function showArcs(obj)
            set(obj.backgroundLine,'visible','on');
        end
        
        function unshowArcs(obj)
            set(obj.backgroundLine,'visible','off');
        end
    end
       
    methods (Access = private)
        function newCarHandler(obj,~,event)
            % event.ID is the car that was created
            obj.makeLine(event.ID.ID);
            obj.updateRoute(event.ID);
            if obj.showingAllGVRoutes
                set(obj.lines(event.ID.ID),'visible','on');
            end
            addlistener(event.ID,'routeChanged',@(src,~)obj.updateRoute(src));
        end
        
        function deleteCarHandler(obj,~,event)
            obj.removeLine(event.ID);
            % When the car gets deleted, the listener automatically gets
            % cleaned up
        end
        
        function makeLine(obj, vehicleIndex)
            [~,index] = min(obj.colorIndices);  % Get the least-frequently used color
            colormap = get(obj.parentAxes,'colororder');
            obj.lines(vehicleIndex) = line('parent',obj.parentAxes,...
                                           'xdata',[],'ydata',[],...
                                           'color', colormap(index,:),...
                                           'linewidth',3,...
                                           'visible','off');
            obj.colorIndices(index) = obj.colorIndices(index) + 1;
        end
        
        function removeLine(obj, vehicleIndex)
            color = get(obj.lines(vehicleIndex),'color');
            colormap = get(obj.parentAxes,'colororder');
            for ii = 1:numel(obj.colorIndices)
                if isequal(color,colormap(ii,:))
                    obj.colorIndices(ii) = obj.colorIndices(ii) - 1;
                    break;
                end
            end
            
            obj.ownedEdgesMask(:,vehicleIndex) = false;
            delete(obj.lines(vehicleIndex));
        end
        
        function updateRoute(obj, car)
            if numel(car.getRouteNodes) <= 2
                obj.ownedEdgesMask(:,car.ID) = false;
            else
                edgeList = obj.graph.getEdgeList;
                ownedEdges = ismember(edgeList,[car.getRouteNodes(1:end-1),car.getRouteNodes(2:end)],'rows') | ...
                             ismember(edgeList,[car.getRouteNodes(2:end),car.getRouteNodes(1:end-1)],'rows');
                obj.ownedEdgesMask(:,car.ID) = kron(ownedEdges,[1;1;1]);
            end
            set(obj.lines(car.ID),'xdata',car.getRoute(:,2),...
                                  'ydata',car.getRoute(:,1));
            obj.refreshBackground;
        end

        function refreshBackground(obj)
            visibleCars = strcmp(get(obj.lines,'visible'),'on');
            bg = any(obj.ownedEdgesMask(:,visibleCars),2);
            xdata = obj.nodeXData;
            ydata = obj.nodeYData;
            xdata(bg) = NaN;
            ydata(bg) = NaN;
            set(obj.backgroundLine,'xdata',xdata,...
                                   'ydata',ydata);
        end
    end
    
end

