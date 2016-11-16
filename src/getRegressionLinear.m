

function [linear, coeffs] = getRegressionLinear(m, vid)

  % get indexes of rows with appropriate data
  iTrain = find(m(:,1)~=vid);
  iTest = find(m(:,1)==vid);

  % columns of m
  colVideo = 1;
  colFrame = 2;
  colRegion = 3;
  colOverlap = 4;
  colStatic = 5;
  colMotion1 = 6;
  colMotion2 = 7;

  % get training data
  v  = m(iTrain, colVideo);
  y  = m(iTrain, colOverlap); 
  x1 = m(iTrain, colStatic); 
  x2 = m(iTrain, colMotion1); 
  x3 = m(iTrain, colMotion2);

  % get test data
  vtest  = m(iTest, colVideo);
  ytest  = m(iTest, colOverlap); 
  x1test = m(iTest, colStatic); 
  x2test = m(iTest, colMotion1); 
  x3test = m(iTest, colMotion2);



  % the best fit is
  % Y = coeffs(1) + coeffs(2) * x1 + coeffs(3) * x2 + coeffs(4) * x3
  % so use that to predict objectness of some region
  % and use that to sort them and pick out the top 5 regions per frame
  X = [ones(size(x1))  x1  x2 x3];
  coeffs = X\y;
%  fprintf('coeffs');
%  coeffs

  X = [ones(size(x1test))  x1test  x2test x3test];
  Y = X * coeffs; % combined score
  linear = Y;


end
