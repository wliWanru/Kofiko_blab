function ImageParameter = ContrastBorderOwner(ImageParameter);
ImageParameter.ImageKind = 3;
ImageParameter.Parameter_Name{1} = 'SurfaceColor';
ImageParameter.Parameter_Name{2} = 'BackgroundColor';
ImageParameter.Parameter_Name{3} = 'StimulusPos';
ImageParameter.Cond_Name = {'p11','p12','p21','p22'};
ImageParameter.Parameter_Value{1} = [0 128 128 0]';
ImageParameter.Parameter_Value{2} = repmat([128 0 0 128]',1,3);
theta = mod(ImageParameter.Orientation/180*pi,pi);
pos(1:2,:) = repmat([ImageParameter.StimulusPos]-[cos(pi/2+theta) sin(pi/2+theta)]*ImageParameter.StimulusSizePix_Y/2,2,1);
pos(3:4,:) = repmat([ImageParameter.StimulusPos]+[cos(pi/2+theta) sin(pi/2+theta)]*ImageParameter.StimulusSizePix_Y/2,2,1);
ImageParameter.Parameter_Value{3} = pos([1 4 2 3],:);

ImageParameter.DefaultValue.StimulusON_MS = 500;
ImageParameter.DefaultValue.StimulusOFF_MS = 500;
ImageParameter.DefaultValue.BackgroundColor = [172 172 172];
