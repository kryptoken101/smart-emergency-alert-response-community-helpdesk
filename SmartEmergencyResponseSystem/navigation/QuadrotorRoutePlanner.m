classdef QuadrotorRoutePlanner < handle
    %% Class to calculate optimal assignments of quadrotor to request positions
   
    methods (Static)
        function [nodePaths, loadouts, exitflag] = planRoutes(requests, quadcopters, stationTrucks, timeout)
            exitflag = 0;       % No error
            
            locations = [[requests.latitude]',[requests.longitude]';...
                         [quadcopters.latitude]',[quadcopters.longitude]';...
                         [stationTrucks.latitude]',[stationTrucks.longitude]'];
            numNodes = size(locations,1);
            numRequests = numel(requests);
            numQuadcopters = numel(quadcopters);
            numStations = numel(stationTrucks);
            numItems = numel(ItemFactory.getCatalog);
            numVars = numNodes^2*(3*numQuadcopters+numItems)+1;
            
            distanceTable = squareform(pdist(locations));
            
            % Build f
            f = [zeros(numVars-1,1);1];
            
            % Build A and b
            [i0, j0, s0, b0] = type0constraints;
            [i2, j2, s2, b2] = type2constraints;
            [i5, j5, s5, b5] = type5constraints;
            [i7, j7, s7, b7] = type7constraints;
            [i8, j8, s8, b8] = type8constraints;
            [i10, j10, s10, b10] = type10constraints;
            [i12, j12, s12, b12] = type12constraints;
            [i13, j13, s13, b13] = type13constraints;
            iVec = [i0;
                    i2+max(i0);
                    i5+max(i0)+max(i2);
                    i7+max(i0)+max(i2)+max(i5);
                    i8+max(i0)+max(i2)+max(i5)+max(i7);
                    i10+max(i0)+max(i2)+max(i5)+max(i7)+max(i8);
                    i12+max(i0)+max(i2)+max(i5)+max(i7)+max(i8)+max(i10);
                    i13+max(i0)+max(i2)+max(i5)+max(i7)+max(i8)+max(i10)+max(i12)];
            A = sparse(iVec,[j0;j2;j5;j7;j8;j10;j12;j13],[s0;s2;s5;s7;s8;s10;s12;s13],max(iVec),numVars);
            b = [b0;b2;b5;b7;b8;b10;b12;b13];
            
            % Build Aeq and beq
            [i1, j1, s1, b1] = type1constraints;
            [i3, j3, s3, b3] = type3constraints;
            [i4, j4, s4, b4] = type4constraints;
            [i6, j6, s6, b6] = type6constraints;
            [i9, j9, s9, b9] = type9constraints;
            [i11, j11, s11, b11] = type11constraints;
            iVec = [i1;
                    i3+max(i1);
                    i4+max(i1)+max(i3);
                    i6+max(i1)+max(i3)+max(i4);
                    i9+max(i1)+max(i3)+max(i4)+max(i6);
                    i11+max(i1)+max(i3)+max(i4)+max(i6)+max(i9)];
            Aeq = sparse(iVec,[j1;j3;j4;j6;j9;j11],[s1;s3;s4;s6;s9;s11],max(iVec),numVars);
            beq = [b1;b3;b4;b6;b9;b11];
            
            % Build lb
            lb = zeros(numVars,1);
            
            % Build ub
            ub = [ones(numNodes^2*numQuadcopters,1);Inf(numNodes^2*(numItems+2*numQuadcopters),1);Inf];
            % Eliminate trivial arcs
            [columns,rows] = meshgrid(1:numNodes^2:(numVars-1),1:(numNodes+1):numNodes^2);
            ub(columns+rows-1) = 0;
            % Starting locations of quadcopters are not valid destinations
            ub(x(1:numNodes,numRequests+(1:numQuadcopters),1:numQuadcopters)) = 0;  
            % No quadcopter may depart from another quadcopter's starting position
            for h = 1:numQuadcopters
                ub(x(numRequests+h,1:numNodes,[1:h-1 h+1:numQuadcopters])) = 0;
            end
            % Pay the battery cost for departing stations and starting points
            for h = 1:numQuadcopters
                ub(z(numRequests+numQuadcopters+(1:numStations),1:numNodes,h)) = ...
                    reshape(1-distanceTable(numRequests+numQuadcopters+(1:numStations),1:numNodes)./QuadCopter.maxRange,numStations*numNodes,1);
                ub(z(numRequests+h,1:numNodes,h)) = ...
                    repmat(quadcopters(h).battery,1,numNodes)-distanceTable(numRequests+h,1:numNodes)./QuadCopter.maxRange;
            end
            % The first step is constrained by cargo
            for h = 1:numQuadcopters
                cargo = smartAccumarray(lookupItemIndex(quadcopters(h).cargo),1,[numItems,1]);
                for r = 1:numRequests
                    if requests(r).isDelivery && cargo(lookupItemIndex(requests(r).item)) < requests(r).quantity || ...
                            ~requests(r).isDelivery && sum([quadcopters(h).cargo.weight]) + requests(r).item.weight*requests(r).quantity > QuadCopter.capacity
                        ub(x(numRequests+h,r,h)) = 0;
                    end
                end
            end
            
            
            opts = optimoptions('intlinprog','display','iter',...
                                             'MaxTime',timeout);
            solution = intlinprog(f,1:numNodes^2*numQuadcopters,A,b,Aeq,beq,lb,ub,opts);
            
            if isempty(solution)
                save('wtf.mat','A','b','Aeq','beq','f','lb','ub','distanceTable');
                nodePaths = cell(0);
                loadouts = cell(0);
                exitflag = 1;  % No feasible route found
            else
                %intcon = numNodes^2*numQuadcopters;
                %save('problem.mat','A','b','Aeq','beq','f','lb','ub','distanceTable','intcon','locations','numNodes','numQuadcopters','numRequests');
                nodePaths = cell(1,numQuadcopters);
                loadouts = cell(1,numQuadcopters);
                for quadcopter = 1:numQuadcopters
                    nodePaths{quadcopter} = eulerianPath(round(reshape(solution((quadcopter-1)*numNodes^2+(1:numNodes^2)),numNodes,numNodes)),numRequests+quadcopter);
                    if all(nodePaths{quadcopter} > numRequests)  % If no requests are serviced...
                        nodePaths{quadcopter} = nodePaths{quadcopter}(1:2);  % only keep the initial location and first destination
                    end
                    loadouts{quadcopter} = cell(1,numel(nodePaths{quadcopter})-1);
                    for ii = 1:numel(nodePaths{quadcopter})-1
                        loadouts{quadcopter}{ii} = generateLoadout(nodePaths{quadcopter}(ii),nodePaths{quadcopter}(ii+1));
                    end
                end
            end

%======================== Constraint functions ============================

            function [i,j,s,b] = type0constraints
                i = zeros(numNodes*numQuadcopters,1);
                j = zeros(numNodes*numQuadcopters,1);
                s = zeros(numNodes*numQuadcopters,1);
                b = ones(numQuadcopters,1);
                idx = 1:numNodes;
                
                for h = 1:numQuadcopters
                    i(idx) = ones(numNodes,1)*h;
                    j(idx) = x(numRequests+h,1:numNodes,h);
                    s(idx) = ones(numNodes,1);
                    idx = idx + numNodes;
                end
            end
            
            function [i,j,s,b] = type1constraints
                i = zeros(numNodes*numItems*numQuadcopters*2,1);
                j = zeros(numNodes*numItems*numQuadcopters*2,1);
                s = zeros(numNodes*numItems*numQuadcopters*2,1);
                b = zeros(numNodes*numItems*numQuadcopters,1);
                idx = 1:numNodes*numItems*2;
                
                for h = 1:numQuadcopters
                    i(idx) = [1:numNodes*numItems 1:numNodes*numItems]'+(h-1)*numNodes*numItems;
                    j(idx) = [q(numRequests+h,1:numNodes,1:numItems);repmat(x(numRequests+h,1:numNodes,h),numItems,1)];
                    s(idx) = [ones(numNodes*numItems,1); -kron(smartAccumarray(lookupItemIndex(quadcopters(h).cargo),1,[numItems,1]),ones(numNodes,1))];     
                    idx = idx + numNodes*numItems*2;
                end
            end
            
            function [i,j,s,b] = type2constraints
                i = kron((1:numNodes^2)',ones(numQuadcopters,1));
                j = kron(ones(numNodes^2,1),(0:numNodes^2:(numQuadcopters-1)*numNodes^2)')+i;
                s = ones(size(i));
                b = ones(numNodes^2, 1);
            end
            
            function [i,j,s,b] = type3constraints
                catalog = ItemFactory.getCatalog;
                
                i = zeros(2*numNodes*numItems*numRequests,1);
                j = zeros(2*numNodes*numItems*numRequests,1);
                s = zeros(2*numNodes*numItems*numRequests,1);
                b = zeros(numItems*numRequests,1);
                idx = 1:2*numNodes;
                iter = 1;
                
                for r = 1:numRequests
                    for c = 1:numItems
                        i(idx) = ones(2*numNodes,1) * iter;
                        j(idx) = [(r-1)*numNodes+(1:numNodes)';
                                  (r-1)+(1:numNodes:numNodes^2)'] + (numQuadcopters + c-1)*numNodes^2;
                        s(idx) = kron([1;-1],ones(numNodes,1));
                        
                        b(iter) = ...
                            strcmp(requests(r).item.name, catalog{c}) * ...
                            requests(r).quantity * ...
                            (2*requests(r).isDelivery - 1); % + for delivery, - for pickup

                        idx = idx + 2*numNodes;
                        iter = iter + 1;
                    end
                end
            end
            
            function [i,j,s,b] = type4constraints
                i = zeros(numRequests*numQuadcopters*numNodes,1);
                j = zeros(numRequests*numQuadcopters*numNodes,1);
                s = zeros(numRequests*numQuadcopters*numNodes,1);
                b = zeros(numRequests,1);
                idx = 1:numQuadcopters*numNodes;
                
                for r = 1:numRequests
                    i(idx) = ones(numQuadcopters*numNodes,1)*r;
                    j(idx) = x(r,1:numNodes,1:numQuadcopters);
                    s(idx) = ones(size(idx));
                    b(r) = 1;
                    idx = idx + numQuadcopters*numNodes;
                end
            end
            
            function [i,j,s,b] = type5constraints
                tbl = ItemFactory.itemTable; %g835097
                weights = [tbl.weight]';
                capacities = repmat(QuadCopter.capacity,numQuadcopters,1);
                
                i = zeros((numItems+numQuadcopters)*numNodes^2,1);
                j = zeros((numItems+numQuadcopters)*numNodes^2,1);
                s = zeros((numItems+numQuadcopters)*numNodes^2,1);
                b = zeros(numNodes^2,1);
                idx = 1:(numItems + numQuadcopters);
                iter = 1;
                
                for v = 1:numNodes
                    for w = 1:numNodes
                        i(idx) = ones(numItems + numQuadcopters,1)*iter;
                        j(idx) = [q(v,w,1:numItems);x(v,w,1:numQuadcopters)];
                        s(idx) = [weights; -capacities];
                        idx = idx + numItems + numQuadcopters;
                        iter = iter + 1;
                    end
                end
            end
            
            function [i,j,s,b] = type6constraints
                i = zeros(numRequests*numQuadcopters*2*numNodes,1);
                j = zeros(numRequests*numQuadcopters*2*numNodes,1);
                s = zeros(numRequests*numQuadcopters*2*numNodes,1);
                b = zeros(numRequests*numQuadcopters,1);
                idx = 1:2*numNodes;
                iter = 1;
                
                for r = 1:numRequests
                    for h = 1:numQuadcopters
                        i(idx) = ones(2*numNodes,1)*iter;
                        j(idx) = [x(1:numNodes,r,h);x(r,1:numNodes,h)];
                        s(idx) = [-ones(numNodes,1);ones(numNodes,1)];
                        idx = idx + 2*numNodes;
                        iter = iter + 1;
                    end
                end
            end
            
            function [i,j,s,b] = type7constraints
                i = zeros(numStations*numQuadcopters*2*numNodes,1);
                j = zeros(numStations*numQuadcopters*2*numNodes,1);
                s = zeros(numStations*numQuadcopters*2*numNodes,1);
                b = zeros(numStations*numQuadcopters,1);
                iter = 1;
                
                for r = numRequests + numQuadcopters + (1:numStations)
                    for h = 1:numQuadcopters
                        i = ones(2*numNodes,1)*iter;
                        j = [x(1:numNodes,r,h);x(r,1:numNodes,h)];
                        s = [-ones(numNodes,1);ones(numNodes,1)];
                        iter = iter + 1;
                    end
                end                
            end
            
            function [i,j,s,b] = type8constraints
                i = kron([1;1],(1:numNodes^2*numQuadcopters)');
                j = [x(1:numNodes,1:numNodes,1:numQuadcopters);
                     z(1:numNodes,1:numNodes,1:numQuadcopters)];
                s = kron([-1;1],ones(numNodes^2*numQuadcopters,1));  % [-maxcharge;1]
                b = zeros(numNodes^2*numQuadcopters,1);
            end
            
            function [i,j,s,b] = type9constraints
                i = zeros(numRequests*numQuadcopters*numNodes*3,1);
                j = zeros(numRequests*numQuadcopters*numNodes*3,1);
                s = zeros(numRequests*numQuadcopters*numNodes*3,1);
                b = zeros(numRequests*numQuadcopters,1);
                idx = 1:numNodes*3;
                iter = 1;
                
                for r = 1:numRequests
                    for h = 1:numQuadcopters
                        i(idx) = ones(numNodes*3,1)*iter;
                        j(idx) = [z(1:numNodes,r,h);z(r,1:numNodes,h);x(r,1:numNodes,h)];
                        s(idx) = [-ones(numNodes,1);ones(numNodes,1);distanceTable(:,r)./QuadCopter.maxRange];
                        idx = idx + numNodes*3;
                        iter = iter + 1;
                    end
                end
            end
            
            function [i,j,s,b] = type10constraints
                i = repmat(1:numNodes^2*numQuadcopters,1,2)';
                j = [t(1:numNodes,1:numNodes,1:numQuadcopters);x(1:numNodes,1:numNodes,1:numQuadcopters)];
                s = kron([1;-(2*numRequests+numStations)],ones(numNodes^2*numQuadcopters,1));
                b = zeros(numNodes^2*numQuadcopters,1);
            end
            
            function [i,j,s,b] = type11constraints
                i = zeros((numRequests+numStations)*numNodes*numQuadcopters*3,1);
                j = zeros((numRequests+numStations)*numNodes*numQuadcopters*3,1);
                s = zeros((numRequests+numStations)*numNodes*numQuadcopters*3,1);
                b = zeros((numRequests+numStations)*numQuadcopters,1);
                idx = 1:numNodes*3;
                iter = 1;
                
                for r = [1:numRequests numRequests+numQuadcopters+(1:numStations)]
                    for h = 1:numQuadcopters
                        i(idx) = ones(numNodes*3,1)*iter;
                        j(idx) = [t(1:numNodes,r,h);t(r,1:numNodes,h);x(r,1:numNodes,h)];
                        s(idx) = [-ones(numNodes,1);ones(numNodes,1);ones(numNodes,1)];
                        idx = idx + numNodes*3;
                        iter = iter + 1;
                    end
                end                
            end
            
            function [i,j,s,b] = type12constraints
                i = [kron((1:numQuadcopters)',ones(numNodes^2,1));
                     (1:numQuadcopters)'];
                j = [x(1:numNodes,1:numNodes,1:numQuadcopters);
                     ones(numQuadcopters,1)*numVars];
                s = [kron(ones(numQuadcopters,1),distanceTable(:));
                     -ones(numQuadcopters,1)];
                b = zeros(numQuadcopters,1);
            end
            
            function [i,j,s,b] = type13constraints
                i = ones(numNodes*numQuadcopters,1);
                j = zeros(numNodes*numQuadcopters,1);
                s = -ones(numNodes*numQuadcopters,1);
                b = -ones(numQuadcopters,1);
                idx = 1:numNodes;
                
                for h = 1:numQuadcopters
                    i(idx) = h*ones(numNodes,1);
                    j(idx) = x(numRequests+h,1:numNodes,h);
                    idx = idx + numNodes;
                end
            end
            
            function retval = x(v1,v2,h)
                [v,w] = meshgrid(v1,v2);
                retval = repmat((h(:)-1)*numNodes^2,1,numel(v1)*numel(v2)) + ...
                    repmat(sub2ind([numNodes,numNodes],v(:),w(:))',numel(h),1);
                retval = sort(retval(:));
            end
            
            function retval = q(v1,v2,c)
                [v,w] = meshgrid(v1,v2);
                retval = repmat((c(:)-1)*numNodes^2,1,numel(v1)*numel(v2)) + ...
                    repmat(sub2ind([numNodes,numNodes],v(:),w(:))',numel(c),1);
                retval = sort(retval(:) + numQuadcopters*numNodes^2);
            end
            
            function retval = z(v1,v2,h)
                [v,w] = meshgrid(v1,v2);
                retval = repmat(sub2ind([numNodes,numNodes],v(:),w(:))',numel(h),1) + ...
                    repmat((numQuadcopters+numItems+h(:)-1)*numNodes^2,1,numel(v1)*numel(v2));
                retval = sort(retval(:));
            end
            
            function retval = t(v1,v2,h)
                [v,w] = meshgrid(v1,v2);
                retval = repmat(h(:)*numNodes^2,1,numel(v1)*numel(v2))+ ...
                    repmat(sub2ind([numNodes,numNodes],v(:),w(:))',numel(h),1);
                retval = sort(retval(:) + (2*numQuadcopters+numItems-1)*numNodes^2);
            end
            
%========================== Utility Functions =============================            
            function retval = lookupItemIndex(item)
                retval = zeros(numel(item),1);
                for ii = 1:numel(item)
                    retval(ii) = find(strcmp(item(ii).name,ItemFactory.getCatalog));
                end
            end
            
            function retval = smartAccumarray(idx,val,sz)
                if isempty(idx)
                    retval = zeros(sz);
                else
                    retval = accumarray(idx,val,sz);
                end
            end
            
            function retval = generateLoadout(v1,v2)
                retval = ItemFactory.makeItem('empty');
                catalog = ItemFactory.getCatalog;
                for ii2 = 1:numItems
                    quantity = solution((numQuadcopters+ii2-1)*numNodes^2+sub2ind([numNodes,numNodes],v1,v2));
                    if quantity > 0
                        retval = [retval repmat(ItemFactory.makeItem(catalog{ii2}),1,round(quantity))];
                    end
                end
            end
        end
        
    end
end