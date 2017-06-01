function fg_clean = AFQ_clean(fg_classified)

% cleans the fiber tracts with AFQ_removeFiberOutliers

maxDist = 4;

maxLen = 4;

numNodes = 30;

M = 'mean';

maxIter = 1;

count = true;


for ii = 1:20
    fg_clean(ii) = AFQ_removeFiberOutliers(fg_classified(ii), maxDist, maxLen, numNodes, M, count, maxIter);
end

end