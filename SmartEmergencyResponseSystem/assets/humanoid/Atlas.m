classdef Atlas < ConnectedVehicle
    %ATLAS Summary of this class goes here
    %   Detailed explanation goes here
    properties (Access = private)
        
        ConnectionipAddress = '127.0.0.1';
        ConnectionPortNumber = 5345;

        % Other properties
        connection
        datagramListener
        heading
    end
    
    properties 
        currentTarget       % Current destination of the ATLAS (request or ground vehicle)
    end
    
    properties (Constant)
        speed = .002;
    end
    
    methods
        function obj = Atlas(portIn,IDIn,LocationIn)
            obj = obj@ConnectedVehicle(portIn,IDIn,LocationIn); % Random Id and location for the vehicle
%            obj.connection = KukaConnection(obj.ConnectionipAddress,obj.ConnectionPortNumber);
%            obj.datagramListener = event.listener(obj.connection,'datagramReceived',@obj.unpackDatagram);
        end
        
        function delete(obj)
            delete(obj.datagramListener);
            delete(obj.connection);
        end
    end
    
    methods (Access = private)
        function unpackDatagram(obj,src,~)
            obj.location = [src.lastData.latitude src.lastData.longitude];
            obj.heading = src.lastData.heading;
        end
    end
    
end

