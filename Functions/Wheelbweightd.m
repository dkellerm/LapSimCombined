function [ RawResults,PointResults ] = Wheelbweightd( CarFcn, TrackFcn )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here


Length  = [ ];
Weight_D = [];

S1 = 1:length(Length);
S2 = 1:length(Weight_D);

RawResults = zeros(S1*2,8,S2);
EnduranceLength = 866142; %22km in inches
EnduranceLaps = EnduranceLength/Track.Length;


parfor i = S1
    Car = car(
    Track = TrackFcn();  
    
end

