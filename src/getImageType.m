
% getImageType.m
% return the type of images contained in the given directory


function imtype = getImageType(imdir)

  imtypes{1} = 'bmp';
  imtypes{2} = 'png';
  imtypes{3} = 'jpg';

  % try different image types until find right one
  for i = 1:3
    imtype = imtypes{i};
    d = dir([imdir '*.' imtype]);
    if length(d) > 2, break; end
  end

end
