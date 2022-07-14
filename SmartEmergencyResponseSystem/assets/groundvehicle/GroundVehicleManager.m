classdef GroundVehicleManager < VehicleManager
    %% Class to keep track of all the ground vehicles
    
    properties (Access = private)
        nodeTable       % Instance of NodeTable
    end
    
    methods
        function obj = GroundVehicleManager(nodeTableIn)
            obj.nodeTable = nodeTableIn;
            obj.vehicleTypeName = 'Station Truck';
        end
        
        function newCar = addVehicle(obj,placeIn)
            if numel(placeIn) == 1
                locationIn = obj.nodeTable.nodeLocations(placeIn,:);
                nodeIn = placeIn;
            elseif numel(placeIn) == 2
                locationIn = placeIn;
                nodeIn = obj.nodeTable.getNearestNode(placeIn(1),placeIn(2));
            else
                error('Input must have 1 or 2 elements')
            end
            newCar = GroundVehicle(obj.getID,locationIn, nodeIn, obj.nodeTable);
            obj.addVehicle@VehicleManager(newCar);
        end
    end
end