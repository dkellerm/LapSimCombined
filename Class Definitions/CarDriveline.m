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
        FinalDriveRatio
        OutputCurve % [AxleRPM, AxleTorque, MotorRPM, MotorTorque, MotorEfficiency, GearNumber]
    end
    methods
        function D = CarDriveline(GearRatios,Efficiency,SprungM,UnsprungM,CG,J,FinalDriveRatio)
            D.GearRatios = GearRatios;
            D.Efficiency = Efficiency;
            D.Weight = SprungM + sum(UnsprungM);
            D.EffectiveCG = CG;
            D.SprungMass = SprungM;
            D.UnsprungMass = UnsprungM;
            D.J = J;
            D.FinalDriveRatio = FinalDriveRatio;
        end
        
        function CalculateOutputCurve(D, MotorOutputCurve)
            if length(D.GearRatios) > 1 % Multiple Gears
                D.ShiftPoints = zeros(length(D.GearRatios) - 1,1);
                OutputCurves = zeros(length(D.GearRatios), length(MotorOutputCurve), 5);

                % Create Output Curves for each gear
                for i=1:length(D.GearRatios)
                    OutputCurves(i,:,1) = MotorOutputCurve(:,1) / D.GearRatios(i);
                    OutputCurves(i,:,2) = MotorOutputCurve(:,2) * D.GearRatios(i);
                    OutputCurves(i,:,3) = MotorOutputCurve(:,1);
                    OutputCurves(i,:,4) = MotorOutputCurve(:,2);
                    OutputCurves(i,:,5) = MotorOutputCurve(:,3);
                end

                % Find All Intersections of gear torque output curves.
                possibleShiftPoints = cell(length(D.ShiftPoints),1);
                for i=2:length(D.GearRatios)
                    possibleShiftPoints{i-1} = intersections(OutputCurves(i-1,:,1), OutputCurves(i-1,:,2), OutputCurves(i,:,1), OutputCurves(i,:,2), true);
                end

                % Take the first intersection
                D.ShiftPoints = cellfun(@(shiftPointsForGear)(round(min(shiftPointsForGear))), possibleShiftPoints);

                % Create the axle output curve. Uses 1 rpm increments.
                maxAxleRPM = round(max(OutputCurves(:,end,1)));
                D.OutputCurve = zeros(maxAxleRPM + 1, 6);
                D.OutputCurve(:,1) = 0:maxAxleRPM;

                for i=1:length(D.GearRatios)
                    if i == 1 % First Gear starts at 0
                        D.OutputCurve(1:D.ShiftPoints(i), 2) = interp1(OutputCurves(i,:,1), OutputCurves(i,:,2), D.OutputCurve(1:D.ShiftPoints(i),1));
                        D.OutputCurve(1:D.ShiftPoints(i), 3) = interp1(OutputCurves(i,:,1), OutputCurves(i,:,3), D.OutputCurve(1:D.ShiftPoints(i),1));
                        D.OutputCurve(1:D.ShiftPoints(i), 4) = interp1(OutputCurves(i,:,1), OutputCurves(i,:,4), D.OutputCurve(1:D.ShiftPoints(i),1));
                        D.OutputCurve(1:D.ShiftPoints(i), 5) = interp1(OutputCurves(i,:,1), OutputCurves(i,:,5), D.OutputCurve(1:D.ShiftPoints(i),1));
                        D.OutputCurve(1:D.ShiftPoints(i), 6) = i;
                    elseif i==length(D.GearRatios) % Final gear goes until end of matrix.
                        D.OutputCurve(D.ShiftPoints(i-1):end, 2) = interp1(OutputCurves(i,:,1), OutputCurves(i,:,2), D.OutputCurve(D.ShiftPoints(i-1):end, 1));
                        D.OutputCurve(D.ShiftPoints(i-1):end, 3) = interp1(OutputCurves(i,:,1), OutputCurves(i,:,3), D.OutputCurve(D.ShiftPoints(i-1):end, 1));
                        D.OutputCurve(D.ShiftPoints(i-1):end, 4) = interp1(OutputCurves(i,:,1), OutputCurves(i,:,4), D.OutputCurve(D.ShiftPoints(i-1):end, 1));
                        D.OutputCurve(D.ShiftPoints(i-1):end, 5) = interp1(OutputCurves(i,:,1), OutputCurves(i,:,5), D.OutputCurve(D.ShiftPoints(i-1):end, 1));
                        D.OutputCurve(D.ShiftPoints(i-1):end, 6) = i;
                    else % Intermediate gear fills space between two shift points
                        D.OutputCurve(D.ShiftPoints(i-1):D.ShiftPoints(i), 2) = interp1(OutputCurves(i,:,1), OutputCurves(i,:,2), D.OutputCurve(D.ShiftPoints(i-1):D.ShiftPoints(i),1));
                        D.OutputCurve(D.ShiftPoints(i-1):D.ShiftPoints(i), 3) = interp1(OutputCurves(i,:,1), OutputCurves(i,:,3), D.OutputCurve(D.ShiftPoints(i-1):D.ShiftPoints(i),1));
                        D.OutputCurve(D.ShiftPoints(i-1):D.ShiftPoints(i), 4) = interp1(OutputCurves(i,:,1), OutputCurves(i,:,4), D.OutputCurve(D.ShiftPoints(i-1):D.ShiftPoints(i),1));
                        D.OutputCurve(D.ShiftPoints(i-1):D.ShiftPoints(i), 5) = interp1(OutputCurves(i,:,1), OutputCurves(i,:,5), D.OutputCurve(D.ShiftPoints(i-1):D.ShiftPoints(i),1));
                        D.OutputCurve(D.ShiftPoints(i-1):D.ShiftPoints(i), 6) = i;
                    end
                end

                plot(OutputCurves(1,:,1), OutputCurves(1,:,2),...
                    OutputCurves(2,:,1), OutputCurves(2,:,2), ...
                    OutputCurves(3,:,1), OutputCurves(3,:,2), ...
                    OutputCurves(4,:,1), OutputCurves(4,:,2), ...
                    OutputCurves(5,:,1), OutputCurves(5,:,2), ...
                    D.OutputCurve(:,1), D.OutputCurve(:,2));
            else % Single Gear
                maxAxleRPM = round(max(MotorOutputCurve(:,1)));
                D.OutputCurve = zeros(maxAxleRPM + 1, 6);
                D.OutputCurve(:,1) = 0:maxAxleRPM;
                
                D.OutputCurve(:, 2) = interp1(MotorOutputCurve(:,1), MotorOutputCurve(:,2), D.OutputCurve(:,1));
                D.OutputCurve(:, 3) = D.OutputCurve(:,1);
                D.OutputCurve(:, 4) = D.OutputCurve(:,2);
                D.OutputCurve(:, 5) = interp1(MotorOutputCurve(:,1), MotorOutputCurve(:,3), D.OutputCurve(:,1));
                D.OutputCurve(:, 6) = 1;
            end
            
            D.OutputCurve(:,1) = D.OutputCurve(:,1) / D.FinalDriveRatio;
            D.OutputCurve(:,2) = D.OutputCurve(:,2) * D.FinalDriveRatio;
        end
    end
end


