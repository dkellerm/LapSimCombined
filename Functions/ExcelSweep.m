function [Results, RawResults] = ExcelSweep(TrackFcn, StartRow, EndRow, TabName)
	NumberOfRuns = EndRow - StartRow + 1;
    RowIndices = 1:NumberOfRuns;
    
	Track = TrackFcn();
	Results = zeros(NumberOfRuns,8);
    RawResults = cell(NumberOfRuns,1);
	
	EnduranceLength = 866142; % 22km in inches
	EnduranceLaps = ceil(EnduranceLength/Track.Length);
        
	parfor i = RowIndices
        
        Track = TrackFcn();
		Car = CarBuilderSS(TabName, i + StartRow - 1);
		Tele = Simulate(Car, Track);
		
		TimeAutoX = sum(cell2mat(Tele.Results(1)));
		Time75 = cell2mat(Tele.Results(4));
		MaxG = Car.Tire.MaxLateralAcceleration;
		TimeSkid = 2*pi*sqrt(9.1/(9.81*MaxG));
		TimeEnd = TimeAutoX * EnduranceLaps;
        
		EnduranceLapPowers = Tele.LapData(1:Track.Length,8)*0.000112985;
		EnduranceLapTimes = Tele.LapData(1:Track.Length,11);
		EnduranceEnergy = sum(EnduranceLapPowers.*EnduranceLapTimes)/3600;
		
		% Fill in any car parameters that should be saved in place of the 0's below.
		Results(i, :) = [TimeAutoX,Time75,TimeSkid,TimeEnd,EnduranceEnergy,Car.DragCoefficient,Car.LiftCoefficient,0]; 
		RawResults{i} = Tele;
        
    end

end