classdef GroundVehicle < Vehicle
    %% Class representing a car 
    properties (SetAccess = private)
        nearestNode % Index of the next node this car will visit (or current node if the car is at a node)
        nodeTable   % Table of all nodes (used to convert between node indices and lat/lon)
    end
    
    properties
        speed = 0.005;
        isWaitingForQuad = 0;
        cargo = [];
        
        % JZA
       % route = {}  % vector of requests/ground vehicles located 
                              % at the lat/lons listed in the route property

        routeNodes = {}   % Anticipated cargos departing the corresponding 
                        % location in waypointTargets
    end
    
    methods
        function obj = GroundVehicle(IDIn, locationIn, nodeIn, nodeTableIn)
            obj = obj@Vehicle(IDIn,locationIn);
            obj.nearestNode = nodeIn;
            obj.nodeTable = nodeTableIn;
        end
        
        function setRoute(obj, routeIn)
            if size(routeIn,2) == 1
                obj.route = routeIn;
            else
                warning('Ground vehicle routes must be specified using node indices');
            end
        end  
        
        function retval = getRoute(obj,varargin)
            latlonRoute = obj.nodeTable.nodeLocations(obj.route,:);
            if nargin == 1
                retval = latlonRoute;
            else
                retval = latlonRoute(varargin{:});
            end
            
        end
        
        function retval = getRouteNodes(obj,varargin)
            if nargin == 1
                retval = obj.route;
            else
                retval = obj.route(varargin{:});
            end
        end
        
        function moveTo(obj,newLocation)
            obj.location = newLocation;
            for cargoItem = obj.cargo
                cargoItem.location = obj.location;
            end
        end
        
        function addCargo(obj,newVehicle)
            obj.cargo = [obj.cargo newVehicle];
        end
        
        % JZA
        function set.isWaitingForQuad(obj,newValue)
            if newValue < 0
                obj.isWaitingForQuad = 0;
            else
                obj.isWaitingForQuad = newValue;
            end
        end
        
        % JZA
        function waypointReached(obj)
            waypointReached@Vehicle(obj);
            obj.route = obj.route(2:end,:);
            %obj.routeNodes = obj.routeNodes(2:end);
        end
        
        % JZA
%         function waypointReached(obj)
%             waypointReached@Vehicle(obj);
%             obj.routeNodes = obj.routeNodes(2:end);
%             obj.loadouts = obj.loadouts(2:end);
%         end
    end   
end

