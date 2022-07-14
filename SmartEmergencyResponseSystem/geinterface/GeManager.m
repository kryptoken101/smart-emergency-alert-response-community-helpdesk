classdef GeManager < handle
    %GEMANAGER This class recieves positional data from the GeCommunicator
    %and updates the Google earth interface accordingly    
    properties
       LAIdx;
       Cr;
       Views;
       
       CamRoll;
       CamTilt;
       CamHead;
    end
    
    properties (Access = protected)   
        
        Vaddudp;
        GVudp;      %UDP connections for the vehicles
        QCudp;
        FWudp;
        ATudp;
        BBudp;
        KKudp;
        
        GVdata;     %Data of vehicles locations
        QCdata;
        FWdata; 
        ATdata;
        BBdata;
        KKdata;
        
        IEwindow;        
        GeTimer;  
        
        nGV;
        nQC;
    end
    
    methods 
        function obj = GeManager()            
            
            % Open ActiveX-Control from Microsoft-Internet-Explorer
            GeInterface(obj);
            [explorer, parent] = actxcontrol('Shell.Explorer.2');                                   
            set(parent, 'units', 'normalized');            
            set(parent, 'Position',[0 0 785/810 645/710]);
            webpage = [pwd '/web/ge_interface.html'];
            Navigate(explorer, webpage); 
            obj.IEwindow = explorer.Document.parentWindow;            
            
            obj.nGV = 0;
            obj.nQC = 0;
            obj.CamRoll = 5;
            obj.CamTilt = 5;
            obj.CamHead = 0;
            load_system('ReceiveSimData');
            obj.GeTimer = timer('ExecutionMode','fixedRate','Period',0.2,'TimerFcn',@obj.updateGe);            
            obj.startUDP();
            obj.initData();                      
            
            obj.Cr = 0;
            obj.Views = 0;                      
        end              
        
        function startTimer(obj)
            start(obj.GeTimer);           
        end
        
        function stopTimer(obj)
            stop(obj.GeTimer);
        end
        
        function updateGe(obj,~,~)
            
            cm_head = -60;
            cm_tilt = 20;
            cm_roll = 0;
            
            updateQC(obj);
            updateGV(obj);
            updateFW(obj);
            updateBB(obj);
            updateKK(obj);
            updateAT(obj);
            
            GV = reshape(obj.GVdata,6,numel(obj.GVdata)/6);
            QC = reshape(obj.QCdata,6,numel(obj.QCdata)/6);
            FW = reshape(obj.FWdata,6,numel(obj.FWdata)/6);
            AT = reshape(obj.ATdata,6,numel(obj.ATdata)/6);
            KK = reshape(obj.KKdata,6,numel(obj.KKdata)/6);
            BB = reshape(obj.BBdata,6,numel(obj.BBdata)/6);
           
            
            QC(4,:) = QC(4,:)+90;   
          
            
            if ~isempty(AT)
                AT(3,:) = AT(3,:)+30;
            end
            
            VC = [GV'; QC'; FW'; BB'; KK'; AT'];
            
            mode = [ones(1,size(GV,2)), zeros(1,size(QC,2)+size(FW,2)), zeros(1,size(KK,2)+size(BB,2)+size(AT,2))];
                      
            if isempty(VC)
                return
            end
            ch = evalin('base','Ch');
            if ch ~= 0                
                obj.CamHead = VC(obj.LAIdx,4);
            end
            
            if ~obj.Cr                                
                 LA = repmat([VC(obj.LAIdx,1),VC(obj.LAIdx,2),VC(obj.LAIdx,3),mode(obj.LAIdx),mod(obj.CamHead+90,360),obj.CamTilt,obj.CamRoll],size(VC,1),1);                            
            else
                LA = repmat([VC(obj.LAIdx,1),VC(obj.LAIdx,2),VC(obj.LAIdx,3),1,cm_head,cm_tilt,cm_roll],size(VC,1),1);            
                          
            end
            
            if ~isempty(AT)
                
            end
            
           
            FW(4,:) = FW(4,:)+90;
            FW = obj.parseUDP(FW); 
            
            
            LA = obj.parseUDP(LA');
              
            if ~isempty(GV)
                GV = obj.parseUDP(GV);
                obj.IEwindow.execScript(['move6GV(' GV{1} ',' GV{2} ',' GV{3} ',' GV{4} ',' GV{5} ',' GV{6} ')'], 'Jscript');
            end
            if ~isempty(QC)
                QC = obj.parseUDP(QC);
                obj.IEwindow.execScript(['move6AR(' QC{1} ',' QC{2} ',' QC{3} ',' QC{4} ',' QC{5} ',' QC{6} ')'], 'Jscript');
            end
                obj.IEwindow.execScript(['move6FW(' FW{1} ',' FW{2} ',' FW{3} ',' FW{4} ',' FW{5} ',' FW{6} ')'], 'Jscript');
            if ~isempty(AT)
                AT(3,:) = AT(3,:)-30;
                AT = obj.parseUDP(AT);
                obj.IEwindow.execScript(['move6AT(' AT{1} ',' AT{2} ',' AT{3} ',' AT{4} ',' AT{5} ',' AT{6} ')'], 'Jscript');            
            end
            if ~isempty(BB)
                BB = obj.parseUDP(BB);
                obj.IEwindow.execScript(['move6BB(' BB{1} ',' BB{2} ',' BB{3} ',' BB{4} ',' BB{5} ',' BB{6} ')'], 'Jscript');            
            end
            if ~isempty(KK)
                KK = obj.parseUDP(KK);
                obj.IEwindow.execScript(['move6KK(' KK{1} ',' KK{2} ',' KK{3} ',' KK{4} ',' KK{5} ',' KK{6} ')'], 'Jscript');            
            end
            
            
            
            if ~(obj.Cr)
                obj.IEwindow.execScript(['moveFullLaView(' num2str(obj.LAIdx-1) ',' LA{1} ',' LA{2} ',' LA{3} ',' LA{4} ',' LA{5} ',' LA{6} ',' LA{7} ')'], 'Jscript');                
            else
                obj.IEwindow.execScript(['moveFullCmView(' num2str(obj.LAIdx-1) ',' LA{1} ',' LA{2} ',' LA{3} ',' LA{5} ',' LA{6} ',' LA{7} ')'], 'Jscript');
            end
              
            % Set LAIdx to -1 to not update
            obj.IEwindow.execScript(['synchronousUpdate(' num2str(obj.LAIdx-1) ', -1, 0, 0, 0, 0, 0, 0, 0)'], 'Jscript');
             
        end
        
        function delete(obj)
            
            stop(obj.GeTimer);
            delete(obj.GeTimer);
            
            fclose(obj.FWudp); 
            fclose(obj.Vaddudp);
            fclose(obj.QCudp);
            fclose(obj.GVudp);
        end        
        
    end
    
    methods (Access = protected)
        function initData(obj)
            obj.GVdata = [];     %Data of vehicles locations
            obj.QCdata = [];
            obj.FWdata = []; 
            obj.ATdata = [];
            obj.BBdata = [];
            obj.KKdata = [];
        end
        
        function startUDP(obj)
                         
            Vaddport = 4018;
            
            GeIP = '127.0.0.1';
            
            obj.Vaddudp = udp(GeIP,'LocalPort',Vaddport+30);                        
            obj.Vaddudp.DatagramReceivedFcn = @(~,~)obj.VehCount();
            fopen(obj.Vaddudp);
                        
        end                
        
        % Read UDP data from the other computer
        function updateGV(obj)
              data = evalin('base','GVdata');
              obj.GVdata = reshape(data,6,numel(data)/6); 
            
        end
        
        function updateQC(obj)
              data = evalin('base','QCdata');
              obj.QCdata = reshape(data,6,numel(data)/6); 
        end
        
        function updateFW(obj)
            data = evalin('base','FWdata');
            obj.FWdata = reshape(data,6,numel(data)/6); 
        end   
        
        function updateBB(obj)
            data = evalin('base','BBdata');
            obj.BBdata = reshape(data,6,numel(data)/6); 
        end   
        
        function updateKK(obj)
            data = evalin('base','KKdata');
            obj.KKdata = reshape(data,6,numel(data)/6); 
        end   
        
        function updateAT(obj)
            data = evalin('base','ATdata');
            obj.ATdata = reshape(data,6,numel(data)/6); 
        end           
            
        function VehCount(obj)
            
            data = fread(obj.Vaddudp, 100, 'single');
            if data(1) == 0                
                set_param('ReceiveSimData','SimulationCommand','start'); 
                obj.startTimer();
            else
            obj.Views = obj.Views + data(2);
            locations = data(3:end);
            locations = reshape(locations,2,numel(locations)/2);
            lat = locations(1,:);
            lon = locations(2,:);
            head = 0;
            cm_head = -60;
            cm_tilt = 20;
            cm_roll = 0;
            
            switch(data(1))
                case 1     % GV        
                    obj.nGV = obj.nGV + data(2);
                    s = num2str(6*obj.nGV);
                    set_param('ReceiveSimData/GVUDP','DataSize',['[' s ' 1]']);
                    for i = 1:data(2)
                        obj.IEwindow.execScript('addGroundVehicle()', 'Jscript');
                        pause(0.5)
                        obj.IEwindow.execScript( ...
                        ['addGVModel(' num2str(lat(i)) ',' num2str(lon(i)) ',' num2str(head) ')'], 'Jscript');
                        obj.GVdata(:,end+1) = [lat(i) lon(i) 0 0 0 0]';
                        pause(0.5)                       
                    end
                    assignin('base','GVdata',obj.GVdata);
                     alt = 10;
                case 2      %QC
                    obj.nQC = obj.nQC + data(2);
                    s = num2str(6*obj.nQC);
                    set_param('ReceiveSimData/QCUDP','DataSize',['[' s ' 1]']);
                    for i = 1:data(2)
                        obj.IEwindow.execScript('addArDroneVehicle()', 'Jscript');
                        pause(0.5)
                        obj.IEwindow.execScript( ...
                        ['addARModel(' num2str(lat(i)) ',' num2str(lon(i)) ',' num2str(head) ')'], 'Jscript');
                        pause(0.5)
                        obj.QCdata(:,end+1) = [lat(i) lon(i) 100 0 0 0]';                         
                    end
                     assignin('base','QCdata',obj.QCdata);
                    alt = 120;
                case 3      %FW
                    for i = 1:data(2)
                        obj.IEwindow.execScript('addFixedWingVehicle()', 'Jscript');
                        pause(0.5)
                        obj.IEwindow.execScript( ...
                        ['addFWModel(' num2str(lat(i)) ',' num2str(lon(i)) ',' num2str(head) ')'], 'Jscript');
                        pause(0.5)
                        obj.FWdata(:,end+1) = [lat(i) lon(i) 100 0 0 0]'; 
                        assignin('base','FWdata',obj.FWdata);
                    end
                    alt = 100;
                case 4      %BB
                    s = num2str(data(2)*6);
                    set_param('ReceiveSimData/BBUDP','DataSize',['[' s ' 1]']);
                    for i = 1:data(2)
                        obj.IEwindow.execScript('addBiobot()', 'Jscript');
                        pause(0.5)
                        obj.IEwindow.execScript( ...
                        ['addBBModel(' num2str(lat(i)) ',' num2str(lon(i)) ',' num2str(head) ')'], 'Jscript');
                        pause(0.5)
                        obj.BBdata(:,end+1) = [lat(i) lon(i) 0 0 5 20]';
                        
                    end
                    assignin('base','BBdata',obj.BBdata);
                    alt = 10;
                case 5      %KK
                    s = num2str(data(2)*6);
                    set_param('ReceiveSimData/KKUDP','DataSize',['[' s ' 1]']);
                    
                    for i = 1:data(2)
                        obj.IEwindow.execScript('addKuka()', 'Jscript');
                        pause(0.5)
                        obj.IEwindow.execScript( ...
                        ['addKKModel(' num2str(lat(i)) ',' num2str(lon(i)) ',' num2str(head) ')'], 'Jscript');
                        pause(0.5)
                        obj.KKdata(:,end+1) = [lat(i) lon(i) 0 0 5 5]';                        
                    end
                    assignin('base','KKdata',obj.KKdata);
                     alt = 10;
                case 6      %AT
                    s = num2str(data(2)*6);
                    set_param('ReceiveSimData/ATUDP','DataSize',['[' s ' 1]']);
                    
                    for i = 1:data(2)
                        obj.IEwindow.execScript('addAtlas()', 'Jscript');
                        pause(0.5)
                        obj.IEwindow.execScript( ...
                        ['addATModel(' num2str(lat(i)) ',' num2str(lon(i)) ',' num2str(head) ')'], 'Jscript');
                        pause(0.5)
                        obj.ATdata(:,end+1) = [lat(i) lon(i) 0 0 5 15]';
                    end
                    assignin('base','ATdata',obj.ATdata);
                    alt = 60;                    
                otherwise
                    %do nothing
                    disp('Incomprehensible data')
                    
            end                        
            
            
            la_head = 0;
            la_tilt = 70;
            la_range = 5;
            
            for i = 1:data(2)
                obj.IEwindow.execScript(['addLaView(' num2str(la_range) ',' num2str(la_tilt) ',' num2str(alt) ')'], 'Jscript');
                pause(0.5);
                obj.IEwindow.execScript(['teleportTo(' num2str(lat(i)) ',' num2str(lon(i)) ',' num2str(la_head) ')'], 'Jscript');
                pause(0.5);
                obj.IEwindow.execScript(['addCmView(' num2str(lat(i))  ',' num2str(lon(i))   ','  num2str(alt)  ',' num2str(cm_head) ',' num2str(cm_tilt) ',' num2str(cm_roll) ')'], 'Jscript');
                pause(0.5);
            end                         
            end
        end
        
        function out = parseUDP(~,data)
            dataStr = mat2str(data);
            dataCell = strsplit(dataStr(2:end-1),';');            
            out = cellfun(@(x) ['[' regexprep(x,' ',', ') ']'],dataCell,'UniformOutput',false);
        end                                             
        
    end
    
end

