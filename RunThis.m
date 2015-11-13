%% Workings of the Combined Lapsimulator for Formula SAE Combustion and Electric
% This is the Master.
% User inputs will mainly be inputted into SetupSheets.xlsx. Toggle which
% car to run through the Lap Simulator here. Dynamic event results as well
% as points will be outputted. 

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

Car = @()(CarBuilderSS('Combustion', rowNumber));
% Track = @FSG2013;
Track = @FSAEMichigan2015;

car = Car();
track = Track();

% [ RawResults,PointResults ] = RPMLimitingAnalysis( Car,Track );
Simulate( car, track )
% save('BatteryandRPMLimitingAnalysis')

% [Showmewhatyougot, RawResults] = ExcelSweep(Track,6,15,'Combustion');

% surf(Car.Chassis.Length,Car.Chassis.WF,

