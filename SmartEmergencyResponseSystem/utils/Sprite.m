classdef Sprite < handle
    %SPRITE Mobile graphical representation of an object 

    properties (Access = protected)
        transform   % hgtransform object
        imageData   % image object
        parentAxes  % Axes object containing the sprite
    end
       
    properties (Access = private)
        xlimListener
        ylimListener
        resizeListener
        axesScalingListener
        userScalingListener
        motionListener
        rotationListener
    end
    
    properties (SetObservable, Access = protected)
        axesScalingMatrix   % For keeping the icon properly scaled on zoom
        userScalingMatrix   % For keeping track of how the user want it scaled
        motionMatrix        % For keeping track of translations
        rotationMatrix      % For keeping track of rotations
    end
    
    properties (Dependent, Access = public)
        visible
    end
    
    methods
        function obj = Sprite(parentAxesIn, imageDataIn, varargin)
            obj.axesScalingMatrix = makehgtform;
            obj.userScalingMatrix = makehgtform;
            obj.motionMatrix =  makehgtform;
            obj.rotationMatrix = makehgtform;
            
            obj.parentAxes = parentAxesIn;
            obj.transform = hgtransform('parent',obj.parentAxes);
            
            obj.imageData = image('parent',obj.transform,...
                                  'CData',flipud(imageDataIn));
            if nargin > 2
                set(obj.imageData,'AlphaData',flipud(varargin{1}))
            end
            xdata = get(obj.imageData,'xdata');
            ydata = get(obj.imageData,'ydata');
            set(obj.imageData,'xdata',xdata-(xdata(1)+xdata(end))/2);
            set(obj.imageData,'ydata',ydata-(ydata(1)+ydata(end))/2);
            
            obj.xlimListener = addlistener(obj.parentAxes,'XLim','PostSet',@obj.updateScaling);
            obj.ylimListener = addlistener(obj.parentAxes,'YLim','PostSet',@obj.updateScaling);
            obj.axesScalingListener = addlistener(obj,'axesScalingMatrix','PostSet',@obj.redraw);
            obj.userScalingListener = addlistener(obj,'userScalingMatrix','PostSet',@obj.redraw);
            obj.motionListener = addlistener(obj,'motionMatrix','PostSet',@obj.redraw);
            obj.rotationListener = addlistener(obj,'rotationMatrix','PostSet',@obj.redraw);
            
            addlistener(getParentFigure(obj.transform),'SizeChange',@obj.updateScaling);

            obj.updateScaling([],[]);
        end
              
        function moveTo(obj, varargin)
            if nargin == 2
                x = varargin{1}(1);
                y = varargin{1}(2);
            elseif nargin == 3
                x = varargin{1};
                y = varargin{2};
            else
                error('Must take 1 or two arguments')
            end                
            M = makehgtform('translate',[x,y,0]);
            obj.motionMatrix = M;
        end
        
        function setAngle(obj, theta)
            M = makehgtform('zrotate',theta);
            obj.rotationMatrix = M;
        end
        
        function setScale(obj, factor)
            M = makehgtform('scale',factor);
            obj.userScalingMatrix = M;
        end
        
        function rotate(obj,theta)
            M = makehgtform('zrotate',theta);
            obj.rotationMatrix = M*obj.rotationMatrix;
        end
        
        function translate(obj, varargin)
            if nargin == 2
                x = varargin{1}(1);
                y = varargin{1}(2);
            elseif nargin == 3
                x = varargin{1};
                y = varargin{2};
            else
                error('Must take 1 or two arguments')
            end 
            M = makehgtform('translate',[x,y,0]);
            obj.motionMatrix = M*obj.motionMatrix;
        end
        
        function set.visible(obj, newValue)
            set(obj.transform,'visible',newValue);
        end
        
        function retval = get.visible(obj)
            retval = get(obj.transform,'visible');
        end
        
        function delete(obj)
            delete(obj.xlimListener);
            delete(obj.ylimListener);
            delete(obj.resizeListener);
            delete(obj.axesScalingListener);
            delete(obj.userScalingListener);
            delete(obj.motionListener);
            delete(obj.rotationListener);
            delete(obj.imageData);
        end
    end
    
    methods (Access = private)
        function redraw(obj,~,~)
            set(obj.transform,'Matrix',obj.motionMatrix * ...
                                       obj.userScalingMatrix * ...
                                       obj.axesScalingMatrix * ...
                                       obj.rotationMatrix);
        end
        
        function updateScaling(obj, ~, ~)
            [pixelsPerXDataUnit, pixelsPerYDataUnit] = obj.computeScaling;
            obj.axesScalingMatrix = [1/pixelsPerXDataUnit 0 0 0;...
                                     0 1/pixelsPerYDataUnit 0 0;...
                                     0 0                    1 0;...
                                     0 0                    0 1];
        end
        
        function [scaleX, scaleY] = computeScaling(obj)
            % Return value is in pixels per data unit
            tempUnits = get(obj.parentAxes,'Units');
            set(obj.parentAxes,'Units','pixels')
            axesSizeInPixels = get(obj.parentAxes,'position');
            scaleX = axesSizeInPixels(3)/diff(get(obj.parentAxes,'xlim'));
            scaleY = axesSizeInPixels(4)/diff(get(obj.parentAxes,'ylim'));
            set(obj.parentAxes,'Units',tempUnits);
        end
    end    
end

