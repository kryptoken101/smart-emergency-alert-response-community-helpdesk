 %% Configuration of Emergency Response Fleets 

 % Number of Ground Vehicles 
 nGV =0; 
 % Number of Fixed Wing Aircrafts 
 nFW =1; 
 % Number of Rotorcrafts 
 nRC =1; 
 % Number of AR.Drones 
 nAR =0; 
 % Number of Emergency Responder Persons 
 nPR =0; 


 % San Francisco Fire Department Geodetic Coordinates 
 SFFDLocation = [  37.80140000000;  -122.45571100000; 0] ; 


 % Local North-East Coordinates and Heading Angle 
 % All vehicles in a line and separated by 10 (m). 
 % All vehicles heading to the North (0 radians). 


 %% Fixed Vehicle Fleet 

 FWFleet.IC.geodetic = SFFDLocation;  
 FWFleet.IC.geodetic(3) = 100 ;  
 FWFleet.nFW = nFW; 
 N0 = 0; 
 dN = 10; %(m) 
 for k = 1:FWFleet.nFW 
 FWFleet.IC.posNED(:,k) = [N0 ; 0; -100]; % (m) 
 FWFleet.IC.heading(k) = 0;   % (rad)  
 N0 = N0 + dN;  
 end  


 %% Ground Vehicle Fleet 

 % All the ground vehicles departing from the same location. Heading is zero 
 % degrees with respect to the North. 
 GVFleet.IC.geodetic = SFFDLocation; 
 GVFleet.IC.geodetic(3) = 100 ;  
 GVFleet.nGV = nGV; 
 N0 = -10; 
 dN = 10; 
 for k = 1:GVFleet.nGV 
 GVFleet.IC.posNED(:,k) = [N0 ; 0; 0]; % (m) 
 GVFleet.IC.heading(k) = 0;   % (rad) 
 N0 = N0 - dN; 
 end 


 %% Rotorcraft Fleet 

 % All the rotorcraft vehicles departing from the same location. Heading is 
 % zero degrees with respect to the North. 
 RCFleet.IC.geodetic = SFFDLocation; 
 RCFleet.IC.geodetic(3) = 100 ;  
 RCFleet.nRC = nRC; 
 N0 = -10; 
 dN = 10; 
 for k = 1:RCFleet.nRC 
 RCFleet.IC.posNED(:,k) = [N0 ; 0; 0]; % (m) 
 RCFleet.IC.heading(k) = 0;   % (rad) 
 N0 = N0 - dN; 
 end 


 %% AR.Drone fleet 

 ARFleet.IC.geodetic = SFFDLocation; 
 ARFleet.IC.geodetic(3) = 100 ; 
 ARFleet.nAR = nAR; 
 N0 = 0;  
 dN = 10; %(m) 
 for k = 1:ARFleet.nAR 
 ARFleet.IC.posNED(:,k) = [N0 ; 0; -100]; % (m) 
 ARFleet.IC.heading(k) = 0;   % (rad) 
 N0 = N0 + dN; 
 end 


 %% Persons/props fleet 

 PRFleet.IC.geodetic = SFFDLocation;  
 PRFleet.IC.geodetic(3) = 100 ; 
 PRFleet.nPR = nPR; 
 N0 = 0; 
 dN = 10; %(m) 
 for k = 1:PRFleet.nPR 
 PRFleet.IC.posNED(:,k) = [N0 ; 0; -100]; % (m) 
 PRFleet.IC.heading(k) = 0;   % (rad) 
 N0 = N0 + dN; 
 end 


 %% Configuration of Google Earth fleet ports 
 GVFleet.gePort = 4012;  
 FWFleet.gePort = 4013; 
 RCFleet.gePort = 4014; 
 ARFleet.gePort = 4015; 
 PRFleet.gePort = 4016;  
 LAFleet.gePort = 4017; 
 CMFleet.gePort = 4018; 
 Settings.gePort = 4019; 


