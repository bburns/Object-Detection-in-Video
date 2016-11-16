
% Gather all the calculated static and motion and overlap scores
% for all the regions of all the videos,
% and put them into a single matrix. 
% Do this after running getScores.m
% author: bburns


% libraries
%addpath(genpath('/projects/vision/2/yjlee/code/proposals'))

% data files
datadir = '/projects/vision/4/bburns/datasets/segtrack/';


m = [];

for vid = 1:6

  % location of videos
  dirs = dir([datadir]);
  videoName = dirs(vid+2).name; % +2 for . and ..

  display(['video: ' videoName]);

  % load scores for this video
  imdir     = [datadir videoName '/'];
  scoresdir = [imdir 'scores/']; 
  load([scoresdir 'scores.mat'], 'overlapScores', 'staticScores', 'motion1Scores', 'motion2Scores', 'frameIndex', 'regionIndex');

  % append scores to matrix m, along with video number
  nrows = size(staticScores,1);
  videonum = vid * ones(nrows,1);
  mnew = [videonum, frameIndex, regionIndex, overlapScores, staticScores, motion1Scores, motion2Scores];
  m = [m; mnew];

end % vid

% save matrix to file
save('scoresAll.mat', 'm');


