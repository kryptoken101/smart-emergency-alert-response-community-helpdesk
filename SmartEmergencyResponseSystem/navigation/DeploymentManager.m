classdef DeploymentManager < handle
    properties (SetAccess = private)
        isDeployment    % Boolean vector indicating which nodes are deployment nodes
    end
    
    methods
        function addNodes(obj, newNodes)
            obj.isDeployment = [obj.isDeployment; logical(newNodes)];
        end
        
        function setDeploymentNode(obj, node)
            obj.isDeployment(node) = true;
            notify(obj,'deploymentsChanged')
        end
        
        function unsetDeploymentNode(obj, node)
            obj.isDeployment(node) = false;
            notify(obj,'deploymentsChanged')
        end
        
        function retval = getDeploymentNodes(obj)
            retval = find(obj.isDeployment);
        end
        
        function reset(obj)
            obj.isDeployment = false(size(obj.isDeployment));
            notify(obj,'deploymentsChanged')
        end
    end
    
    events
        deploymentsChanged
    end
end