classdef QuadCopter < Vehicle
    %% Class representing a quadcopter drone
    properties
        charge = 1      % Fraction of range remaining
        cargo = []      % Vector of Items that the quadcopter is carrying
        waypointTargets = {}  % vector of requests/ground vehicles located 
                              % at the lat/lons listed in the route property
        loadouts = {}   % Anticipated cargos departing the corresponding 
                        % location in waypointTargets
        isWaitingForGV = 0; % For sorting out the order between quadcopters and ground vehicles  
    end
    
    properties (Constant)
        capacity = 10   % How much can the quadcopter carry (weight)?
        maxRange = 100  % Distance drone can travel on full charge
        speed = 0.004   % Arbitrary, for MATLAB Kinematics   
       
    end
    
    properties (Access = private)
        connection
        locationListener
    end
    
    methods
        function obj = QuadCopter(IDIn,LocationIn)
            obj = obj@Vehicle(IDIn,LocationIn);
            obj.route = zeros(0,2);     % Set dimensionality of route
            %obj.connection = QuadCopterConnection('',10003);
            %obj.locationListener = event.listener(obj.connection,'datagramReceived',@obj.unpackDatagram);
            obj.cargo = ItemFactory.makeItem('empty');
        end    
        
        function waypointReached(obj)
            waypointReached@Vehicle(obj);
            obj.waypointTargets = obj.waypointTargets(2:end);
            obj.loadouts = obj.loadouts(2:end);
        end
        
        function unpackDatagram(obj)
            %obj.location = [obj.connection.lastData.latitude,...
            %                obj.connection.lastData.longitude];
        end
        
        function setLocation(obj,newLocation)
            obj.location = newLocation;
        end
        
        function delete(obj)
            delete(obj.locationListener);
            delete(obj.connection);
        end
        
        function set.isWaitingForGV(obj,newValue)
            if newValue < 0
                obj.isWaitingForGV = 0;
            else
                obj.isWaitingForGV = newValue;
            end
        end
    end
    
end

