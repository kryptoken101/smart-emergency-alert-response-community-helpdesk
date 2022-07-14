classdef DSim < handle
    %DSIM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
         GroundVehicles
         Quadcopters
         %FixedWings      
                  
    end
    
    methods
        
        function obj = DSim(groundVehicleManager,quadCopterManager,biobotManager,kukaManager,atlasManager,FixedWingManager)
            
            obj.GroundVehicles = groundVehicleManager;
            obj.Quadcopters = quadCopterManager;
                       
            assignin('base','nGV',numel(obj.GroundVehicles.getVehicles()));
            assignin('base','nRC',numel(obj.Quadcopters.getVehicles()));
            assignin('base','nFW',1);                        
            
            assignin('base','GVManager',obj.GroundVehicles);
            assignin('base','QCManager',obj.Quadcopters);
            evalin('base','setupSimulator()');                                                       
            
            %choice = questdlg('Would you like to send waypoints?', ...
            %' ', ...
            %'Yes','No','No');
        % Handle response
        %switch choice
        %    case 'Yes'
        %        disp([choice ' coming right up.'])
        
        %    case 'No'
        %        disp([choice ' coming right up.'])        
        
        %end
            
        %    obj.setWaypoints();
            try
                evalin('base','fopen(Vaddudp)');
            catch
                disp('GE UDP port open');
            end
            evalin('base','fwrite(Vaddudp,0,''single'');');
            evalin('base','fclose(Vaddudp)');                    
        end
        
        
        function stop(obj)
            
        end          
        
        function setWaypoints(obj)
            
            SimuLinkIP = '127.0.0.1';            
            
            GVFleetSLP = 9040;
            FWFleetSLP = 9080;
            RCFleetSLP = 9020;
            
            groundvehicles = obj.GroundVehicles.getVehicles();            
            idx = 0;
            % Loop over all ground Vehicles and simulate
            for groundVehicle = groundvehicles
                idx = idx + 1;
                
                plan = groundVehicle.getRoute();
                nWP = size(plan,1);
                
                if numel(plan) == 0
                    dataGV = [groundVehicle.location(1) * ones(1,100);groundVehicle.location(2) * ones(1,100); 0, -1, zeros(1,98) ];
                else
                    dataGV=[groundVehicle.location(1), plan(:,1)', plan(end,1)*ones(1,99-nWP); groundVehicle.location(2), plan(:,2)', plan(end,2)*ones(1,99-nWP); zeros(1,nWP),-1,zeros(1,99-nWP)];
                end
                sendWaypointsUDP(dataGV,idx,SimuLinkIP,GVFleetSLP);
                pause(0.5)
            end
            
            quads = obj.Quadcopters.getVehicles();            
            idx = 0;
            
            % Loop over all Quadcopters
            for quadcopter = quads
                idx = idx + 1;
                
                plan = quadcopter.getRoute();
                nWP = size(plan,1);
                
                if numel(plan) == 0
                    dataQC=[quadcopter.location(1)*ones(1,100); quadcopter.location(2)*ones(1,100); 50*ones(1,100);zeros(1,100);5*ones(1,100)];
                else
                    dataQC=[quadcopter.location(1), plan(:,1)', plan(end,1)*ones(1,99-nWP); quadcopter.location(2), plan(:,2)', plan(end,2)*ones(1,99-nWP); 50*ones(1,100);zeros(1,100);5*ones(1,100)];
                end
                
                sendWaypointsUDP(dataQC,idx,SimuLinkIP,RCFleetSLP);
                pause(0.5)
            end
            
            FW = load('FWroute.mat');
            dataFW = [ FW.routeData' ; 100*ones(1,100)];
            sendWaypointsUDP(dataFW,1,SimuLinkIP,FWFleetSLP);
        end                       
    end    
end

