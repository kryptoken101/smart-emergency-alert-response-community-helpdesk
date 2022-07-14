classdef TransitGraphNodeOverlay < handle
    %% Visual representation of a GroundTransportationGraph for main UI
    properties (Access = public)
        nodeRadius = 5;
    end
    
    properties (Access = private)
        parentFigure
        parentAxes
        
        nodeDots            % The actual dots on the screen
        nodeDotsVisible     % boolean
        deploymentDots      % The dots corresponding to deployment nodes                          
        deploymentDotsVisible % boolean
        
        deploymentMgr       % Object to keep track of which nodes are deployment nodes
        nodeLocations       % Object to keep track of where the nodes are
    end
    
    methods
        function obj = TransitGraphNodeOverlay(parentAxesIn, nodeLocationsIn, deploymentMgrIn)
            obj.deploymentMgr = deploymentMgrIn;
            obj.nodeLocations = nodeLocationsIn;
            obj.parentAxes = parentAxesIn;
            obj.parentFigure = get(obj.parentAxes,'parent');

            obj.nodeDots = line('xdata',[],'ydata',[],... % The actual dots on the screen
                                'parent',obj.parentAxes,...
                                'linestyle','none',...
                                'marker','.',...
                                'markerfacecolor','b',...
                                'markeredgecolor','b',...
                                'markersize',25);
            obj.deploymentDots = line('xdata',[],'ydata',[],...
                                      'parent',obj.parentAxes,...
                                      'linestyle','none',...
                                      'marker','s',...
                                      'markerfacecolor','r',...
                                      'markeredgecolor','r',...
                                      'markersize',9);
            obj.nodeDotsVisible = false;
            obj.deploymentDotsVisible = false;
            obj.refreshDots();
            
            addlistener(obj.deploymentMgr,'deploymentsChanged',@(~,~)obj.refreshDots);
        end
        
        function retval = whichNodeWasClicked(obj)
            clickedPoint = get(obj.parentAxes,'CurrentPoint');
            retval = obj.nodeLocations.getNearestNode(clickedPoint(1,2),clickedPoint(1,1));
        end
        
        function refreshDots(obj)
            deploymentNodes = logical(obj.deploymentMgr.isDeployment);
            plainNodes = true(size(deploymentNodes));
            
            if obj.deploymentDotsVisible
                set(obj.deploymentDots,'xdata',obj.nodeLocations.nodeLocations(deploymentNodes,2),...
                                       'ydata',obj.nodeLocations.nodeLocations(deploymentNodes,1));
                plainNodes = plainNodes & ~deploymentNodes;
            else
                set(obj.deploymentDots,'xdata',[],...
                                       'ydata',[]);
            end
            
            if obj.nodeDotsVisible
                set(obj.nodeDots,'xdata',obj.nodeLocations.nodeLocations(plainNodes,2),...
                                 'ydata',obj.nodeLocations.nodeLocations(plainNodes,1));
            else
                set(obj.nodeDots,'xdata',[],...
                                 'ydata',[]);
            end
        end
        
        function showNodes(obj)
            obj.nodeDotsVisible = true;
            obj.refreshDots;
        end
        
        function unshowNodes(obj)
            obj.nodeDotsVisible = false;
            obj.refreshDots;            
        end
        
        function showDeployments(obj)
            obj.deploymentDotsVisible = true;
            obj.refreshDots;
        end
        
        function unshowDeployments(obj)
            obj.deploymentDotsVisible = false;
            obj.refreshDots;            
        end
        
        function enableDeploymentSelection(obj)
            set(obj.nodeDots,'ButtonDownFcn',@obj.setAsDeploymentSelection);
        end
        
        function disableDeploymentSelection(obj)
            set(obj.nodeDots,'ButtonDownFcn',[]);
        end
    end
    
    methods (Access = private)
        function setAsDeploymentSelection(obj,~,~)
            pointClicked = get(gca,'CurrentPoint');
            node = obj.nodeLocations.getNearestNode(pointClicked(1,2),pointClicked(1,1));
            obj.deploymentMgr.setDeploymentNode(node);
        end
    end    
end

