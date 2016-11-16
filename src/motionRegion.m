
% motionRegion.m
% extract regions based on motion


% parameters
video=2;frame=21;region=19;
video=1;

% data sources
datadir         = '/projects/vision/4/bburns/datasets/segtrack/';
regionbase      = '/scratch/vision/yjlee/videoSegmentation/SegTrack/data/regionProposals/endresUnary/';
opticalflowbase = '/scratch/vision/yjlee/videoSegmentation/SegTrack/data/opticalFlow/';

vidnames = dir(datadir);
videoName = vidnames(video+2).name; % +2 for . and ..

imdir            = [datadir videoName '/'];
gtdir            = [imdir 'ground-truth/'];
scoresdir        = [imdir 'scores/'];
regiondir        = [regionbase videoName '/'];
opticalflowdir   = [opticalflowbase videoName '/'];
%regiondir       = [imdir 'proposals/'];
%opticalflowdir  = [imdir 'opticalFlow/'];

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

%for region=1:100

% get a region bitmap
proposal = proposals{region};
regionmap = ismember(superpixels, proposal);

% get overlap score
%intersection = gt & regionmap;
%union = gt | regionmap;
%overlap = nnz(intersection) / nnz(union);

% get optical flow vectors
flowFile = [opticalflowdir imname1 '_to_' imname2 '.opticalflow.mat'];
load(flowFile,'vx','vy');

% get motion cues and plot data
%[motion1, xmin, xmax, ymin, ymax] = getMotionCue1(regionmap, vx, vy);
%[motion2, boundary, edges, testpoints] = getMotionCue2(regionmap, vx, vy);

dirs = atan2(vy,vx);
mags = vx .^ 2 + vy .^ 2;

ofmin = min(min(mags));
ofmax = max(max(mags));

%for theta = 0.2:0.1:0.8
for theta = 0.5:0.5

  regs = zeros(size(mags));
  th = ofmin + theta * (ofmax - ofmin);
  inds = find(mags>th);
  regs(inds) = 1;

  % find connected components (blobs)
  cc = bwconncomp(regs);

  % for each blob, make a new regionmap and plot it
  for i=1:cc.NumObjects
    regionmap = zeros(size(mags));
    regionmap(cc.PixelIdxList{i}) = 1;
    figure;
    imagesc(regionmap);
    colormap gray;

    % intersect with superpixels map to find out what
    % superpixels make up the region
    % (not perfect, but would make it easier to 
    % integrate with endres's code)
    sp = superpixels .* regionmap;
    sps = unique(sp(:));
    % add to cell of regions
%    regions{i} = sps;

  end % i

end % theta




