function ImageParameter = RF(ImageParameter);
ImageParameter.ImageKind = 3;
ImageParameter.Parameter_Name{1} = 'SurfaceColor';
ImageParameter.Parameter_Value{1} = [0 255 ]';
ImageParameter.Cond_Name = {'Black', 'White'};

% Default Value
ImageParameter.DefaultValue.StimulusON_MS = 250;
ImageParameter.DefaultValue.StimulusOFF_MS = 250;
ImageParameter.DefaultValue.StimulusSizePix_X = 10;
ImageParameter.DefaultValue.StimulusSizePix_Y = 10;
ImageParameter.DefaultValue.Orientation = 0;
ImageParameter.DefaultValue.BackgroundColor = [172 172 172];

