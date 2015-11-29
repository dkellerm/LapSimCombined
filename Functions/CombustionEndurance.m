function [ fuelUsed, Time, RPMLimit, Tele ] = CombustionEndurance( Car,Track )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

EnduranceLength = 866142; % 22km in inches
track = Track();
Laps = EnduranceLength/track.Length;
fuelStep = 0; %initiliaze [L/s]
Time = 0;
RPMLimit = 0;
Tele = Simulate(Car, track);

for i = 1:track.Sections
     if track.Track(1,i).Radius > 0
         fuelStep(end+1) = car.Battery.fuel_corner;
     end
     if track.Track(1,i).Radius == 0
         fuelStep(end+1) = car.Motor.OutputCurve(i,3);
     end
end
    fuelUsed = sum(fuelStep)*Results(1,1);
end