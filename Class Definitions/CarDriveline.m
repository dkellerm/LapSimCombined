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
        DrivetrainType
        Tmult
        Name = '';
    end
    methods
        function D = CarDriveline(GearRatio,Efficiency,SprungM,UnsprungM,CG,J,PrimaryGear,FinalDrive,Tmult,DrivetrainType)
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
            D.DrivetrainType = DrivetrainType;
        end
        function [MotorRPM,Efficiency] = DriveTransfer(D,RoadSpeed,TireRadius)
            switch D.DrivetrainType
                case 'Electric'
                    Efficiency = D.Efficiency;
                    MotorRPM = RoadSpeed/TireRadius*D.GearRatio;
                    
                case 'Combustion'
                    Efficiency = D.Efficiency;
                    MotorRPM = RoadSpeed/TireRadius*D.GearRatio;
            end
        end
        
    end
end


