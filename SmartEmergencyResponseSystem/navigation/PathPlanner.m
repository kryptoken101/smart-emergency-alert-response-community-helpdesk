classdef PathPlanner < handle
    %% Class to calculate optimal assignments of ground vehicles to deployment points
    properties (SetAccess = private)
        optimalRoutes
    end

    methods
        function obj = planRoutes(obj, graph, deploymentMgr, vehicles)
            deployNodes = deploymentMgr.getDeploymentNodes;
            vehicleNodes = zeros(numel(vehicles),1);
            for ii = 1:numel(vehicles)
                vehicleNodes(ii) = vehicles(ii).nearestNode;
            end
            
            distanceMatrix = graph.getDistance(deployNodes,vehicleNodes);
            
            if numel(deployNodes) > numel(vehicles)
                warning('Not enough ground vehicles')
                distanceMatrix(numel(deployNodes),numel(deployNodes)) = 0;  % Extend the matrix to be square
            elseif numel(vehicles) > numel(deployNodes)
                warning('Some vehicles may not be used')
                distanceMatrix(numel(vehicles),numel(vehicles)) = 0;    % Extend the matrix to be square
            end
            
            n = size(distanceMatrix,1);
            options = optimoptions('intlinprog','display','none');
            assignment = intlinprog(distanceMatrix(:),...    % Minimize total distance
                                    1:n^2,...  % Every variable must be an integer
                                    [], [],...  % No inequality constraints
                                    [kron(eye(n),ones(1,n));kron(ones(1,n),eye(n))],...  % Row and column sums...
                                    ones(2*n,1),...                                     % ... must be one
                                    zeros(n^2,1),...      % Every entry is positive...
                                    ones(n^2,1),...       % ... and bounded by 1.
                                    options);
            assignment = reshape(assignment, n, n);
            
            obj.optimalRoutes = cell(1,numel(vehicles));
            for ii = 1:numel(vehicles)
                destinationIndex = find(assignment(:,ii));
                if destinationIndex <= numel(deployNodes)
                    obj.optimalRoutes{ii} = graph.getShortestPath(...
                                                vehicleNodes(ii),...
                                                deployNodes(destinationIndex));
                else
                    obj.optimalRoutes{ii} = vehicleNodes(ii);   % If not assigned to a deployment, stand still
                end
                vehicles(ii).setRoute(obj.optimalRoutes{ii}(:));
            end
        end
    end
end