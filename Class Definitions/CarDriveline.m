classdef CarDriveline < handle
    %UNTITLED4 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        GearRatio
        Efficiency
        Weight
        EffectiveCG
        SprungMass
        UnsprungMass
        J
        PrimaryGear
        FinalDrive
        tabName
        Tmult
        Name = '';
    end
    methods
        function D = CarDriveline(GearRatio,Efficiency,SprungM,UnsprungM,CG,J,PrimaryGear,FinalDrive,Tmult,tabName)
            D.GearRatio = GearRatio;
            D.Efficiency = Efficiency;
            D.Weight = SprungM + sum(UnsprungM);
            D.EffectiveCG = CG;
            D.SprungMass = SprungM;
            D.UnsprungMass = UnsprungM;
            D.J = J;
            D.PrimaryGear = PrimaryGear;
            D.FinalDrive = FinalDrive;
            D.Tmult = Tmult; 
            D.tabName = tabName;
        end
                function [MotorRPM,Efficiency] = DriveTransfer(D,RoadSpeed,TireRadius)
                    switch D.tabName
                        
                        case 'Electric'
                    Efficiency = D.Efficiency;
                    MotorRPM = RoadSpeed/TireRadius*D.GearRatio;
                        
                        case 'Combustion'
                             Efficiency = D.Efficiency;
                    MotorRPM = RoadSpeed/TireRadius*D.GearRatio*D.PrimaryGear*D.FinalDrive*D.Tmult;
                    end
                end

    end
 end


