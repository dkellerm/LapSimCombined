%% Workings of the Combined Lapsimulator for Formula SAE Combustion and Electric
% This is the Master

clear all
clc

% setup = 'Combustion';
setup = 'Electric';

Car = CarBuilderSS(setup);
Track = FSG2013;

% [ RawResults,PointResults ] = RPMLimitingAnalysis( Car,Track );
Simulate( Car,Track )
save('BatteryandRPMLimitingAnalysis')
