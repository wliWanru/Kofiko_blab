function ImageParameter = BarSmallField(ImageParameter);
ImageParameter.ImageKind = 3;
ImageParameter.Parameter_Name{1} = 'StimulusPos';
dist = -200:20:200;
theta = mod(ImageParameter.Orientation/180*pi,pi);
for i = 1:length(dist)
    pp(i,:) = [ImageParameter.StimulusPos]-[cos(pi/2+theta) sin(pi/2+theta)]*(dist(i));
    ImageParameter.Cond_Name{i} = num2str(dist(i));
end
ImageParameter.Parameter_Value{1} = pp;

ImageParameter.DefaultValue.StimulusON_MS = 500;
ImageParameter.DefaultValue.StimulusOFF_MS = 500;
ImageParameter.DefaultValue.BackgroundColor = [172 172 172];
