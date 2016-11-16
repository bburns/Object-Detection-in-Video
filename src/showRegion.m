

% show example region with motion cue sample points


% change region number to get different proposals - 
% 1 is the 'best' proposal as determined by the endres code
% (ie has the highest static score)

%video=1;frame=1;region=39;
%video=1;frame=11;region=96;
%video=2;frame=16;region=8;
%video=2;frame=21;region=1;
%video=3;frame=1;region=1;bgopt=2;
%video=3;frame=3;region=1;bgopt=1;
%video=4;frame=2;region=1;
%video=4;frame=21;region=13;


%video=1;frame=16;region=129;showvy=true; % o=.56, m1=6, m2=10 [bird, good by both]
%video=4;frame=41;region=37; % example showing problem with frame border, worse for m2
%video=1;frame=6;region=120; % m1 beats m2

%video=1;frame=16;region=90; % m2 beats m1, but is it a bug? something with edge of frame? 
%video=1;frame=16;region=122;showvy=true; % m1 sees mpeg artifact as motion, m2 doesn't reach it
%video=1;frame=26;region=31;showvx=true; % another mpeg artifact? m1 very sensitive


%video=2;frame=21;region=27;showdir=true; % m2>m1. but m1 correctly picking up motion difference
%video=2;frame=21;region=19;%showdir=true; % m2>m1. but m1 correctly picking up motion difference


%showMotionCue(video, frame, region, bgopt);

%showMotionCue(2,21,10,2);
%showMotionCue(2,21,27,4);
%showMotionCue(1,1,136,-2);
%showMotionCue(1,26,135,1);
%showMotionCue(2,21,27,4);
showMotionCue(4,31,45,1);
%showMotionCue(3,16,9,2);



