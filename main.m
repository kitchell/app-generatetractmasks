function main()

% Takes in the output from AFQ, converts it to a resampled volume and then
% smooths the resultant volume object.  Outputs a nifti for both the
% voxel-wise density of the fibers and a boolean mask of the fiber volume.
%
% voxelResize = .7
% threshold = 2
% smoothBool = 1


switch getenv('ENV')
    case 'IUHPC'
        disp('loading paths (HPC)')
        addpath(genpath('/N/u/brlife/git/jsonlab'))
        addpath(genpath('/N/u/brlife/git/vistasoft'))
        addpath(genpath('/N/u/brlife/git/afq-master'))
        addpath(genpath('/N/u/kitchell/Karst/Applications/iso2mesh'))
    case 'VM'
        disp('loading paths (VM)')
        addpath(genpath('/usr/local/jsonlab'))
        addpath(genpath('/usr/local/iso2mesh'))
        addpath(genpath('/usr/local/vistasoft'))
        addpath(genpath('/usr/local/afq-master'))
end

% load config.json
config = loadjson('config.json');

disp('config dump')
disp(config)

mkdir('masks')

T1 = niftiRead(config.T1);

load(config.afq_fg);

if config.clean_afq
    fg_classified = AFQ_clean(fg_classified);
end

eval(sprintf('!NUMFILES=$d', length(fg_classified)));

cm = parula(length(fg_classified));

thresholdPercent = 20;
%islandFlag       = false;
smoothKernel     = [3 3 3];
voxelResize = config.voxelResize;

for ifg=1:length(fg_classified)
    color_json(ifg).name = fg_classified(ifg).name;
    color_json(ifg).color = cm(ifg,:);
    fg = fg_classified(ifg);
    if isempty(fg.fibers)
        continue
    end
    %changes from acpc to image space
    for ifibers=1:length(fg.fibers)
        fg.fibers{ifibers}=mrAnatXformCoords(T1.qto_ijk, fg.fibers{ifibers})';
        
    end
    
    fiberBoolNifti = T1;
    imgDim         = T1.dim(1:3);
    imgRes         = T1.pixdim(1,1);
    imgResize      = imgDim*imgRes;
    imgBins        = ceil(imgResize/voxelResize);
    emptyMatrix    = zeros(imgBins);
    
    
    
    % adjusts nifti object field information (probably not necessary)
    fiberBoolNifti.dim       = imgBins;
    fiberBoolNifti.pixdim    = [voxelResize voxelResize voxelResize];
    fiberBoolNifti.qoffset_x = fiberBoolNifti.qoffset_x*(imgRes/voxelResize);
    fiberBoolNifti.qoffset_y = fiberBoolNifti.qoffset_y*(imgRes/voxelResize);
    fiberBoolNifti.qoffset_z = fiberBoolNifti.qoffset_z*(imgRes/voxelResize);
    
    
    
    for ifibers = 1:length(fg.fibers)
        roundedExpandedTract = round(fg.fibers{ifibers}*(imgRes/voxelResize));
        
        for inodes = 1:length(fg.fibers{ifibers})
            emptyMatrix(  roundedExpandedTract(1,inodes), ...
                roundedExpandedTract(2,inodes), ...
                roundedExpandedTract(3,inodes))= ...
                emptyMatrix(  roundedExpandedTract(1,inodes), ...
                roundedExpandedTract(2,inodes), ...
                roundedExpandedTract(3,inodes)) +1;
        end
    end
    
    %duplicates object
    %fiberDensityNifti=fiberBoolNifti;
    
    %% compute DiffusivityRatio of fg
    % The "diffusivity ratio" of a fg (not a technical term, has nothing to do
    % with the FA or anything) is the ratio of voxels with more than one node
    % in them to the total number of non zero voxels.  Presumably, this is a
    % measure of how "dense" the fg is.  If there are very few voxels with
    % multiple nodes then this means that there may not be a very dense
    % representation of the fiber.  Basically, I am developing this ratio as a
    % potential benchmark for the viability of the volumes/surfaces we are
    % developing.  My sense is that there may be some ratio value that would
    % reliably lead to better printing outcomes.
    
    %     moreThanOneNode  = length(find(emptyMatrix>1));
    %     nonZeroNode      = length(find(emptyMatrix>0));
    %     DiffusivityRatio = moreThanOneNode/nonZeroNode;
    
    
    %% actually do smoothing if necessary
    % smooths if necessary.  In theory de-islands as well, though I've never
    % seen it in action.  It is set to go to keyboard if it detects islands.
    % It could be that the function to detect islands is broken, so this may
    % simply be pointless.
    if config.smooth
        smoothData = smooth3(emptyMatrix,'gaussian',smoothKernel);
        % auto threshold computation
        % computes the appropriate threshold for the given percentile value.
        % Probably not computationally efficient, but principled (aside from the
        % arbitrary threshold) and adaptive to the specific case.
        uniqueVals = unique(smoothData);
        
        % calculate bin interval according to uniquevals
        binz       = 0:(uniqueVals(end)/10000):uniqueVals(end);
        
        % is there something wrong here with the calculation of the second bin?
        hisDist    = histcounts(smoothData,binz);
        
        % count of nonzero entries, used for percentile calculation later
        nonZeroTotal = sum(hisDist(2:end));
        
        % loop to calculate cumulative sum of distribution
        for ibins = 1:length(hisDist)
            if ibins == 1
                cumulativeSums(ibins) = 0;
            else
                cumulativeSums(ibins) = cumulativeSums(ibins-1)+hisDist(ibins);
            end
        end
        % calculate percentiles
        percentiles = (cumulativeSums / nonZeroTotal)*100;
        failureVec  = (percentiles > thresholdPercent);
        
        % find corresponding bin value
        thresholdBinVal = binz(find(failureVec, 1 ));
        
        %the bwislands is currently returning an empty output for me, at least
        %on this test fiber.   I'm not sure if that means there are no islands
        %to be found for this fiber, or if the function doesn't work.  This
        %part may cause a problem at some point.
        %         islands = bwislands(smoothData);
        %         if ~isempty(islands)
        %             islandFlag = true;
        %             smoothData = deislands3d(smoothData,3);
        %         end
        
        boolMatrixVersion=smoothData>thresholdBinVal;
        fiberBoolNifti.data=boolMatrixVersion;
    else
        boolMatrixVersion   = emptyMatrix>config.threshold;
        fiberBoolNifti.data = boolMatrixVersion;
    end
    
    % convert to unit8 from bool (necessary for niftiSave function)
    fiberBoolNifti.data = uint8(fiberBoolNifti.data);
    
    % fiberdensityNifti may be useless at this point because it is unsmoothed,
    % and the indexing done by boolmatrixversion is going to index a great deal
    % of empty voxels in the sparser, unsmoothed emptyMatrix object.
    %
    % fiberDensityNifti.data=emptyMatrix(boolMatrixVersion);
    %
    % Update:  now just saving the smoothed object.
    %     fiberDensityNifti.data = smoothData(boolMatrixVersion);
    
    boolSaveName=strcat('masks/',fg.name, '_Vol.nii.gz');
    boolSaveName = strrep(boolSaveName, ' ', '_');
    %     densitySaveName=strcat(saveDir,'/', num2str(subj), '_', fg.name, '_densityVol.nii.gz');
    %     densitySaveName = strrep(densitySaveName, ' ', '_');
    niftiWrite(fiberBoolNifti,boolSaveName);
    %     niftiWrite(fiberDensityNifti,densitySaveName);
    fprintf(strcat('\n Done with ', fg.name, '\n'))
end

savejson('',color_json,'masks/color.json');
end
