
% getScores.m
% Get the static and motion scores, the overlap with the ground 
% truth, for all videos and frames, and save them to a matrix 
% for doing regression on.
% Assumes the regions and optical flows have already been found 
% and stored in the proposals and opticalFlow subfolders. 
% Each video will get a scores.mat file, stored in the scores subdir. 
% To gather all scores into one matrix, see gatherScores.m. 
% author: bburns


% libraries
addpath(        '/v/filer4b/v37q001/yjlee/project/');
addpath(genpath('/v/filer4b/v17q003/yjlee/code/GMM-GMR-v2.0/GMM-GMR-v2.0/'));
addpath(genpath('/v/filer4b/v17q003/yjlee/code/gcmex-2.3.0/'));
addpath(        '/v/filer4b/v17q003/yjlee/code/sliding_segments/');
addpath(        '/v/filer4b/v37q001/yjlee/research/pwmetric/');

% parameters
% skip: number of video frames to skip during processing

%skip = 1; % do all frames
%skip = 2;
skip = 5; 
%skip = 10;
%skip = 25; % just do one frame

% datafiles
datadir         = '/projects/vision/4/bburns/datasets/segtrack/';
regionbase      = '/scratch/vision/yjlee/videoSegmentation/SegTrack/data/regionProposals/endresUnary/';
opticalflowbase = '/scratch/vision/yjlee/videoSegmentation/SegTrack/data/opticalFlow/';

for vid = 1:6 

  % location of video
  dirs = dir([datadir]);
  videoName = dirs(vid+2).name; % +2 for . and ..
  imdir = [datadir videoName '/'];

  % location for scores.mat
  scoresdir = [imdir 'scores/'];
  if ~exist(scoresdir,'dir')
    mkdir(scoresdir);
  end

  display(['video ' num2str(vid) ': ' videoName]);
  tic;

  % get static score, motion scores, and overlap scores
  [combinedScores, staticScores, motion1Scores, motion2Scores, overlapScores, frameIndex, regionIndex] = getAppMotionRegionScores(videoName, skip);

  % save all scores to scores.mat
  save('-v7', [scoresdir 'scores.mat'], 'staticScores', 'motion1Scores', 'motion2Scores', 'overlapScores', 'frameIndex', 'regionIndex');

  toc;
  fprintf('\n');

end % vid

