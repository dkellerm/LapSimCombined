NoRegenRaw = squeeze(RawResults(1,:,:));

EndTimes = [];

for i = 1:size(NoRegenRaw,1)
    for j = 1:size(NoRegenRaw,2)
        EndTimes(i,j) = sum(NoRegenRaw{i,j}.Results{1});
    end
end