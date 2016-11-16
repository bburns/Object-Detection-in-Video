
% compareScores.m
% compare scores from static, motion1 and motion2 cues. 
% takes top k scores from each, 
% compares their overlap scores with the ground truth, 
% produces box plots
% author: bburns

   
% parameters
% k: compare the top k scores
% doNonlinear: turn nonlinear calcs on/off
% doBoxplot: 
% doCorrelation: 

%k = 10;
%k = 25;
k = 50;
%k = 100;

% turn this off if on 64-bit machine (libsvm not compiled for that yet)
doNonlinear = false;
%doNonlinear = true;

%doBoxplot = true;
doBoxplot = false;

%doCorrelation = not doBoxplot;

vidname = {'birdfall2','cheetah','girl','monkeydog','parachute','penguin'};

% columns of m
colVideo = 1;
colFrame = 2;
colRegion = 3;
colOverlap = 4;
colStatic = 5;
colMotion1 = 6;
colMotion2 = 7;

% combination columns
colSM1 = 8;
colSM2 = 9;
colLinear = 10;
colNonlinear = 11;

ndataCols = 6; % s,m1,m2,....
if doNonlinear 
  ndataCols = ndataCols + 1;
end

% load scores 
load('scoresAll.mat'); % m: video, frame, region, overlap, static, motion1, motion2

% get combinations
m(:,colSM1) = m(:,colStatic) + m(:,colMotion1);
m(:,colSM2) = m(:,colStatic) + m(:,colMotion2);

coeffsAll = zeros(6,4);

% do for each video
for vid=1:6

  mvid = selectRows(m, colVideo, vid);

  fprintf('video %d: %d overlap scores\n', vid, size(mvid,1));

  % add columns for linear and nonlinear regression
  [linear, coeffs] = getRegressionLinear(m, vid);
  mvid(:,colLinear) = linear;
  coeffsAll(vid,:) = coeffs';

  if doNonlinear
    nonlinear = getRegressionNonlinear(m, vid);
    mvid(:,colNonlinear) = nonlinear;
  end

  % create an empty table
  data = zeros(k,ndataCols+1);

  % get baseline column (just random selection of overlap scores)
  data(:,1) = randsample(mvid(:,colOverlap), k);

  % get data columns
  for j=1:ndataCols
    col = j+1;
    mcol = j+4;
    [y,i] = sortrows(mvid,-mcol); % sort scores in descending order
    data(:,col) = y(1:k,colOverlap); % get overlap scores for top k scores
  end

  if doBoxplot
    % show boxplot
    figure;
    if doNonlinear
      boxplot(data,'labels',{'baseline','static','motion1','motion2','s+m1','s+m2','linear','nonlinear'});
    else
      boxplot(data,'labels',{'baseline','static','motion1','motion2','s+m1','s+m2','linear'});
    end
    title(['video ' num2str(vid) ' (' vidname{vid} '): average overlap values for top ' num2str(k) ' scores']);
    ylim([0 1]);
  else

    % show correlation plots
    figure;
%    subplot(1,2,1);
    scatter(mvid(:,colMotion1),mvid(:,colOverlap),'rs'); % red square
    r1 = corr(mvid(:,colMotion1),mvid(:,colOverlap));
    hold on;
%    subplot(1,2,2);
    scatter(mvid(:,colMotion2),mvid(:,colOverlap),'b+');
    r2 = corr(mvid(:,colMotion2),mvid(:,colOverlap));
    ylim([0 1]);
    title(['video ' num2str(vid) ' (' vidname{vid} '): overlap vs motion scores']);
    xlabel('motion scores');
    ylabel('overlap with ground truth');
    legend(['motion1, r=' num2str(r1)],['motion2, r=' num2str(r2)]);
    legend('Location','Best');
    legend show;
  end

end




