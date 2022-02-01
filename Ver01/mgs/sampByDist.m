function SampN = sampByDist(sampSpace,freqDist,N)

% sampByDist draws N samples from the sample spce(sampSpace) according to
% a specific frequency distribution(ferqDist)

sampSpace_pile = [];
for freqInd = 1:length(freqDist)
    sampSpace_pile = [sampSpace_pile ; [sampSpace(freqInd) * ones(freqDist(freqInd),1)]];
end

inds = randi(length(sampSpace_pile), [N 1]);
SampN = sampSpace_pile(inds);
