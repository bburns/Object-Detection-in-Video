
% Get static scores, motion scores, and overlap scores for a video.
% This gets called by getScores.m
% This version adds the new motion cue also. 
% author: yjlee, bburns

function [combinedScores, staticScores, motion1Scores, motion2Scores, overlapScores, frameIndex, regionIndex] = getAppMotionRegionScores(videoName, skip)


% libraries
%addpath('/v/filer4b/v37q001/yjlee/project/');


% data directories
datadir         = '/projects/vision/4/bburns/datasets/segtrack/';
regionbase      = '/scratch/vision/yjlee/videoSegmentation/SegTrack/data/regionProposals/endresUnary/';
opticalflowbase = '/scratch/vision/yjlee/videoSegmentation/SegTrack/data/opticalFlow/';

imdir           = [datadir videoName '/'];
gtdir           = [imdir 'ground-truth/'];
regiondir       = [regionbase videoName '/'];
opticalflowdir  = [opticalflowbase videoName '/'];

% get image files and ground truth files
imtype = getImageType(imdir);
imfiles = dir([imdir '*.' imtype]);

gttype = getImageType(gtdir);
gtfiles = dir([gtdir '*.' gttype]);


staticScores = [];
motion1Scores = [];
motion2Scores = [];
overlapScores = [];
frameIndex = [];
regionIndex = [];

%t1 = 0;
%t2 = 0;

% iterate over frames
for i = 1:skip:length(imfiles)-1;
    
    imname1 = imfiles(i).name;
    imname2 = imfiles(i+1).name;
    
    im = imread([imdir imname1]); 

    % get ground truth as binary mask
    gtname = [gtdir gtfiles(i).name]; 
    gt = imread(gtname);
    gt = im2bw(gt, 0.5); % convert to binary mask


    % load regions, superpixels and static scores
    segname = [regiondir imname1 '.mat'];
    load(segname, 'proposals', 'superpixels', 'unary');
    

    % load or create optical flow maps
    flowFile = [opticalflowdir imname1 '_to_' imname2 '.opticalflow.mat'];
%    try
        load(flowFile,'vx','vy');
%    catch
%        im1 = double(imread([imdir imname1]));
%        im2 = double(imread([imdir imname2]));
%        flow = mex_LDOF(im1,im2);
%        vx = flow(:,:,1);
%        vy = flow(:,:,2);
%    end
    

    % find best region proposals
    diffUnary = diff(unary,1,1);
    ind = find(diffUnary>0,1);
    proposals = proposals(1:ind);

    % save those static scores to array
    staticScores = [staticScores; unary(1:ind)];
    
    N = length(proposals);
    motion1Row = zeros(N,1);
    motion2Row = zeros(N,1);
    overlapRow = zeros(N,1);

    fprintf('frame %i: %i regions\n', i, N);

    % iterate over best regions, calculate motion score and overlap for each
    for j=1:N    

        % get region mask
        regionmap = ismember(superpixels, proposals{j});

        % get overlap score, add to list (overlap = intersection / union)
        intersection = gt & regionmap;
        union = gt | regionmap;
        overlapScore = nnz(intersection) / nnz(union);

        % plot the gt and region and show overlap score
%        imagesc(gt);
%        colormap gray;
%        hold on;
%        boundaries = bwboundaries(regionmap);
%        b = boundaries{1};
%        scatter(b(:,2),b(:,1),4,'g');
%        overlapScore
%        pause

        % motion1: difference of histograms of optical flow
%        tic;
        motion1Score = getMotionCue1(regionmap, vx, vy);
%        t1 = t1 + toc;

        % motion2: difference of optical flow around boundary
%        tic;
        motion2Score = getMotionCue2(regionmap, vx, vy);
%        t2 = t2 + toc;

        motion1Row(j) = motion1Score;
        motion2Row(j) = motion2Score;
        overlapRow(j) = overlapScore;

    end

    motion1Scores = [motion1Scores; motion1Row];
    motion2Scores = [motion2Scores; motion2Row];
    overlapScores = [overlapScores; overlapRow];
    frameIndex = [frameIndex; i*ones(N,1)];
    regionIndex = [regionIndex; (1:N)'];

end


nregions = size(staticScores, 1);
display(['total: ' num2str(nregions) ' regions']);
%display(['t1: ' num2str(t1)]);
%display(['t2: ' num2str(t2)]);


% normalize all to same scale
staticScores = zscore(staticScores);
motion1Scores = zscore(motion1Scores);
motion2Scores = zscore(motion2Scores);


% combine scores for objectness ranking

% straight combination
%combinedScores = staticScores + motion1Scores;
combinedScores = staticScores + motion1Scores + motion2Scores;

% linear regression combination
%coeffs = [0.028 0.022 0.015 0.021]'; % avg values from all 6 segtrack videos
%nScores = size(staticScores,1);
%combinedScores = [ones(nScores,1) staticScores motion1Scores motion2Scores] * coeffs;

% nonlinear regression combination
% use model to predict objectness scores
% see getRegressionNonlinear.m for example of how to do this
% would train a model from some dataset, eg all the segtrack videos, and save it. 
% load('model.mat', 'model');
% would also need to save the scaling factors to apply to the instance data. 
% labels can be anything
%instances = [staticScores motion1Scores motion2Scores];
% then scale them the same way the training data was scaled
%[predictedLabels, accuracy, decvalues] = svmpredict(labels, instances, model);

end

