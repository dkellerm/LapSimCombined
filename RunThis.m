%% Workings of the Combined Lapsimulator for Formula SAE Combustion and Electric
% This is the Master.
% User inputs will mainly be inputted into SetupSheets.xlsx. Toggle which
% car to run through the Lap Simulator here. Dynamic event results as well
% as points will be outputted. 
% 
% clear all
% clc 

% winopen('SetupSheets.xlsx'); %Make sure to save excel before running, you can leave it open
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%%%%%%%%%
%%%%%%%%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%%%%%%%%%
%setup = input(' Combustion or Electric? ','s');
% setup = 'Combustion';
% setup = 'Electric';
%%%%%%%%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%%%%%%%%%
%%%%%%%%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Car = CarBuilder();
%tabName = input(' Combustion or Electric? ','s');
rowNumber = 6;

Car = @()(CarBuilderSS('Electric', rowNumber));
% Track = @FSAEMichigan2015;
Track = @FSG2013;

car = Car();
track = Track();

% [ RawResults,PointResults ] = RPMLimitingAnalysis( Car,Track );
Simulate( car, track )
% save('BatteryandRPMLimitingAnalysis')

% [Results, RawResults] = ExcelSweep(Track,rowNumber,6,'Combustion');

% scatter3(Results(:,6),Results(:,7),Results(:,1))
% surf(Results(:,6),Results(:,7),Results(:,1))
% mesh(Results(:,6),Results(:,7),Results(:,1))
% waterfall(Results(:,6),Results(:,7),Results(:,1))
% plot3(Results(:,6),Results(:,7),Results(:,1))
% Trend = cat(3,Results(:,6),Results(:,7),Results(:,1));
% Z = griddata(Results(:,6),Results(:,7),Results(:,1),x,y);
% x = min(length(Results(:,1))):0.1:length(Results(:,1));
% y = min(length(Results(:,2))):0.1:length(Results(:,2));
% Z = griddata(Results(:,6),Results(:,7),Results(:,1),x,y);

% Cd = Results(:,6);
% Cl = Results(:,7);
% timed = Results(:,1);
% 
% X = reshape(Cd,4,4)';
% Y = reshape(Cl,4,4)';
% Z = reshape(timed,4,4)';
% % 
% figure
% surf(X,Y,Z)
% xlabel('Cd')
% ylabel('Cl')
% zlabel('Lap Time [s]')
