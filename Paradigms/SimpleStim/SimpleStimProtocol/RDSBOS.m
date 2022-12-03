function ImageParameter = RDSBOS(ImageParameter);
ImageParameter.ImageKind = 5;
ImageParameter.Parameter_Name{1} = 'StimulusPos';
ImageParameter.Parameter_Name{2} =  'Depth';
theta = mod(ImageParameter.Orientation/180*pi,pi);
ImageParameter.StimulusPos = ImageParameter.StimulusPos- ImageParameter.ScreenCenter
pos(1:2,:) = repmat([ImageParameter.StimulusPos]-[cos(pi/2+theta) sin(pi/2+theta)]*ImageParameter.StimulusSizePix_Y/2,2,1);
pos(3:4,:) = repmat([ImageParameter.StimulusPos]+[cos(pi/2+theta) sin(pi/2+theta)]*ImageParameter.StimulusSizePix_Y/2,2,1);
ImageParameter.Parameter_Value{2} = [ImageParameter.Depth -ImageParameter.Depth  -ImageParameter.Depth  ImageParameter.Depth]';
ImageParameter.Parameter_Value{1} = pos([1 4 2 3],:);;
ImageParameter.Cond_Name = {'p11','p12','p21','p22'};

ImageParameter.DefaultValue.StimulusON_MS = 500;
ImageParameter.DefaultValue.StimulusOFF_MS = 500;
ImageParameter.DefaultValue.BackgroundColor = [0 0 0];
