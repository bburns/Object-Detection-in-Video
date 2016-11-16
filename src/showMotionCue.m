
% showMotionCue.m
% show motion cues against optical flow background.
% bgopt determines what portion of optical flow is shown in background.
% 0=none, 1=direction, 2=magnitude, 3=vx, 4=vy. 
% and can reverse sign to get reverse values
% author: bburns
 
   
function showMotionCue(video, frame, region, bgopt)

  showMotion1 = true;
  showMotion2 = true;
  %showMotion1 = false;

  if nargin < 4
    bgopt = 2;
  end

  % can show one of these in the background
  showdir=0;showmag=0;showvx=0;showvy=0;

  if abs(bgopt)==1, showdir=sign(bgopt); end
  if abs(bgopt)==2, showmag=sign(bgopt); end
  if abs(bgopt)==3, showvx=sign(bgopt); end
  if abs(bgopt)==4, showvy=sign(bgopt); end

  optnames = {'direction','magnitude','vx','vy'};

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

  % get a region bitmap
  proposal = proposals{region};
  regionmap = ismember(superpixels, proposal);

  % get overlap score
  intersection = gt & regionmap;
  union = gt | regionmap;
  overlap = nnz(intersection) / nnz(union);

  % get optical flow vectors
  flowFile = [opticalflowdir imname1 '_to_' imname2 '.opticalflow.mat'];
  load(flowFile,'vx','vy');

  % get motion cues and plot data
  [motion1, xmin, xmax, ymin, ymax] = getMotionCue1(regionmap, vx, vy);
  [motion2, boundary, edges, testpoints] = getMotionCue2(regionmap, vx, vy);

  % show image with region boundary
  %figure;
  clf;
  subplot(121);
  imshow(im);
  title(['video ' num2str(video) ', frame ' num2str(frame) ', region ' num2str(region)]);
  hold on;

  % plot region in green outline
  plot(boundary(:,2),boundary(:,1),'g','LineWidth',2);

  % plot edges
  subplot(122);
  edges = 1-edges;
  imagesc(edges);
  title(['region against optical flow ' optnames{abs(bgopt)}]);
  colormap gray;
  axis image;

  hold on;

  % show optical flow in background
  if showdir
    dirs = atan2(vy,vx);
    imshow(showdir * dirs,[]);
    colormap hsv;
  end
  if showmag
    mags = sqrt(vx .^ 2 + vy .^ 2);
    imshow(showmag * mags,[]);
  end
  if showvx
    imshow(showvx * vx, []);
  end
  if showvy
    imshow(showvy * vy, []);
  end

  % show region edge
  %plot(boundary(:,2),boundary(:,1),'white','LineWidth',1);
  plot(boundary(:,2),boundary(:,1),'black','LineWidth',1);

  % show motion1 bounding box
  if showMotion1
    line([xmin xmax], [ymin ymin],'Color','red');
    line([xmin xmax], [ymax ymax],'Color','red');
    line([xmin xmin], [ymin ymax],'Color','red');
    line([xmax xmax], [ymin ymax],'Color','red');
  end

  % show motion2 inner/outer points
  if showMotion2
    scatter(testpoints(:,1),testpoints(:,2),8,'r'); % inner
    scatter(testpoints(:,3),testpoints(:,4),8,'g'); % outer

    % draw connecting line between inner/outer points
    for testpoint = testpoints'
      h = line([testpoint(1),testpoint(3)], [testpoint(2),testpoint(4)]);
      set(h, 'Color','blue');
    end
  end

  % show scores
  %txt(1) = {['motion1: ' num2str(motion1)]};
  %txt(2) = {['motion2: ' num2str(motion2)]};
  %txt(3) = {['overlap: ' num2str(overlap)]};
  txt = ['motion1: ' num2str(motion1) ', motion2: ' num2str(motion2) ', overlap: ' num2str(overlap)];
  %text(10, 10, ['motion2: ' num2str(motion2) ', overlap: ' num2str(overlap)], 'Color','black');
  text(10, 10, txt, 'Color','black');

end

