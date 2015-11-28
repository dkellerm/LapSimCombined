classdef CarTire < handle
    %CarTire is an object class used in the SAE Lap Sim in conjuction with
    %several other classes to build a Car class object.
    %   The Car tire is currently defined by it's GG curve (currently
    %   assumed to be elliptical), rolling resistance, weight, system CG,
    %   mass moment of inertia about the CG, rotational inertia, effective
    %   radius.
    
    properties
        MaxForwardAcceleration  % Max non turning acceleration on GG curve
        MaxBrakingAcceleration
        ForwardAccelerationMap
        BrakingAccelerationMap
        MaxLateralAcceleration % Max turning acceleration on GG curve
        LateralAccelerationMap % Max Lateral acceleration for at different radii
        RollingResistance % Constant rolling resistance coefficient
        SpringRate
        Weight % Weight of all four tires (lbf)
        EffectiveCG % CG of all tires (in inches from center rear axle)
        J % Rotational inertia (lbf in^2)
        Radius % Effective radius (in)
        FrontInclinationAngle
        RearInclinationAngle
        
        TireModelLatNormalAxis
        TireModelLatSlipAxis
        TireModelLatCamberAxis
        TireModelLatData
        
        TireModelLatAligningMoments
        TireModelLatAligningNormal
        TireModelLatAligningSA
        
        TireModelLongNormalAxis
        TireModelLongSlipAxis
        TireModelLongCamberAxis
        
        Name = '';
    end
    
    methods
        function T = CarTire(K,R,Resistance,Weight,CG,J)
            % CarTire Constructor method
            %
            % This method constructs an object of type CarTire.  To define
            % an object of this class, input a maximum forward
            % acceleration, maximum lateral acceleration, a radius, a
            % rolling resistance coefficient, a weight, a center of
            % gravity, a moment of inertia about the CG, and a rotational
            % moment of inertia about the center of the tire.
            %   
            
            % Assigns values to tire object properties
            T.SpringRate = K;
            T.Radius = R;
            T.RollingResistance = Resistance;
            T.Weight = Weight;
            T.EffectiveCG = CG;
            T.J = J;
            
            SR_a = .09; % acceleration slip ratio                                    
            SR_b = -.10; % braking slip ratio

            tiredatalat = getfield(load('Hoosier_R25B_13_6_Lateral_6CF.mat'),'tiredatalat'); % Load tire data with lateral forces
            [wid_lat,hei_lat,len_lat] = size(tiredatalat);
            camb_lat = 0:.25:3;
            for i = 1:len_lat
                mtrx_lat(:,:,i) = -tiredatalat(2:wid_lat,2:wid_lat,i); % matrix with lateral forces
            end
            normal_lat = tiredatalat(1,2:wid_lat,1); % array with normal forces
            slip_lat = tiredatalat(2:wid_lat,1,1); % array with slip angles
            [NORM_lat,SLIP_lat,CAMB_lat] = meshgrid(normal_lat,slip_lat,camb_lat); % meshgrid inputs for use with interp3 function

            tiredatamz_sp = xlsread('Hoosier_R25B_13_6_Mz.xlsx' , '0' , 'A1:CW101'); %read excel sheet with Mz moments
            [widt,heit] = size(tiredatamz_sp);
            norm_mz = tiredatamz_sp(1,2:widt); % array of normal loads

            tiredatalong = xlsread('Hoosier_R25B_13_6_Longitudinal_6CF.xlsx' , '0' , 'A1:CW101'); %read excel sheet with longitudinal forces
            [widt,heit] = size(tiredatalong);
            norm_long = tiredatalong(1,2:widt);
            slip_long = tiredatalong(2:heit,1);
            mtrx_long = -tiredatalong(2:heit,2:widt);
        end
        
        function CalculateLateralGMap(T,CarObject,TrackObject)
            TrackCornerRadii = TrackObject.TrackCornerRadii();
            TrackCornerRadii = unique(TrackCornerRadii);
            
            % Balance Car at closest to average corner
            averageCornerRadius = mean(TrackCornerRadii);
            [~, closestToAverageCornerRadiusIndex] = min(abs(TrackCornerRadii-averageCornerRadius));
            LateralGCalculator(T, CarObject, 'Balance', TrackCornerRadii(closestToAverageCornerRadiusIndex));
            
            % Calculate max lateral acceleration at corner radii using balanced car.
            T.LateralAccelerationMap = struct('accelerations', arrayfun(@(radius)(LateralGCalculator(T,CarObject,'',radius)), TrackCornerRadii),...
                                              'radii', TrackCornerRadii);
            T.MaxLateralAcceleration = max(T.LateralAccelerationMap.accelerations);
        end
        
        function lateralG = LateralGCalculator(T,CarObject,Balance,Radius)
            Ws = CarObject.SprungMass;
            Wfus = CarObject.UnsprungMass(1);
            Wrus = CarObject.UnsprungMass(2);
            Tf = CarObject.Chassis.Track(1);
            Tr = CarObject.Chassis.Track(2);
            hfus = CarObject.Suspension.UnsprungHeight(1);
            hrus = CarObject.Suspension.UnsprungHeight(2);
            hfrc = CarObject.Suspension.RollCenters(1);
            hrrc = CarObject.Suspension.RollCenters(2);
            hCG = CarObject.CG(3) - (hfrc + hrrc)/2;
            b = CarObject.CG(1)/CarObject.Chassis.Length;
            a = 1 - b;
            FR = [ a b ];
            
            K1F = CarObject.Suspension.LinearSpring(1);
            K1R = CarObject.Suspension.LinearSpring(2);
            KarbF = CarObject.Suspension.ARB(1);
            KarbR = CarObject.Suspension.ARB(2);
            K2  = T.SpringRate;
            
            Kf = ((1/(K1F*Tf^2/2 + KarbF) + 2/(K2*Tf^2))^-1);
            Kr = ((1/(K1R*Tr^2/2 + KarbR) + 2/(K2*Tr^2))^-1);
            
            Kf_initial = Kf;
            Kr_initial = Kr;
            
            Gs = (0:0.01:2)';
            Velocity = sqrt(Gs * 32.2 * Radius/12);
            Fz_aero_delta = CarObject.CalculateAeroEffects(Velocity);
            
            UnbalanceFlag = 1;
            
            while true
            
                Fz = LateralWeightTransfer( Gs,Ws,Wfus,Wrus,FR,Tf,Tr,Kf,Kr,hCG,hfus,hrus,hfrc,hrrc );
                
                Fz = Fz + Fz_aero_delta;
                
                [Fy,SA] = T.TireModel(Fz,'Lateral');

                FyFront = Fy(:,1) + Fy(:,2);
                FyRear  = Fy(:,3) + Fy(:,4);

                W = Ws + Wrus + Wfus;
                Wf = W*FR(1);
                Wr = W*FR(2);

                FrontGs = FyFront/Wf;
                RearGs  = FyRear/Wr;

                OutGs = zeros(length(FrontGs),1);

                I = FrontGs > RearGs;
                OutGs(I) = RearGs(I);
                I = RearGs >= FrontGs;
                OutGs(I) = FrontGs(I);

                Difference = OutGs - Gs;
                I1 = find(Difference >= 0,1,'last');
                I2 = find(Difference < 0, 1,'first');

                Diff1 = abs(Difference(I1));
                Diff2 = abs(Difference(I2));

                if Diff1 > Diff2
                    I = I2;
                else
                    I = I1;
                end
                
                if strcmp(Balance,'Balance')
                
                    if UnbalanceFlag
                        
                        UnbalancedG = OutGs(I);
                        UnbalanceFlag = 0;
                        
                    end
                    
                    Diff = FrontGs(I) - RearGs(I);
                
                    if abs(Diff) > 0.01
                        Adjustment = abs(Diff/max(FrontGs(I),RearGs(I)))*min(Kr,Kf);
                        if Diff > 0
                            Kr = Kr - Adjustment;
                            Kf = Kf + Adjustment;
                        else
                            Kr = Kr + Adjustment;
                            Kf = Kf - Adjustment;
                        end
                    else
                        disp(['Front Roll Stiffness: ',num2str(Kf), ' in-lbf/rad'])
                        disp(['Rear Roll Stiffness:  ',num2str(Kr), ' in-lbf/rad'])
                        disp(['Unbalanced Gs: ', num2str(UnbalancedG)])
                        disp(['Balanced Gs:   ', num2str(OutGs(I))])
                        break
                    end
                
                else
                    break
                end
            
            end
            
            if Fz(171,1) <= 0
                disp('Warning, car fails tilt test')
            elseif Fz(I,1) <= 0
                disp('Warning, car flips before max lateral acceleration acheived')
            end
               
            
            lateralG = OutGs(I);
            CarObject.Suspension.LinearSpring(1) = CarObject.Suspension.LinearSpring(1) - (Kf_initial - Kf);
            CarObject.Suspension.LinearSpring(2) = CarObject.Suspension.LinearSpring(2) - (Kr_initial - Kr);
            
        end
        
        function CalculateLongitudinalGMap(T, CarObject)
            Velocities = 0:10:100;
            [ForwardGs, BrakingGs] = arrayfun(@(velocity)(LongitudinalGCalculator(T, CarObject, velocity)), Velocities);
            T.ForwardAccelerationMap = struct('accelerations', ForwardGs, 'velocities', Velocities);
            T.BrakingAccelerationMap = struct('accelerations', BrakingGs, 'velocities', Velocities);
            
            T.MaxForwardAcceleration = max(T.ForwardAccelerationMap.accelerations);
            T.MaxBrakingAcceleration = max(T.BrakingAccelerationMap.accelerations);
        end
        
        function [forwardG, brakingG] = LongitudinalGCalculator(T,CarObject, Velocity)
            
            Kf = CarObject.Suspension.LinearSpring(1);
            Kr = CarObject.Suspension.LinearSpring(2);
            Kt = T.SpringRate;
            Ws = CarObject.SprungMass;
            Wfus = CarObject.UnsprungMass(1);
            Wrus = CarObject.UnsprungMass(2);
            hCG = CarObject.CG(3);
            PC = CarObject.Suspension.PitchCenter;
            L = CarObject.Chassis.Length;
            b = CarObject.CG(1)/CarObject.Chassis.Length;
            a = 1 - b;
            FR = [ a b ];
            
            Gs = (0:0.01:2)';
            
            Fz = LongitudinalWeightTransfer( Kf, Kr, Kt, Gs, Ws, Wfus, Wrus, hCG, PC, FR, L );
            Fz_aero_deltas = CarObject.CalculateAeroEffects(Velocity);
            
            Fz(:,1) = Fz(:,1) + Fz_aero_deltas(1);
            Fz(:,2) = Fz(:,2) + Fz_aero_deltas(2);
            Fz(:,3) = Fz(:,3) + Fz_aero_deltas(3);
            Fz(:,4) = Fz(:,4) + Fz_aero_deltas(4);

            [Fx, SR] = T.TireModel(Fz,'Longitudinal');

            FxRear  = Fx(:,3) + Fx(:,4);

            W = Ws + Wrus + Wfus;
            RearGs = FxRear/W;

            Difference = RearGs - Gs;
            I1 = find(Difference >= 0,1,'last');
            I2 = find(Difference < 0, 1,'first');

            Diff1 = abs(Difference(I1));
            Diff2 = abs(Difference(I2));

            if Diff1 > Diff2
                I = I2;
            else
                I = I1;
            end
            
            forwardG = RearGs(I);
            
            Gs = -(0:0.01:5)';
            
            Fz = LongitudinalWeightTransfer( Kf, Kr, Kt, Gs, Ws, Wfus, Wrus, hCG, PC, FR, L );
            
            I = find(Fz(:,3:4) < 0);
            
            if I
                Fz = Fz(1:I(1)-1,:);
                Gs = Gs(1:I(1)-1);
            end
            
            [Fx,SR] = T.TireModel(Fz,'Longitudinal');

            FxTotal = Fx(:,1) + Fx(:,2) + Fx(:,3) + Fx(:,4);
            
            OutGs = -FxTotal/W;
            
            Difference = OutGs - Gs;
            I1 = find(Difference >= 0,1,'last');
            I2 = find(Difference < 0, 1,'first');

            Diff1 = abs(Difference(I1));
            Diff2 = abs(Difference(I2));

            if Diff1 > Diff2
                I = I2;
            else
                I = I1;
            end

            if I
           
                brakingG = OutGs(I);
                
            else
                disp('Warning, car flips before brake lockup')
                brakingG = OutGs(end);
                
            end
            
        end
 
        function LongA = GGCurve(T,LateralA,BrakeThrottle, Velocity)
            % CarTire GGCurve Method
            %
            % This method returns an array of possible longitudinal
            % accelerations that are possible from a given array of lateral
            % accelerations.  Currently assumes GG curve is symmetric
            % ellipse.
            %
            % INPUTS
            % Name          Type          Units   Description            
            %**************************************************************
            % T             TireObject    N/A     Tire Object for the given
            %                                     GG curve
            %
            % LateralA      Nx1 array     G's     Lateral Acceleration for
            %                                     which a maximum forward/
            %                                     backward acceleration is 
            %                                     desired from the car tire
            % OUTPUTS
            % Name          Type          Units   Description            
            %**************************************************************
            % LongA         Nx1 array     G's     Maximum longitudinal
            %                                     acceleration for given 
            %                                     lateral acceleration
            %
            % VARIABLES
            % Name          Type          Units   Description            
            %**************************************************************
            % NONE
            %
            % FUNCTIONS
            % Name          Location         Description            
            %**************************************************************
            % NONE    
            
            radii = (Velocity.^2)./LateralA; % Will result in NaN for velocities/Lat A's of zero.
            maxLateralAs = interp1(T.LateralAccelerationMap.radii, T.LateralAccelerationMap.accelerations, radii, 'spline');
            
            if strcmp(BrakeThrottle,'Throttle')
                maxForwardA = interp1(T.ForwardAccelerationMap.velocities, T.ForwardAccelerationMap.accelerations, Velocity, 'spline');
                LongA = maxForwardA.*sqrt(1-(LateralA./maxLateralAs).^2);
                I = isnan(LongA);
                LongA(I) = maxForwardA(I);
            elseif strcmp(BrakeThrottle,'Brake')
                maxBrakeA = interp1(T.BrakingAccelerationMap.velocities, T.BrakingAccelerationMap.accelerations, Velocity, 'spline');
                LongA = abs(maxBrakeA.*sqrt(1-(LateralA./maxLateralAs).^2));
                I = isnan(LongA);
                LongA(I) = -1 * maxBrakeA(I);
            end
        end
        
        function PlotGGCurve(T)
            LatG = linspace(-T.MaxLateralAcceleration,T.MaxLateralAcceleration,100);
            
            LongForG = -T.GGCurve(abs(LatG),'Throttle');
            LongBacG = T.GGCurve(abs(LatG),'Brake');
            
            figure
            plot(LatG,LongForG,'b',LatG,LongBacG,'b')
            grid on
            xlabel('Lateral Gs')
            ylabel('Longitudinal Gs')
            
        end
        
        function [Fy, SA] = TireOperatingPoints(T, Fz)
                tmp = abs(T.TireModelLatNormalAxis - max([F_FLz,F_FRz,F_RLz,F_RRz])); % difference between calculated normal load and array
                [~,idx] = min(tmp); % index of closest value
                idxsa = find(T.TireModelLatAligningMoments(3:end,idx) == max(T.TireModelLatAligningMoments(3:end,idx))); % vertical index is at location of max Mz at the given normal load
                SA = tiredatamz_sp(idxsa,1); % locate slip angle

                C_a_FL = interp3(NORM_lat,SLIP_lat,CAMB_lat,mtrx_lat,F_FLz,SA,-IA_FLc)/SA; % FL cornering stiffness [lb/deg]
                C_a_FR = interp3(NORM_lat,SLIP_lat,CAMB_lat,mtrx_lat,F_FRz,SA,-IA_FRc)/SA; % FR cornering stiffness [lb/deg]
                C_a_RL = interp3(NORM_lat,SLIP_lat,CAMB_lat,mtrx_lat,F_RLz,SA,-IA_RLc)/SA; % RL cornering stiffness [lb/deg]
                C_a_RR = interp3(NORM_lat,SLIP_lat,CAMB_lat,mtrx_lat,F_RRz,SA,-IA_RRc)/SA; % RR cornering stiffness [lb/deg]
                    
                alpha_FL = F_FLz*v_max0^2/(C_a_FL*g*r(aa)); % FL slip angle
                alpha_FR = F_FRz*v_max0^2/(C_a_FR*g*r(aa)); % FR slip angle
                alpha_RL = F_RLz*v_max0^2/(C_a_RL*g*r(aa)); % RL slip angle
                alpha_RR = F_RRz*v_max0^2/(C_a_RR*g*r(aa)); % RR slip angle
                    
                F_FLy = interp3(NORM_lat,SLIP_lat,CAMB_lat,mtrx_lat,F_FLz,abs(alpha_FL),-IA_FLc); % FL lateral force
                F_FRy = interp3(NORM_lat,SLIP_lat,CAMB_lat,mtrx_lat,F_FRz,abs(alpha_FR),-IA_FRc); % FR lateral force
                F_RLy = interp3(NORM_lat,SLIP_lat,CAMB_lat,mtrx_lat,F_RLz,abs(alpha_RL),-IA_RLc); % RL lateral force
                F_RRy = interp3(NORM_lat,SLIP_lat,CAMB_lat,mtrx_lat,F_RRz,abs(alpha_RR),-IA_RRc); % RR lateral force
        end
        
        
    end
    
end

function [ NormalLoad ] = LateralWeightTransfer( Gs,Ws,Wfus,Wrus,FR,Tf,Tr,Kf,Kr,hCG,hfus,hrus,hfrc,hrrc )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here



Weight = Ws + Wfus + Wrus;
WeightF = Weight*FR(1);
WeightR = Weight*FR(2);

SprungWeightF = WeightF - Wfus;
SprungWeightR = WeightR - Wrus;

FRSprung = [ SprungWeightF/Ws, SprungWeightR/Ws ];

UnsprungWTF = Wfus*Gs*hfus/Tf;
UnsprungWTR = Wrus*Gs*hrus/Tr;

GeometricWTF = Ws*Gs*FRSprung(1)*hfrc/Tf;
GeometricWTR = Ws*Gs*FRSprung(2)*hrrc/Tr;

ElasticWTF = Ws*Gs*hCG*(Kf/(Kf+Kr))/Tf; % hCG is with respect to roll axis
ElasticWTR = Ws*Gs*hCG*(Kr/(Kf+Kr))/Tr;

StaticWFR = -Weight*FR(1)/2;
StaticWFL = -Weight*FR(1)/2;
StaticWRR = -Weight*FR(2)/2;
StaticWRL = -Weight*FR(2)/2;

NormalWFR = -(StaticWFR + UnsprungWTF + GeometricWTF + ElasticWTF);
NormalWFL = -(StaticWFL - UnsprungWTF - GeometricWTF - ElasticWTF);

NormalWRR = -(StaticWRR + UnsprungWTR + GeometricWTR + ElasticWTR);
NormalWRL = -(StaticWRL - UnsprungWTR - GeometricWTR - ElasticWTR);


%               InsideF  OutsideF   InsideR   OutsideR
NormalLoad = [ NormalWFR NormalWFL NormalWRR NormalWRL ];

end

function [ NormalLoad ] = LongitudinalWeightTransfer( Kf, Kr, Kt, Gs, Ws, Wfus, Wrus, hCG, PC, FR, L )
    
    a = FR(2)*L;
    b = FR(1)*L;
    o = PC(2) - b;
    h = hCG - PC(1);
    
    F = Gs*(Ws + Wfus + Wrus);

    S0 = Kf*Kt^2*a^2 + Kr*Kt^2*b^2 + Kf*Kt^2*o^2 + Kr*Kt^2*o^2 +...
    Kf*Kr*Kt*a^2 + Kf*Kr*Kt*b^2 + 2*Kf*Kr*Kt*o^2 - 2*Kf*Kt^2*a*o +...
    2*Kr*Kt^2*b*o - 2*Kf*Kr*Kt*a*o + 2*Kf*Kr*Kt*b*o;

    Pitch = F*h*(Kf+Kt)*(Kr+Kt)/S0;
    
    DynamicCGh = Pitch*o + hCG;
    
% 
%     WeightTransferF = -F*h*(a-o)*(Kt*2)*(Kf*(Kr + Kt))/S0;
%     WeightTransferR =  F*h*(b+o)*(Kt*2)*(Kr*(Kf + Kt))/S0;



    WeightTransferF = -DynamicCGh./L*(Ws+Wfus+Wrus).*Gs;
    WeightTransferR = DynamicCGh./L*(Ws+Wfus+Wrus).*Gs;
    
    StaticWeightF = Ws*b/(a+b) + Wfus;
    StaticWeightR = Ws*a/(a+b) + Wrus;
    
    FrontLoad = StaticWeightF + WeightTransferF;
    RearLoad = StaticWeightR + WeightTransferR;
    
    NormalLoad = [ FrontLoad/2 FrontLoad/2 RearLoad/2 RearLoad/2 ];
    
end
    
    



