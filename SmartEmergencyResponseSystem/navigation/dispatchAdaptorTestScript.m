%%
rng(1);
[nodes, graph, deployment] = loadNodeDataFromMapFile('SanFrancisco.map');
theaterx = [-122.4599,-122.3775];
theatery = [37.7735,37.8118];

gvmgr = GroundVehicleManager(nodes);
qcmgr = QuadCopterManager;
rqmgr = RequestManager;

planner = QuadrotorOptimizationDispatchAdaptor('127.0.0.1',10005,10004,rqmgr,qcmgr,gvmgr);

for ii = 1:5
    randomRequest(theaterx,theatery,rqmgr);
end
for ii = 1:2
    gvmgr.addVehicle(randi(size(nodes.nodeLocations,1)));
end
for ii = 1:2
    qcmgr.addVehicle(randomPoint(theaterx,theatery));
end
% Draw starting config
ax = axes('xlim',theaterx,'ylim',theatery);
overlay = QuadCopterRouteOverlay(ax,qcmgr,true);
for truck = gvmgr.getVehicles
    DeploymentTruckSprite(ax,truck);
end
for req = rqmgr.getRequests
    RequestMarker(ax,req);
end
for copter = qcmgr.getVehicles
    QuadCopterSprite(ax,copter);
end

% Plan the routes
planner.optimize(1);


%%
y = QuadrotorOptimizationReceiptAdaptor('127.0.0.1',10030,10020)