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
        setup
        Tmult
        Name = '';
    end
    methods
%         function D = CarDriveline(GearRatio,Efficiency,SprungM,UnsprungM,CG,J,PrimaryGear,FinalDrive,Tmult)
%             D.GearRatio = GearRatio;
%             D.Efficiency = Efficiency;
%             D.Weight = SprungM + sum(UnsprungM);
%             D.EffectiveCG = CG;
%             D.SprungMass = SprungM;
%             D.UnsprungMass = UnsprungM;
%             D.J = J;
%             D.PrimaryGear = PrimaryGear;
%             D.FinalDrive = FinalDrive;
%             D.Tmult = Tmult;
%         
%         end
        
        function D = CarDriveline(GearRatio,Efficiency,SprungM,UnsprungM,CG,J)
            D.GearRatio = GearRatio;
            D.Efficiency = Efficiency;
            D.Weight = SprungM + sum(UnsprungM);
            D.EffectiveCG = CG;
            D.SprungMass = SprungM;
            D.UnsprungMass = UnsprungM;
            D.J = J;
        end
 
%         switch setup
%             case 'Electric'
        
                function [MotorRPM,Efficiency] = DriveTransfer(D,RoadSpeed,TireRadius)
                    Efficiency = D.Efficiency;
                    MotorRPM = RoadSpeed/TireRadius*D.GearRatio;
                end
        
%             case 'Combustion'
%             
%                 function [MotorRPM,Efficiency] = DriveTransfer(D,RoadSpeed,TireRadius)
%                     Efficiency = D.Efficiency;
%                     MotorRPM = RoadSpeed/TireRadius*D.GearRatio*D.PrimaryGear*D.FinalDrive*D.Tmult;
%                 end
%         end
            
    end
 end


