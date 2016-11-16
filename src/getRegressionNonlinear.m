

function nonlinear = getRegressionNonlinear(m, vid)

  % svm regressor library
  %addpath('../libsvm-3.1/matlab');
  %addpath('/projects/vision/4/bburns/code/libsvm-3.1/matlab');
  addpath('util/libsvm-3.1/matlab');


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


  % train SVM

  labels = y;
  instances = [x1 x2 x3];

  % scale data
  mins = min(instances);
  maxs = max(instances);
  instances = scaleData(instances);

  % pick best values for parameters c and gamma
  % this doesn't show any improvement over default values for the segtrack dataset
%  bestcv = 0;
%  for log2c = -1:3,
%    for log2g = -4:1,
%      cmd = ['-s 3 -t 2 -v 3 -c ', num2str(2^log2c), ' -g ', num2str(2^log2g)];
%      cv = svmtrain(labels, instances, cmd);
%      if (cv >= bestcv),
%        bestcv = cv; bestc = 2^log2c; bestg = 2^log2g;
%      end
%      fprintf('%g %g %g (best c=%g, g=%g, rate=%g)\n', log2c, log2g, cv, bestc, bestg, bestcv);
%    end
%  end


  % train the svm
  % model = svmtrain(training_label_vector, training_instance_matrix [, 'libsvm_options']);
  %      -training_label_vector:
  %          An m by 1 vector of training labels (type must be double).
  %      -training_instance_matrix:
  %          An m by n matrix of m training instances with n features.
  %          It can be dense or sparse (type must be double).
  %      -libsvm_options:
  %          A string of training options in the same format as that of LIBSVM.
  % model = svmtrain(labels, instances, 'cmdline params')
  % s3 = epsilon SVR (support vector regression)
  % t2 = RBF (radial basis function kernel) (recommended)
  %
  % -c cost : set the parameter C of C-SVC, epsilon-SVR, and nu-SVR (default 1)
  % -g gamma : set gamma in kernel function (default 1/num_features)
  % -p epsilon : set the epsilon in loss function of epsilon-SVR (default 0.1)

%  cmd = ['-s 3 -t 2 -c ' num2str(bestc) ' -g ' num2str(bestg) ]
  cmd = '-s 3 -t 2';
  model = svmtrain(labels, instances, cmd)



  % test nonlinear regressor
  labels = ytest;
  instances = [x1test x2test x3test];

  % scale the test data in the same way as the training data
  for i=1:3
    instances(:,i) = (instances(:,i)-mins(i)) / (maxs(i)-mins(i));
  end

  % note: for testing, you can put anything into the labels vector. 
  % see the libsvm/matlab readme. 
  % note: predictedLabels and decvalues are the same thing...
  [predictedLabels, accuracy, decvalues] = svmpredict(labels, instances, model);
  Y = predictedLabels; % this is our predicted objectness score
  nonlinear = Y;

end



% scale data to [0,1]
function dataScaled = scaleData(data)

  % The following one-line code scale each feature to the range of [0,1]:
  % (data - repmat(min(data,[],1),size(data,1),1)) * spdiags(1./(max(data,[],1)-min(data,[],1))', 0,size(data,2),size(data,2))
  dataScaled = (data - repmat(min(data,[],1),size(data,1),1)) * spdiags(1./ (max(data,[],1)-min(data,[],1))' , 0, size(data,2), size(data,2));

end