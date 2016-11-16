

% look for examples where m1 and m2 differ the most



load('scoresAll.mat');

% columns of m
colVideo = 1;
colFrame = 2;
colRegion = 3;
colOverlap = 4;
colStatic = 5;
colMotion1 = 6;
colMotion2 = 7;



colScore = 8;
m(:,colScore) = abs(m(:,colMotion2) - m(:,colMotion1));

m2 = sortrows(m,-colScore);
m2 = m;


display('video frame region overlap static motion1 motion2 score');

m2(1:20,:)
%icount = 0;



%for vid=1:6
for vid=3:3
  icount = 0;
  for row=1:2000
    video = m2(row,colVideo);
    if video==vid
      icount = icount + 1;
      frame = m2(row,colFrame);
      region = m2(row,colRegion);
      %showMotionCue(video,frame,region);
      %showMotionCue(video,frame,region,-2);
      for j=1:4
        showMotionCue(video,frame,region,-j);
        pause;
      end
    end
%    if icount>=3, break; end
    if icount>=100, break; end
  end
end



