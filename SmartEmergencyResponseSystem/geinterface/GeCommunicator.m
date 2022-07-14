classdef GeCommunicator < handle
    %   This class contains ports to send position of the fleet to the 
    %   GEInterface. It has listeners for the positions of the fleet and
    %   sends them via respective UDP ports to the 
    
    properties (Access = protected)
       
        VehAddPort;
        Vaddudp;
    end
    
    methods
        function obj = GeCommunicator(groundVehicleManager,...
                                 quadCopterManager,...
                                 biobotManager,...
                                 atlasManager,...
                                 kukaManager)
            obj.VehAddPort = 4018;                 
            GroundVehicles = groundVehicleManager.getVehicles();
            Quadcopters = quadCopterManager.getVehicles();            
            %FixedWings = fixedwingManager.getVehicles();
            Biobots = biobotManager.getVehicles();
            Atlas = atlasManager.getVehicles();
            Kukas = kukaManager.getVehicles();
                                                   
            obj.Vaddudp = udp('127.0.0.1',obj.VehAddPort+30,'LocalPort',obj.VehAddPort);
            fopen(obj.Vaddudp);
            % Vehicle type and number are sent over UDP
            % 1 - Ground Vehicle
            % 2 - QuadCopters
            % 3 - FixedWing
            % 4 - Biobot
            % 5 - Kukabot
            % 6 - Atlas
            
            if ~(isempty(GroundVehicles)) 
                fwrite(obj.Vaddudp,[1,numel(GroundVehicles), [GroundVehicles.location]],'single'); 
            end
            pause(2);
            
            if ~(isempty(Quadcopters)) 
                fwrite(obj.Vaddudp,[2,numel(Quadcopters), [Quadcopters.location]],'single');
            end
            pause(2);
            
            % Add only one fixed wing
            fwrite(obj.Vaddudp,[3,1, [37.8057, -122.4568]],'single'); 
            pause(2);
            
            if ~(isempty(Biobots)) 
                fwrite(obj.Vaddudp,[4,numel(Biobots), [Biobots.location]],'single');
            end
            pause(2);
            
            if ~(isempty(Atlas)) 
                fwrite(obj.Vaddudp,[6,numel(Atlas), [Atlas.location]],'single');
            end
            pause(2);
            
            if ~(isempty(Kukas)) 
                fwrite(obj.Vaddudp,[5,numel(Kukas), [Kukas.location]],'single');
            end
            pause(2);
            
            assignin('base','Vaddudp',obj.Vaddudp);
                
            %obj.listenVehicleCounts(obj, GroundVehicles , Quadcopters , []);%evalin('base', 'FW'));
        end
                
        function delete(obj)
            fclose(obj.Vaddudp);            
        end
        
        function listenVehicleCounts(obj, objGV,objQC, objFW)           
                        
            obj.VC.GVcount = numel(getVehicles(objGV));
            obj.VC.QCcount = numel(getVehicles(objQC));
            obj.VC.FWcount = numel(getVehicles(objFW));
            
            addlistener(objGV,'vehicleAdded',@(src,event,str)obj.GVcountCB(src,event,'A'));
            addlistener(objQC,'vehicleAdded',@(src,event,str)obj.QCcountCB(src,event,'A'));
            addlistener(objFW,'vehicleAdded',@(src,event,str)obj.FWcountCB(src,event,'A'));
            
            addlistener(objGV,'vehicleRemoved',@(src,event,str)obj.GVcountCB(src,event,'R'));
            addlistener(objQC,'vehicleRemoved',@(src,event,str)obj.QCcountCB(src,event,'R'));
            addlistener(objFW,'vehicleRemoved',@(src,event,str)obj.FWcountCB(src,event,'R'));
        end
        
        function GVcountCB(obj,~,~, str)
            if strcmp(str,'A') 
                obj.VC.GVcount = obj.VC.GVcount + 1;
            elseif strcmp(str,'R')
                obj.VC.GVcount = obj.VC.GVcount - 1;
            end
        end
        
        function QCcountCB(obj,~,~, str)
            if strcmp(str,'A') 
                obj.VC.QCcount = obj.VC.QCcount + 1;
            elseif strcmp(str,'R')
                obj.VC.QCcount = obj.VC.QCcount - 1;
            end
        end
        
        function FWcountCB(obj,~,~, str)
            if strcmp(str,'A') 
                obj.VC.FWcount = obj.VC.FWcount + 1;
            elseif strcmp(str,'R')
                obj.VC.FWcount = obj.VC.FWcount - 1;
            end
        end
    end
    
end

