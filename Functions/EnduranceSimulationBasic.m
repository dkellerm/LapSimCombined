function [ Energy, Time, TF ] = EnduranceSimulationBasic( Car,Track,EnduranceLength)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

track = Track();
TF = 1;
TFDecrement = .1;

Laps = EnduranceLength/track.Length;

while true
    Car.Driveline.SetTorqueFactor(TF);
    Tele = Simulate(Car, track);
    
    FirstLapP = Tele.LapData(1:track.Length,8)*0.000112985;
    FirstLapT = Tele.LapData(1:track.Length,11);
    FirstLapE = sum(FirstLapP.*FirstLapT)/3600;
    FirstLapT = sum(FirstLapT);
    
    SecondLapP = Tele.LapData(track.Length+1:end,8)*0.000112985;
    SecondLapT = Tele.LapData(track.Length+1:end,11);
    SecondLapE = sum(SecondLapP.*SecondLapT)/3600;
    SecondLapT = sum(FirstLapT);
    
    Energy = FirstLapE + SecondLapE*(Laps-1);
    Time = FirstLapT + SecondLapT*(Laps-1);
    
    Error = Car.Battery.Capacity - Energy;
    
    if abs(Error) < Car.Battery.Capacity/50
        break;
    end
    
    TF = TF - TFDecrement;
end

