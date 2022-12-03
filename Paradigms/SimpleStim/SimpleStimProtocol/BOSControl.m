function ImageParameter = BOSControl(ImageParameter);
ImageParameter.ImageKind = 3;
ImageParameter.Parameter_Name{1} = 'SurfaceColor';
ImageParameter.Parameter_Name{2} = 'BackgroundColor';

ImageParameter.Cond_Name = {'p11','p12'};
ImageParameter.Parameter_Value{1} = [0 128]';
ImageParameter.Parameter_Value{2} = repmat([128 0]',1,3);

ImageParameter.DefaultValue.StimulusON_MS = 500;
ImageParameter.DefaultValue.StimulusOFF_MS = 500;
ImageParameter.DefaultValue.BackgroundColor = [172 172 172];
