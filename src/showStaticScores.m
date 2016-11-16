
% showStaticScores.m
% make a plot showing static scores from endres code


video = 3;
frame = 1;
region = 1;

% data sources
datadir         = '/projects/vision/4/bburns/datasets/segtrack/';
regionbase      = '/scratch/vision/yjlee/videoSegmentation/SegTrack/data/regionProposals/endresUnary/';
opticalflowbase = '/scratch/vision/yjlee/videoSegmentation/SegTrack/data/opticalFlow/';

vidnames = dir(datadir);
videoName = vidnames(video+2).name; % +2 for . and ..

imdir           = [datadir videoName '/'];
gtdir           = [imdir 'ground-truth/'];
scoresdir       = [imdir 'scores/'];
regiondir       = [regionbase videoName '/'];
opticalflowdir  = [opticalflowbase videoName '/'];

% get frame image
imfiles = dir(imdir);
imname1 = imfiles(frame+2).name; % +2 for . and ..
imname2 = imfiles(frame+3).name;
imfile = [imdir imname1];
im = imread(imfile);

% get groundtruth image
gtfiles = dir(gtdir);
gtname = [gtdir gtfiles(frame+2).name];
gt = imread(gtname);
gt = im2bw(gt, 0.5); % convert to binary mask

% get region data
regionfile = [regiondir imname1 '.mat'];
load(regionfile, 'proposals', 'superpixels', 'unary')

plot(unary);
title('static scores from endres code');
xlabel('region');
ylabel('score');


