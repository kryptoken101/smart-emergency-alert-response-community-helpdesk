function planner = problemGenerator
% 5:18, 5:53, 5:88
% 10:53 10:88 10:26 10:195
rng(88);
scale = 1;

theaterx = [-122.4599,-122.3775]*scale;
theatery = [37.7735,37.8118]*scale;

planner = QuadrotorRoutePlanner;

% Make up requests
for ii=1:10
    reqs(ii) = randomRequest;
end
% reqs(1) = Request([-.03,.03]*scale,ItemFactory.makeItem('Defibrillator'),'Me',1,now,now,1,true,false);
% reqs(2) = Request([.03,.03]*scale,ItemFactory.makeItem('Defibrillator'),'Me',1,now,now,1,true,false);
% reqs(3) = randomRequest;
% reqs(4) = randomRequest;
% reqs(5) = randomRequest;

% Make up vehicles
trucks(1) = GroundVehicle(10,randomPoint,0,[0 0]);
trucks(2) = GroundVehicle(11,randomPoint,0,[0 0]);

% Make up quadcopters
copters(1) = QuadCopter(10,randomPoint*scale);
copters(2) = QuadCopter(11,randomPoint*scale);

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
tic;
planner = planner.planRoutes(reqs,copters,trucks);
toc

for ii = 1:numel(planner.optimalRoutes)
    route = planner.optimalRoutes{ii};
    line('parent',ax,'xdata',route(:,2),'ydata',route(:,1),'color',rand(1,3));
end

    function retval = randomRequest
        catalog = ItemFactory.getCatalog;
        isDelivery = (rand < .5)
        retval = Request(randi(intmax),...
                         randomPoint,...
                         ItemFactory.makeItem(catalog(randi(numel(catalog)))),...
                         'Me',...
                         1,...
                         now,...
                         now,...
                         randi(2),...
                         isDelivery,...
                         ~isDelivery);
        retval.item
        retval.quantity
    end

    function retval = randomPoint
        retval = rand(1,2).*[diff(theaterx),diff(theatery)]+[theaterx(1) theatery(1)];
        retval = fliplr(retval);
    end
end