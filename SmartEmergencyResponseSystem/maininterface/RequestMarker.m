classdef RequestMarker < handle
    %REQUESTMARKER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = private)
        request     % Instance of Request
        marker      % Line with a single point
        
        locationListener
        deliveryListener
        itemListener
        removeListener
    end
    
    methods
        function obj = RequestMarker(parentAxesIn,...
                                     requestIn)
            obj.request = requestIn;
            
            % Remember that x/y corresponds to lon/lat, not lat/lon.
            obj.marker = line('xdata',requestIn.location(2),...
                              'ydata',requestIn.location(1),...
                              'parent',parentAxesIn,...
                              'MarkerSize',7,...
                              'MarkerEdgeColor','r',...
                              'ButtonDownFcn',@obj.clickHandler);
                          
            obj.updateShape;
            obj.updateColor;
            obj.updatePosition(obj.request.location);
            obj.locationListener = addlistener(obj.request,'locationChanged',...
                            @(src,~)obj.updatePosition(src.location));
            obj.deliveryListener = addlistener(obj.request,'deliveryPickupChanged',...
                            @(~,~)obj.updateShape);
            obj.itemListener = addlistener(obj.request,'itemChanged',...
                            @(~,~)obj.updateColor);
            obj.removeListener = addlistener(obj.request,'beingDeleted',@(~,~)delete(obj));
        end
        
        function delete(obj)
            delete(obj.locationListener);
            delete(obj.deliveryListener);
            delete(obj.itemListener);
            delete(obj.marker);
            delete(obj.removeListener);
        end
    end
    
    methods (Access = private)        
        function clickHandler(obj,~,~)
            switch get(getParentFigure(obj.marker),'SelectionType')
                case 'normal'
                    obj.enableDragging
                case 'open'
                    RequestMenu.open(obj.request);
            end
        end
        
        function enableDragging(obj)
            set(getParentFigure(obj.marker),'WindowButtonMotionFcn',@(~,~)obj.drag);
            set(getParentFigure(obj.marker),'WindowButtonUpFcn',@(~,~)obj.disableDragging);
        end
        
        function drag(obj)
            currentPoint = get(get(obj.marker,'parent'),'CurrentPoint');
            % Remember that x/y corresponds to lon/lat, not lat/lon.
            obj.request.location = currentPoint([3,1]);
        end
        
        function disableDragging(obj)
            set(getParentFigure(obj.marker),'WindowButtonMotionFcn',[]);
        end
        
        function updatePosition(obj,location)
            % Remember that x/y corresponds to lon/lat, not lat/lon.
            set(obj.marker,'xdata',location(2));
            set(obj.marker,'ydata',location(1));
        end
        
        function updateShape(obj)
            if obj.request.isPickup
                markerShape = 'o';
            elseif obj.request.isDelivery
                markerShape = 's';
            else
                markerShape = '.';
            end
            set(obj.marker,'Marker',markerShape);
        end
        
        function updateColor(obj)
            set(obj.marker,'MarkerFaceColor',obj.request.item.color);
        end
    end    
end

