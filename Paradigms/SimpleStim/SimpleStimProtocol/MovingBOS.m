function ImageParameter = MovingBOS(ImageParameter);
ImageParameter.ImageKind = 3;
ImageParameter.Parameter_Name{1} = 'SurfaceColor';
ImageParameter.Parameter_Name{2} = 'BackgroundColor';
ImageParameter.Parameter_Name{3} = 'StimulusPos';
for i = 1:11
        
    ImageParameter.Cond_Name{(i-1)*4+1} = ['shift_' num2str(i-6) '_top_black'];
        ImageParameter.Cond_Name{(i-1)*4+2} = ['shift_' num2str(i-6) '_bottom_white'];
    ImageParameter.Cond_Name{(i-1)*4+3} = ['shift_' num2str(i-6) '_top_white'];
    ImageParameter.Cond_Name{(i-1)*4+4} = ['shift_' num2str(i-6) '_bottom_black'];

   
end
ImageParameter.Parameter_Value{1} = repmat([0 128 128 0]',11,1);
ImageParameter.Parameter_Value{2} = repmat([128 0 0 128]',11,3);
theta = mod(ImageParameter.Orientation/180*pi,2*pi);

allpos = [];

shiftmagnitude = ImageParameter.StimulusSizePix_Y/2;

for i = linspace(-shiftmagnitude,shiftmagnitude,11);
    StimulusPos = ImageParameter.StimulusPos + [cos(pi/2+theta) sin(pi/2+theta)]*i;
    pos(1:2,:) = repmat(StimulusPos-[cos(pi/2+theta) sin(pi/2+theta)]*ImageParameter.StimulusSizePix_Y/2,2,1);
    pos(3:4,:) = repmat(StimulusPos+[cos(pi/2+theta) sin(pi/2+theta)]*ImageParameter.StimulusSizePix_Y/2,2,1);
    allpos = [allpos;pos([1 4 2 3],:)];
end

ImageParameter.Parameter_Value{3} = allpos;

ImageParameter.DefaultValue.StimulusON_MS = 500;
ImageParameter.DefaultValue.StimulusOFF_MS = 500;
ImageParameter.DefaultValue.BackgroundColor = [172 172 172];
