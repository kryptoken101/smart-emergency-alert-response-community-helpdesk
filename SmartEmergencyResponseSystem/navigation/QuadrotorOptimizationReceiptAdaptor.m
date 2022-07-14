classdef QuadrotorOptimizationReceiptAdaptor < handle
    %QUADROTOROPTIMIZATIONRECEIPTADAPTOR 
    
    properties
        outbox      % Connection to send data to the command center
        inbox       % Connection to receive data from the command center
        
        worldState  % Representation of the state of everything
    end
    
    methods
        function obj = QuadrotorOptimizationReceiptAdaptor(ipAddress,inport,outport)
            obj.outbox = EventDispatcher(ipAddress,outport);
            obj.inbox = EventListener('',inport,@obj.processState);
            
            obj.worldState = WorldState;
        end
        
        function delete(obj)
            delete(obj.outbox);
            delete(obj.inbox);
        end
    end
    
    methods (Access = private)
        function processState(obj,msg)
           fields = strsplit(msg,',');
           switch fields{1}
               case 'GO'
                   obj.optimize(str2double(fields{2}));
                   obj.worldState = WorldState;
               case 'QC'
                   idx = str2double(fields{2});
                   [obj.worldState.quadcopters(idx).latitude,...
                    obj.worldState.quadcopters(idx).longitude,...
                    obj.worldState.quadcopters(idx).battery,...
                    obj.worldState.quadcopters(idx).cargo] = ...
                            QuadrotorOptimizationReceiptAdaptor.unpackQuadcopterString(fields(3:end));
               case 'GV'
                   idx = str2double(fields{2});
                   [obj.worldState.groundVehicles(idx).latitude,...
                    obj.worldState.groundVehicles(idx).longitude] = ...
                            QuadrotorOptimizationReceiptAdaptor.unpackGroundVehicleString(fields(3:4));
               case 'RQ'
                   newRequest.ID = str2double(fields{2});
                   [newRequest.latitude,...
                    newRequest.longitude,...
                    newRequest.item,...
                    newRequest.quantity,...
                    newRequest.isDelivery] = ...
                            QuadrotorOptimizationReceiptAdaptor.unpackRequestString(fields(3:7));
                    obj.worldState.requests = [obj.worldState.requests newRequest];
           end
        end
        
        function optimize(obj, timeout)
            if any(isempty([obj.worldState.quadcopters.latitude])) || ...
               any(isempty([obj.worldState.groundVehicles.latitude])) || ...
               any(isempty([obj.worldState.requests.latitude]))
                obj.outbox.dispatch('FAILED, Empty Input');
            else
                [nodePaths, loadouts, exitflag] = QuadrotorRoutePlanner.planRoutes(...
                                                    obj.worldState.requests,...
                                                    obj.worldState.quadcopters,...
                                                    obj.worldState.groundVehicles,...
                                                    timeout);
                if exitflag ~= 0
                    obj.outbox.dispatch('FAILED, No feasible solution');
                    return;
                end
                
                for quadcopter = 1:numel(nodePaths)
                    routeString = [num2str(quadcopter),','];
                    for node = 1:numel(nodePaths{quadcopter})
                        routeString = [routeString num2str(nodePaths{quadcopter}(node)) ','];
                        if node <= numel(loadouts{quadcopter})
                            for item = loadouts{quadcopter}{node}
                                routeString = [routeString item.name ','];
                            end
                        end
                    end
                    obj.outbox.dispatch(routeString);
                    disp(routeString)
                end
                obj.outbox.dispatch('DONE');
            end        
        end
    end
    
    methods (Static)
        function [lat, lon, battery, cargo] = unpackQuadcopterString(msg)
            lat = str2double(msg{1});
            lon = str2double(msg{2});
            battery = str2double(msg{3});
            cargo = ItemFactory.makeItem('empty');
            for item = msg(4:end)
                cargo = [cargo, ItemFactory.makeItem(item{1})];
            end
        end
        
        function [lat, lon] = unpackGroundVehicleString(msg)
            lat = str2double(msg{1});
            lon = str2double(msg{2});
        end
        
        function [lat, lon, item, quantity, isDelivery] = unpackRequestString(msg)
            lat = str2double(msg{1});
            lon = str2double(msg{2});
            item = ItemFactory.makeItem(msg{3});
            quantity = str2double(msg{4});
            isDelivery = (msg{5} == '1');
        end
    end
end

