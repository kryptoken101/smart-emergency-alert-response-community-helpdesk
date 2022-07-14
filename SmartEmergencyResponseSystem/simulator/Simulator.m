classdef Simulator < handle
    %SIMULATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private, GetAccess = private)
        GroundVehicles
        Quadcopters
        Requests
        Biobots
        Kukas
        ATLASes
        FixedWings
        MyDrone
        simdt
        
        BBudp
        KKudp
        ATudp
        stepTimer
    end
    
    methods
        function obj = Simulator(groundVehicleManager,...
                                 quadCopterManager,...
                                 requestManager,...
                                 biobotManager,...
                                 kukaManager,...
                                 ATLASManager,...
                                 fixedWingManager,...
                                 myDroneManager,...
                                 simdt)
            obj.GroundVehicles = groundVehicleManager;
            obj.Quadcopters = quadCopterManager;
            obj.Requests = requestManager;
            obj.Biobots = biobotManager;
            obj.Kukas = kukaManager;
            obj.ATLASes = ATLASManager;
            obj.FixedWings = fixedWingManager;
            obj.MyDrone = myDroneManager;
            obj.simdt = simdt;          
            obj.stepTimer = timer('Name','FrameTimer',...
                                  'ExecutionMode','fixedRate',...
                                  'Period',obj.simdt);
            obj.startUDP;
        end
        
        function startUDP(obj)
            ATport = 4015;
            BBport = 4016;                        
            KKport = 4017;
            
            GeIP = '127.0.0.1';
            
            obj.BBudp = udp(GeIP,BBport+30,'LocalPort',BBport);
            obj.KKudp = udp(GeIP,KKport+30,'LocalPort',KKport); 
            obj.ATudp = udp(GeIP,ATport+30,'LocalPort',ATport); 
            
            fopen(obj.BBudp);
            fopen(obj.KKudp);
            fopen(obj.ATudp);
        end
        
        function start(obj)
            %obj.setGVDependency();
            obj.setQCDependency();
            set(obj.stepTimer,'TimerFcn',@(~,~)obj.step());
            start(obj.stepTimer);
        end
        
        function stop(obj)
            stop(obj.stepTimer)
        end
        
        function delete(obj)
            delete(obj.BBudp);
            delete(obj.KKudp);
            delete(obj.ATudp);
        end
    end
    
    methods (Access = private)
        function step(obj)
%             persistent lasttime
%             thistime = toc;
%             disp(thistime-lasttime)
%             lasttime = thistime;
            obj.simGroundVehicles();
            obj.simQuadCopters();
            obj.simBiobots();
            obj.simKukas();
            obj.simATLAS();
            obj.simFixedWings();
            obj.simMyDrone();
            drawnow
        end
        
        
        % JZA: quadcopter has to wait for the car to arrive at a depot
        % station. Therefore adding this function
        function setQCDependency(obj)

            for vehicle = obj.Quadcopters.getVehicles()
                vehicle.isWaitingForGV = 0;
                %vhw = vehicle.isWaitingForGV; 
                disp('for loop for 1');
            end
            
            for groundvehicle = obj.GroundVehicles.getVehicles()
                disp('getGV');
                for i = 1:numel(groundvehicle.getRouteNodes)
                    disp([groundvehicle.getRouteNodes]);
                    mc = metaclass(groundvehicle.getRouteNodes);
                    %if (vhw == 1)
                        disp('if waiting');
                    if (strcmp(mc.Name, 'QuadCopter') || strcmp(mc.Name, 'Quadcopter'))
                        disp('for loop for QC');
                        groundvehicle.route{i}.isWaitingForGV = ...
                            groundvehicle.route{i}.isWaitingForGV + 1; 
                        
                    end
                    %end
                end
            end
        end
        
        
        function setGVDependency(obj)

            for vehicle = obj.GroundVehicles.getVehicles()
                vehicle.isWaitingForQuad = 0;
            end
            
            for quadcopter = obj.Quadcopters.getVehicles()
                for i = 1:numel(quadcopter.waypointTargets)
                    mc = metaclass(quadcopter.waypointTargets{i});
                    if strcmp(mc.Name, 'GroundVehicle')
                        quadcopter.waypointTargets{i}.isWaitingForQuad = ...
                            quadcopter.waypointTargets{i}.isWaitingForQuad; % + 1; 
                        %JZA: Commented out the +1 because we should let the GV go to the depos and do not wait for the quads to arrive.  
                    end
                end
            end
        end
    


        function simQuadCopters(obj)
            quads = obj.Quadcopters.getVehicles();
            data = zeros(numel(quads),6);
            idx = 0;
            % Loop over all Quadcopters
            for quadcopter = quads
                idx = idx + 1;
                
                plannedRoute = quadcopter.getRoute();

                if (size(plannedRoute,1)>1) % Keep navigating while there is at least one more target
                    targetLoc = plannedRoute(2,:);
                    speed = quadcopter.speed;
                    % Check if quad is close enough to the waypoint to reach in one step
                    if (norm(quadcopter.location - targetLoc)<speed*obj.simdt)
                        quadcopter.charge = quadcopter.charge-norm(quadcopter.location-targetLoc)./QuadCopter.maxRange;
                        quadcopter.location = targetLoc;    % In this step quad reaches the waypoint
                        quadcopter.cargo = quadcopter.loadouts{2};
                        currentTarget = quadcopter.waypointTargets{2};
                        mc = metaclass(currentTarget);
                        if (strcmp(mc.Name,'Request'))
                            obj.Requests.removeRequestByID(currentTarget.ID);
                        elseif strcmp(mc.Name,'GroundVehicle')
                            currentTarget.isWaitingForQuad = ...
                                currentTarget.isWaitingForQuad - 1;
                        end
                        quadcopter.waypointReached();         % It covered one more waypoint

                        % Also check if Quad is done with it's route
                        % and needs to ride on the GV
                        % JZA: Uncommented this check for Quads to find the
                        % GV at the end of their capacity for the mission,
                        % however it made the quads dissapear at the end. 
%                         if (size(quadcopter.getRoute(),1)==1) % This is the last waypoint
%                             quadcopter.waypointTargets{1}.addCargo(quadcopter);
%                             quadcopter.deactivate;
%                         end

                    else
                        % Move the quad by one time step in the correct direction
                        heading = targetLoc - quadcopter.location;
                        quadcopter.location = quadcopter.location + speed*obj.simdt*heading/norm(heading);
                        quadcopter.charge = quadcopter.charge - speed*obj.simdt/QuadCopter.maxRange;
                    end                  
                    head = targetLoc-quadcopter.location;
                    data(idx,:) = [quadcopter.location 40 atan2d(head(1),head(2)) 0 0];
                end                
            end
            %fwrite(obj.QCudp,data(:));
        end
        
        function simGroundVehicles(obj)
            groundvehicles = obj.GroundVehicles.getVehicles();
            data = zeros(numel(groundvehicles),6);
            idx = 0;
            % Loop over all ground Vehicles and simulate
            for groundVehicle = groundvehicles
                idx = idx + 1;
                plannedRoute = groundVehicle.getRoute();
                
                if (size(plannedRoute,1)>1 && groundVehicle.isWaitingForQuad == 0) % Keep navigating until the GV reaches the final waypoint
                    targetLoc = plannedRoute(2,:);
                    speed = groundVehicle.speed;
                    % Check if GV is close enough to the waypoint to reach in one step
                    if (norm(groundVehicle.location - targetLoc)<speed*obj.simdt)
                        groundVehicle.moveTo(targetLoc); % In this step quad reaches the waypoint
                        groundVehicle.waypointReached();
                    else
                        % Move the quad by one time step in the correct direction
                        heading = targetLoc - groundVehicle.location;
                        groundVehicle.moveTo(groundVehicle.location + speed*obj.simdt*heading/norm(heading));
                    end
                    head = targetLoc-groundVehicle.location;
                    data(idx,:) = [groundVehicle.location 0 atan2d(head(1),head(2)) 0 0]; 
                end
            end
            %fwrite(obj.GVudp,data(:));
        end
       
        function simBiobots(obj)
            data = [];
            for biobot = obj.Biobots.getVehicles
                plannedRoute = biobot.getRoute;
                if size(plannedRoute,1)>1
                    Simulator.moveTowardPoint(biobot,Biobot.speed,plannedRoute(2,:),obj.simdt);
                    if size(biobot.getRoute,1)<=1
                        % Destination reached
                        mc = metaclass(biobot.currentTarget);
                        if strcmp(mc.Name,'Request')
                            obj.Requests.removeRequestByID(biobot.currentTarget.ID);
                        end
                    end
                end
                data(end+1,:) = [biobot.location 0 0 5 5];
            end
            fwrite(obj.BBudp,data(:),'double');
        end
        
        function simKukas(obj)
            data = [];
            for kuka = obj.Kukas.getVehicles
                plannedRoute = kuka.getRoute;
                if size(plannedRoute,1)>1
                    Simulator.moveTowardPoint(kuka,Kuka.speed,plannedRoute(2,:),obj.simdt);
                    if size(kuka.getRoute,1)<=1
                        % Destination reached
                        mc = metaclass(kuka.currentTarget);
                        if strcmp(mc.Name,'Request')
                            obj.Requests.removeRequestByID(kuka.currentTarget.ID);
                        end
                    end
                end
                data(end+1,:) = [kuka.location 0 0 5 5];
            end
            fwrite(obj.KKudp,data(:),'double');
        end
        
        function simATLAS(obj)
            data = [];
            for ATLAS = obj.ATLASes.getVehicles
                plannedRoute = ATLAS.getRoute;
                if size(plannedRoute,1)>1
                    Simulator.moveTowardPoint(ATLAS,Atlas.speed,plannedRoute(2,:),obj.simdt);
                    if size(ATLAS.getRoute,1)<=1
                        % Destination reached
                        mc = metaclass(ATLAS.currentTarget);
                        if strcmp(mc.Name,'Request')
                            obj.Requests.removeRequestByID(ATLAS.currentTarget.ID);
                        end
                    end
                end
                data(end+1,:) = [ATLAS.location 0 0 5 5];
            end
            fwrite(obj.ATudp,data(:),'double');
        end
        
        function simFixedWings(obj)
            for fixedWing = obj.FixedWings.getVehicles
                plannedRoute = fixedWing.getRoute;
                if size(plannedRoute,1)>1
                    Simulator.moveTowardPoint(fixedWing,FixedWing.speed,plannedRoute(2,:),obj.simdt);
                end
            end
        end
        function simMyDrone(obj)
            for myDrone = obj.MyDrone.getVehicles
                plannedRoute = myDrone.getRoute;
                if size(plannedRoute,1)>1
                    Simulator.moveTowardPoint(myDrone,myDrone.speed,plannedRoute(2,:),obj.simdt);
                end
            end
        end
    end
    
    methods (Static)
        function moveTowardPoint(vehicle, speed, destination, simdt)
            if norm(vehicle.location - destination)<=speed*simdt
                vehicle.location = destination;
                vehicle.waypointReached;
            else
                direction = destination - vehicle.location;
                vehicle.location = vehicle.location + speed*simdt*direction/norm(direction);
            end
        end
    end
    
end

