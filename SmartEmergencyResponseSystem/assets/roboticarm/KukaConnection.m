classdef KukaConnection < handle
    %% Connection for a connected vehicle
    %  Latest Data received is stored in lastData.
    %  Latest Data received that has the valid flag set to true is
    %  stored in lastValidData.
    %
    %  Also provides events datagramReceived that fires when any Data
    %  is received as well as validDatagramReceived that fires when any
    %  *valid* GPS data is received.
    
    properties (Access = private)
        dataListener
    end
    
    properties (GetAccess = public)
        lastData
    end
    
    methods
        function obj = KukaConnection(varargin)
            obj.dataListener = EventListener(varargin{:},@obj.processKukaString);
        end
        
        function processKukaString(obj,raw)
            processedData = KukaConnection.parseGPSString(raw);
            if isempty(processedData)
                return;
            end
            
            obj.lastData = processedData;
            notify(obj,'datagramReceived');
        end
        
        function delete(obj)
            delete(obj.dataListener);
        end
    end
    
    methods (Static)
        function retval = parseGPSString(raw)
            expression = '(?<id>\w*),(?<latitude>[+-]?\d*\.?\d*),(?<longitude>[+-]?\d*\.?\d*),(?<heading>[+-]?\d*\.?\d*)';
            results = regexp(raw,expression,'names','once');
            if ~isempty(results)
                retval.id = results.id;
                retval.latitude = str2double(results.latitude);
                retval.longitude = str2double(results.longitude);
                retval.heading = mod(str2double(results.heading),360);
                retval.timestamp = datestr(now);
            else
                retval = [];
            end
            
            disp(raw)
        end
    end
    
    events
        datagramReceived
    end    
end

