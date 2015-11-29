classdef CarBattery < handle
    %UNTITLED8 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Capacity
        Weight
        EffectiveCG
        fuel_corner
        fuel_brake
        fuel_shift
        
        Name = '';
    end
    
    methods
        function B = CarBattery(Capacity,Weight,CG,fuel_corner,fuel_brake,fuel_shift)
            B.Capacity = Capacity;
            B.Weight = Weight;
            B.EffectiveCG = CG;
            B.fuel_corner = fuel_corner;
            B.fuel_brake = fuel_brake;
            B.fuel_shift = fuel_shift;
        end
        
    end
    
end

