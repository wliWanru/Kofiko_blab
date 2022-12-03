function ImageParameter = RDSDepth(ImageParameter);
        ImageParameter.ImageKind = 5;
        ImageParameter.Parameter_Name{1} = 'Depth';
        ImageParameter.StimulusPos = ImageParameter.StimulusPos- ImageParameter.ScreenCenter;
        theta = mod(ImageParameter.Orientation/180*pi,pi);
        ImageParameter.Parameter_Value{1} = -10:2:10

     for i = 1:length(ImageParameter.Parameter_Value{1});
            ImageParameter.Cond_Name{i} = num2str(ImageParameter.Parameter_Value{1}(i));
     end
ImageParameter.DefaultValue.StimulusON_MS = 500;
ImageParameter.DefaultValue.StimulusOFF_MS = 500;
ImageParameter.DefaultValue.BackgroundColor = [0 0 0];

