
% 11, 13, 15, 18, 19, 20, 21
rng(18);
scale = 1;

theaterx = [-122.4599,-122.3775]*scale;
theatery = [37.7735,37.8118]*scale;

planner = QuadrotorRoutePlanner;

% Make up requests
for ii=1:15
    reqs(ii) = randomRequest;
end
% reqs(1) = Request([-.03,.03]*scale,ItemFactory.makeItem('Defibrillator'),'Me',1,now,now,1,true,false);
% reqs(2) = Request([.03,.03]*scale,ItemFactory.makeItem('Defibrillator'),'Me',1,now,now,1,true,false);
% reqs(3) = randomRequest;
% reqs(4) = randomRequest;
% reqs(5) = randomRequest;

% Make up vehicles
trucks(1) = GroundVehicle(10,randomPoint(theaterx,theatery),0,[0 0]);
trucks(2) = GroundVehicle(11,randomPoint(theaterx,theatery),0,[0 0]);

% Make up quadcopters
copters(1) = QuadCopter(10,randomPoint(theaterx,theatery)*scale);
copters(2) = QuadCopter(11,randomPoint(theaterx,theatery)*scale);

% Draw the starting config
ax = axes('xlim',theaterx,'ylim',theatery);
for truck = trucks
    DeploymentTruckSprite(ax,truck);
end
for req = reqs
    RequestMarker(ax,req);
end
for copter = copters
    QuadCopterSprite(ax,copter);
end

drawnow

% Plan the routes
planner = planner.planRoutes(reqs,copters,trucks);

for ii = 1:numel(planner.optimalRoutes)
    route = planner.optimalRoutes{ii};
    line('parent',ax,'xdata',route(:,2),'ydata',route(:,1),'color',rand(1,3));
end

