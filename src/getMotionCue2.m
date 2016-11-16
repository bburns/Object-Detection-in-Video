
% contour motion detector
% looks at motion differences near boundaries of region
% called from getAppMotionRegionScores.m
% author: bburns

% regionmap - the binary region map
% vx, vy - the optical flow vector map

% distScaled - the motion difference, scaled from 0 to 1
% boundary - the boundary points (for plotting)
% edges - the edge map (for plotting)
% testPoints - the sample points (for plotting)

function [distScaled, boundary, edges, testpoints] = getMotionCue2(regionmap, vx, vy)

  % look on either sides of region boundary - 
  % large motion difference = more likely region is an object
  % start with region map
  % get list of pixels on edges
  % walk through them, getting perpendicular from edge gradient
  % pick inner/outer points
  % find direction and magnitude at those points
  % motion score += abs(difference)
  % scaled score = 1 - exp(-score)


  % parameters
  % skip: number of edge points to skip as go around boundary
  % offset: how far to go inward and outward from border to sample motion, in pixels

%  skip = 20;
  skip = 5;

%  offset = 8;
  offset = 6;



  [nr, nc, z] = size(regionmap);

  % get coordinates of edge pixels
  % boundaries is a p x 1 cell array, p = number of objects found
  % b is a q x 2 array, where q = number of pixels on border,
  % and each row is y,x coordinates of edge pixel
  boundaries = bwboundaries(regionmap);
  boundary = boundaries{1}; % our regions just have one object, so use the first one

  % get direction of edges
  % gv and gh are vertical and horizontal edge responses to the sobel 
  % gradient operators. 
  [edges,thresh,gv,gh] = edge(im2single(regionmap),'sobel');


  npoints = size(boundary,1);
  ntestpoints = round(npoints / skip) + 1;
  testpoints = zeros(ntestpoints,4);
  vouter = zeros(ntestpoints * 2,1);
  vinner = zeros(ntestpoints * 2,1);
  k = 1;

  % iterate over pixels on edge
  for i = 1:skip:npoints

      % get coordinates of edge point
      row = boundary(i,:);
      y = row(1);
      x = row(2);

      % get perpendicular to the gradient operators at the edge
      xdir = gv(y,x);
      ydir = gh(y,x);

      % normalize it
      d = norm([xdir ydir]);
      if d ~= 0
          xdir = xdir / d;
          ydir = ydir / d;
      end

      % find inner and outer sample points
      xinner = round(x - xdir * offset);
      yinner = round(y - ydir * offset);
      xouter = round(x + xdir * offset);
      youter = round(y + ydir * offset);

      % make sure they fit in image
      xinner = min(max(xinner, 1), nc);
      yinner = min(max(yinner, 1), nr);
      xouter = min(max(xouter, 1), nc);
      youter = min(max(youter, 1), nr);

      % get the optical flow at inner/outer points
      vxi = vx(yinner,xinner);
      vyi = vy(yinner,xinner);
      vxo = vx(youter,xouter);
      vyo = vy(youter,xouter);

      % append to the vectors
      vinner(k) = vxi;
      vouter(k) = vxo;
      vinner(ntestpoints + k) = vyi;
      vouter(ntestpoints + k) = vyo;

      % save points for plotting
      testpoints(k,1) = xinner;
      testpoints(k,2) = yinner;
      testpoints(k,3) = xouter;
      testpoints(k,4) = youter;

      k = k + 1;
  end

  % get distance between inner/outer vectors,
  % in average velocity per test point
  % absolute value seems to work better than the vector norm
  %%dist = sqrt(sum((vinner - vouter).^2)) / ntestpoints;
  %dist = norm(vinner - vouter, 2) / ntestpoints;
  diff = abs(vinner - vouter);
  dist = mean(diff);

  % get scaled velocity difference 0..1
  distScaled = 1 - exp(-dist);

end

