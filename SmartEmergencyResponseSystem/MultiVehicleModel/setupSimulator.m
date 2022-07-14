%% =======================================================================
%  Script to setup a heterogeneous fleet of autonmous vehicles.  The
%  fleet consists of  fixed wing aircraft, rotorcraft, and ground vehicles.
%  
%  Fixed wing uninhabited aerial vehicles (UAV): Physics and control
%  systems based on the University of Minnesota UAV models. Guidance
%  algorithms are developed to track waypoints and execute mission plans. 
%
%  Rotorcraft: A quadrotor type UAV is used in the simulation. The Parrot 
%  ARDrone vehicle is simulated based on models derived via blackbox system
%  identification. Outer loop controllers are designed to track waypoints
%  and execute missions. 
%
%  Ground Vehicles: A simple point mass model of a ground vehicle is used.
%  Guidance algorithms are developed to track the desired position of the
%  vehicles. 


%% =======================================================================
%   Cleaning workspace

bdclose all;
%close all;


cd MultiVehicleModel
%% =======================================================================
% Simulation parameters
evalin('base','simPars.SampleTime = 0.02'); % sec


%% Configuration of fleets
%% Configuration of Google Earth fleet ports 
evalin( 'base',...
 'GVFleet.gePort = 4012; FWFleet.gePort = 4013; RCFleet.gePort = 4014; ARFleet.gePort = 4015; PRFleet.gePort = 4016; LAFleet.gePort = 4017; CMFleet.gePort = 4018; Settings.gePort = 4019'); 


if nGV <=0
 nGV =1; 
end
 
if nFW <=0
 nFW =1; 
end

if nRC <=0
 nRC =1; 
end

nAR = 0;
%% Number of waypoints to send via UDP
FWFleet.nWPs = 100; 
RCFleet.nWPs = 100; 
GVFleet.nWPs = 100; 





%%
% San Francisco Fire Department Geodetic Coordinates 
 SFFDLocation = [  37.77986111100;  -122.47091944400; 0] ; 


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
 dN = 30; 
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


%% =======================================================================
%  Setting up Fixed Wing UAV Fleet
%  Adding Fixed Wing UAV path
%addpath FixedWingUAV ;
%addpath FixedWingUAV/FLEET_Sim ; 
%addpath FixedWingUAV/Libraries ;
%addpath FixedWingUAV/Controllers ;
%addpath net; 
%addpath net/UDPReader; 
% change to UMN-UAV directory 
cd FixedWingUAV/FLEET_Sim ; 
% setting up the UMN-UAV fleet
setupFixedWingUAVFleet; 
% changing to base directory
cd ../../ ; 

%% =======================================================================
%  Setting up AR.Drone Fleet
%addpath ARDrone ;
%cd ARDrone;
setupARDrone ;
%cd ../ ; 


%% =======================================================================
%  Setting up Ground Vehicle Fleet
%addpath GroundVehicle ;
%cd ARDrone;
setupGV ;
%cd ../ ; 

%% =======================================================================
% Assign all values in the base workspace
% assignin('base','RCFleet',RCFleet);
% assignin('base','RCFleet',ARFleet);
% assignin('base','GVFleet',GVFleet);
% assignin('base','FWFleet',FWFleet);

%%
open_system('MultiVehicleModel');
set_param('MultiVehicleModel','SimulationCommand','start'); 
pause(5);
cd ../