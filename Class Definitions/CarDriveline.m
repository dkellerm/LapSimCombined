classdef CarDriveline < handle
    %UNTITLED4 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        GearRatios
        ShiftPoints
        Efficiency
        Weight
        EffectiveCG
        SprungMass
        UnsprungMass
        J
        PrimaryGear
        FinalDriveRatio
        DrivetrainType
        OutputCurve
        Name = '';
    end
    methods
        function D = CarDriveline(GearRatios,Efficiency,SprungM,UnsprungM,CG,J,FinalDriveRatio,DrivetrainType)
            D.GearRatios = GearRatios;
            D.Efficiency = Efficiency;
            D.Weight = SprungM + sum(UnsprungM);
            D.EffectiveCG = CG;
            D.SprungMass = SprungM;
            D.UnsprungMass = UnsprungM;
            D.J = J;
            D.FinalDriveRatio = FinalDriveRatio;
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
        
        function CalculateOutputCurve(D, MotorOutputCurve)
            if length(D.GearRatios) > 1
                D.ShiftPoints = zeros(length(D.GearRatios) - 1,1);
                OutputCurves = zeros(length(D.GearRatios), length(MotorOutputCurve), 3);
                
                % Create Output Curves for each gear
                for i=1:length(D.GearRatios)
                    OutputCurves(i,:,1) = MotorOutputCurve(:,1) / D.GearRatios(i);
                    OutputCurves(i,:,2) = MotorOutputCurve(:,2) * D.GearRatios(i);
                    OutputCurves(i,:,3) = MotorOutputCurve(:,3);
                end
                
                % Find All Intersections of gear torque output curves.
                possibleShiftPoints = cell(length(D.ShiftPoints),1);
                for i=2:length(D.GearRatios)
                    possibleShiftPoints{i-1} = intersections(OutputCurves(i-1,:,1), OutputCurves(i-1,:,2), OutputCurves(i,:,1), OutputCurves(i,:,2), true);
                end
                
                % Take the first intersection
                D.ShiftPoints = cellfun(@(shiftPointsForGear)(round(min(shiftPointsForGear))), possibleShiftPoints);
                
                % Create the axle output curve. Uses 1 rpm increments.
                maxAxleRPM = max(OutputCurves(:,end,1));
                D.OutputCurve = zeros(maxAxleRPM + 1, 4);
                D.OutputCurve(:,1) = 0:maxAxleRPM;
                
                for i=1:length(D.GearRatios)
                    if i == 1
                        D.OutputCurve(1:D.ShiftPoints(i), 2) = interp1(OutputCurves(i,:,1), OutputCurves(i,:,2), D.OutputCurve(1:D.ShiftPoints(i),1));
                        D.OutputCurve(1:D.ShiftPoints(i), 3) = interp1(OutputCurves(i,:,1), OutputCurves(i,:,3), D.OutputCurve(1:D.ShiftPoints(i),1));
                    elseif i==length(D.GearRatios)
                        D.OutputCurve(D.ShiftPoints(i-1):end, 2) = interp1(OutputCurves(i,:,1), OutputCurves(i,:,2), D.OutputCurve(D.ShiftPoints(i-1):end, 1));
                        D.OutputCurve(D.ShiftPoints(i-1):end, 3) = interp1(OutputCurves(i,:,1), OutputCurves(i,:,3), D.OutputCurve(D.ShiftPoints(i-1):end, 1));
                    else
                        D.OutputCurve(D.ShiftPoints(i-1):D.ShiftPoints(i), 2) = interp1(OutputCurves(i,:,1), OutputCurves(i,:,2), D.OutputCurve(D.ShiftPoints(i-1):D.ShiftPoints(i),1));
                        D.OutputCurve(D.ShiftPoints(i-1):D.ShiftPoints(i), 3) = interp1(OutputCurves(i,:,1), OutputCurves(i,:,3), D.OutputCurve(D.ShiftPoints(i-1):D.ShiftPoints(i),1));
                    end
                end
                
                plot(OutputCurves(1,:,1), OutputCurves(1,:,2),...
                    OutputCurves(2,:,1), OutputCurves(2,:,2), ...
                    OutputCurves(3,:,1), OutputCurves(3,:,2), ...
                    OutputCurves(4,:,1), OutputCurves(4,:,2), ...
                    OutputCurves(5,:,1), OutputCurves(5,:,2), ...
                    D.OutputCurve(:,1), D.OutputCurve(:,2));
            end
                
        end
        
    end
end


