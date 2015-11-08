clear all
clc
format compact


%% Template
% [X,Y] = meshgrid(-3:1:3);
% V = peaks(X,Y);
% 
% figure
% surf(X,Y,V)
% title('Sample Grid');
% 
% [Xq,Yq] = meshgrid(-3:0.25:3);
% 
% Vq = interp2(X,Y,V,Xq,Yq,'linear');
% 
% figure
% surf(Xq,Yq,Vq);
% title('Refined Grid');

%% ENGINE (USER INPUTS)

T_mult = 1.0; % torque multiplier

t_shift = .280;     % shift time (s). Only 3 decimals. Value from 4/19/14 test data. 
redline = 8000;    % rev limit (rpm) 8000 for delft
% torque_step = 100;  % rpm step for torque curve [Isaac says to get creative, constant step]
G= zeros(5);        % preallocate matrix for for gears 
G(1) = 2.5;         % first gear ratio
G(2) = 2;           % second gear ratio
G(3) = 1.632;       % third gear ratio
G(4) = 1.333;       % fourth gear ratio
G(5) = 1.095;       % fifth gear ratio
G_P = 2.652;        % primary gear ratio
G_F = 38/14;        % final drive ratio

r_t = 10.25*( 1 / 12 ); % tire rolling radius (ft)   %MEASURE THIS WITH VEHICLE ROLL TEST


%% Read Excel

N = xlsread('Torquecurves.xlsx','Delft','C4:C129');
  
for n = 1:length(G) % for all gears
    
    R(n) = G(n)*G_P*G_F; % total gear reduction
    
    T_ref(:,n) = xlsread('Torquecurves.xlsx','Delft','E4:E129').*R(n)*T_mult; % 2014 SS torque curve        
    
   for rev = 1:redline % over rpm range
        
        v_ref(rev,n) = rev*( 1 ./ R(n) )*( 1 / 60 )*( 2*pi*r_t ); % speeds as function of rpm and gear
        
    end
    
end

%% Interpolate torque and RPM curves

torque_step = redline/length(T_ref);
T_REF = 0; % Initialize
for rev = 1:torque_step:redline
    if rev > min(N)
        for n = 1:length(G)
            for nn = 1:length(T_ref)
                T_REF(end+1,n) = interp1(N,T_ref(:,n),rev);
            end
        end
    end
end


%% Fuel Map
