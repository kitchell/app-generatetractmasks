function fg_clean = AFQ_clean(fg_classified)

% cleans the fiber tracts with AFQ_removeFiberOutliers

maxDist = 4;

maxLen = 4;

%numNodes = 30;
numNodes = 100;

M = 'mean';

maxIter = 5;

count = true;


for ii = 1:length(fg_classified)
    fg_clean(ii) = AFQ_removeFiberOutliers(fg_classified(ii), maxDist, maxLen, numNodes, M, count, maxIter);
end

end
