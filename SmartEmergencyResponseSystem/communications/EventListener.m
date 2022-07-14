classdef EventListener < handle
    %% Event Listener object
    %  This class essentially wraps MATLAB's built-in 'addlistener', 
    %  however it also provides the same functionality over UDP.
    %
    %  Valid usages:
    %   e = EventListener(ipaddress, portnumber, callback)
    %       ipaddress  - String, unused
    %       portnumber - Port on which to listen for incoming traffic
    %       callback   - Function handle that takes a single string
    %                    argument
    %
    %   e = EventListener(dispatcher, callback)
    %       dispacher - Instance of EventDispatcher object to listen to
    %       callback  - Function handle that takes a single string argument
    %
    %  NOTE: Due to limitations on UDP (and the fact that I didn't
    %  implement general serialization), only ASCII strings can be sent.
    properties (Access = private)
        callbackFcn = [];
        
        % At most one of the following will be non-empty
        matlabListener = [];    % By holding the listener, the listener will be destroyed when this object is.
        udpConnection = [];
    end
    
    methods (Access = public)
        function obj = EventListener(varargin)
            if nargin == 2
                obj.callbackFcn = varargin{2};
                obj.matlabListener = event.listener(varargin{1},...
                                                    'dataMessageSend',...
                                                    @(src,event)feval(obj.callbackFcn,event.message));
            elseif nargin == 3
                obj.callbackFcn = varargin{3};
                obj.udpConnection = udp('','LocalPort',varargin{2},...
                                        'DatagramTerminateMode','on',...
                                        'InputBufferSize',4096);
                set(obj.udpConnection,'DatagramReceivedFcn',@(src,event)feval(obj.callbackFcn,fgetl(obj.udpConnection)));
                fopen(obj.udpConnection);
            end
        end
        
        function delete(obj)
            if ~isempty(obj.matlabListener)
                delete(obj.matlabListener);
            end
            if ~isempty(obj.udpConnection)
                fclose(obj.udpConnection);
                delete(obj.udpConnection);
            end
        end
    end
 
end

