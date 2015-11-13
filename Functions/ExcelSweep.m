function [RawResults] = ExcelSweep(TrackFcn, StartRow, EndRow, TabName)
	NumberOfRuns = EndRow - StartRow + 1;
	Track = TrackFcn();
	Results = zeros(NumberOfRuns,8);
    RawResults = cell(NumberOfRuns,1);
	
	EnduranceLength = 866142; % 22km in inches
    
	
	EnduranceLaps = ceil(EnduranceLength/Track.Length);
        
	parfor row = StartRow:EndRow
        
        Track = TrackFcn();
		Car = CarBuilderSS(TabName, row);
		Tele = Simulate(Car, Track);
		
		TimeAutoX = sum(cell2mat(Tele.Results(1)));
		Time75 = cell2mat(Tele.Results(4));
		MaxG = Car.Tire.MaxLateralAcceleration;
		TimeSkid = 2*pi*sqrt(9.1/(9.81*MaxG));
		TimeEnd = TimeAutoX * EnduranceLaps;
        
		EnduranceLapPowers = Tele.LapData(1:Track.Length,8)*0.000112985;
		EnduranceLapTimes = Tele.LapData(1:Track.Length,11);
		EnduranceEnergy = sum(FirstLapP.*FirstLapT)/3600;
		
		% Fill in any car parameters that should be saved in place of the 0's below.
		Results(row - StartRow + 1, :) = [TimeAutoX,Time75,TimeSkid,TimeEnd,EnduranceEnergy,WheelBase,WF,0]; 
		RawResults{row - StartRow + 1} = Tele;
	end
end