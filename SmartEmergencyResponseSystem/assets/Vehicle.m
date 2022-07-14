classdef Vehicle < handle
    %% Class representing a generic vehicle
    properties (SetAccess = private)
        ID
    end
    
    properties (SetObservable)
        location    % Current lat/lon of the vehicle
    end
    
    properties (SetObservable, Access = protected)
        route       % List of destinations indicating the planned route
    end
    
    methods
        function obj = Vehicle(IDIn, locationIn)
            obj.ID       = IDIn;
            obj.location = locationIn;
            
            addlistener(obj,'location','PostSet',@(~,~)notify(obj,'locationChanged'));
            addlistener(obj,'route','PostSet',@(~,~)notify(obj,'routeChanged'));
        end
        
        function retval = getRoute(obj,varargin)
            if nargin == 1
                retval = obj.route;
            else
                retval = obj.route(varargin{:});
            end
        end
        
        function setRoute(obj, routeIn)
            obj.route = routeIn;
        end
        
        function waypointReached(obj)
            obj.route = obj.route(2:end,:);
        end
        
        function activate(obj)
            notify(obj,'activated');
        end
        
        function deactivate(obj)
            notify(obj,'deactivated');
        end
        
        function delete(obj)
            notify(obj,'beingDeleted');
        end
    end
    
    events
        locationChanged
        routeChanged
        beingDeleted
        activated
        deactivated
    end    
end

