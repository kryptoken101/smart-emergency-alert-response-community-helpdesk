classdef EventDispatcher < handle
    %% Event Dispatcher object
    %  This class essentially wraps MATLAB's built-in 'notify', however it
    %  also provides the same functionality over UDP.
    %
    %  Valid usages:
    %   d = EventDispatcher
    %
    %   d = EventDispatcher(ipaddress, portnumber)
    %       ipaddress - Destination ipaddress to which to send
    %                   notifications
    %       portnumer - Destination port number
    %
    %  NOTE: Due to limitations on UDP (and the fact that I didn't
    %  implement general serialization), only ASCII strings can be sent.
    properties (Access = private)
        udpConnection = [];
    end
    
    methods (Access = public)
        function obj = EventDispatcher(varargin)
            if nargin == 2
               obj.udpConnection = udp(varargin{1},varargin{2},'OutputBufferSize',4096);
               fopen(obj.udpConnection);
            end            
        end
        
        function dispatch(obj,message)
            if ~ischar(message)
                warning('Cannot send non-ASCII message...ignoring.')
                return
            end
            
            if isempty(obj.udpConnection) || ~isvalid(obj.udpConnection)
                notify(obj,'dataMessageSend',DataMessage(message));
            else
                fprintf(obj.udpConnection,message);
            end
        end  
        
        function delete(obj)
            if ~isempty(obj.udpConnection)
                fclose(obj.udpConnection);
                delete(obj.udpConnection);
            end
        end
    end
    
    events
        dataMessageSend
    end
    
end