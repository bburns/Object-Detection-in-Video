
% get motion1 cue - difference in histograms of optical flow
% code extracted from getAppMotionRegionScores.m
% called from getAppMotionRegionScores.m
% author: yjlee

function [motion1Score, xmin, xmax, ymin, ymax] = getMotionCue1(regionmap, vx, vy)

  % libraries
  addpath('/v/filer4b/v37q001/yjlee/project/');

  % parameters
  bdryPix = 30;
  flowBinEdges = [-15:0.5:15];


  [nr, nc, z] = size(regionmap);

  %. doesn't this just duplicate regionmap? or convert it to uint? 
  Seg = zeros(nr,nc);   
  Seg(regionmap) = 1;

  %%%%%%%%%%%%%%%%%%%%%%
  %% get bbox region of interest    
  [y,x] = find(Seg==1);

  minx = min(x); maxx = max(x);
  miny = min(y); maxy = max(y);

  tbdry = max(miny-bdryPix,1);
  bbdry = min(maxy+bdryPix,nr);
  lbdry = max(minx-bdryPix,1);
  rbdry = min(maxx+bdryPix,nc);

  ROISeg = Seg(tbdry:bbdry, lbdry:rbdry);
  fg_inds = find(ROISeg==1);
  bg_inds = find(ROISeg==0);
  %%%%%%%%%%%%%%%%%%%%%%

  %%%%%%%%%%%%%%%%%%%%%%
  %% get fg bg region optical flow histograms    
  ROIvx = vx(tbdry:bbdry, lbdry:rbdry); 
  ROIvy = vy(tbdry:bbdry, lbdry:rbdry); 

  fg_flow_hist = normalizeFeats([histc(ROIvx(fg_inds), flowBinEdges); histc(ROIvy(fg_inds), flowBinEdges)]');
  bg_flow_hist = normalizeFeats([histc(ROIvx(bg_inds), flowBinEdges); histc(ROIvy(bg_inds), flowBinEdges)]');

  flowDist = pdist2(fg_flow_hist,bg_flow_hist,'chisq');        
  flowAffinity = exp(-flowDist);    
  %%%%%%%%%%%%%%%%%%%%%%  

  motion1Score = 1 - flowAffinity;

  xmin = lbdry; xmax = rbdry;
  ymin = bbdry; ymax = tbdry;

end

