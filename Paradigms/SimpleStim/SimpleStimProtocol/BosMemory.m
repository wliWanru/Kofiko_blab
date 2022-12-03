function ImageParameter = BOSMemory

ImageParameter.ImageKind = -1;
ImageParameter.StimulusSizePix_Y = 100;
ImageParameter.StimulusSizePix_X = 100;
ImageParameter.Orientation  = 0;

% ImageParameter.Parameter_Name{1} = 'SurfaceColor';
% ImageParameter.Parameter_Name{2} = 'BackgroundColor';
% ImageParameter.Parameter_Name{3} = 'StimulusPos';
% ImageParameter.Cond_Name = {'p11','p12','p21','p22'};
% ImageParameter.Parameter_Value{1} = [0 128 128 0]';
% ImageParameter.Parameter_Value{2} = repmat([128 0 0 128]',1,3);
% theta = mod(ImageParameter.Orientation/180*pi,pi);
% pos(1:2,:) = repmat([ImageParameter.StimulusPos]-[cos(pi/2+theta) sin(pi/2+theta)]*ImageParameter.StimulusSizePix_Y/2,2,1);
% pos(3:4,:) = repmat([ImageParameter.StimulusPos]+[cos(pi/2+theta) sin(pi/2+theta)]*ImageParameter.StimulusSizePix_Y/2,2,1);
% ImageParameter.Parameter_Value{3} = pos([1 4 2 3],:);
radius = round(max(ImageParameter.StimulusSizePix_Y,ImageParameter.StimulusSizePix_X)*3/2);
da = ImageParameter.StimulusSizePix_X;
db = ImageParameter.StimulusSizePix_Y;
[x y] = meshgrid(-radius:radius,-radius:radius);
[TH R] = cart2pol(x,y);
TH = TH + pi;
theta = mod(ImageParameter.Orientation/180*pi,pi);
BaseImage = 0.5 * ones(size(R));
BackGroundImage = BaseImage;
BackGroundImage((R<radius)&(TH>theta & TH<theta+pi)) = 1;
BackGroundImage((R<radius)&(TH<theta | TH>theta+pi)) = 0;
Position = -[cos(pi/2+theta) sin(pi/2+theta)]*ImageParameter.StimulusSizePix_Y/2
dist1 = abs(y - tan(theta)*x-((Position(2)-tan(theta)*Position(1))))/sqrt(1+tan(theta)^2);
dist2 = abs(y - tan(theta+pi/2)*x-((Position(2)-tan(theta+pi/2)*Position(1))))/sqrt(1+tan(theta+pi/2)^2);
BOSImage1 = BaseImage;
BOSImage1((dist1 < db/2 & dist2 <da/2)&(R<radius)) = 1;
BOSImage1((dist1 > db/2 | dist2 >da/2)&(R<radius)) = 0;
Position = [cos(pi/2+theta) sin(pi/2+theta)]*ImageParameter.StimulusSizePix_Y/2
dist1 = abs(y - tan(theta)*x-((Position(2)-tan(theta)*Position(1))))/sqrt(1+tan(theta)^2);
dist2 = abs(y - tan(theta+pi/2)*x-((Position(2)-tan(theta+pi/2)*Position(1))))/sqrt(1+tan(theta+pi/2)^2);
BOSImage2 = BaseImage;
BOSImage2((dist1 < db/2 & dist2 <da/2)&(R<radius)) = 1;
BOSImage2((dist1 > db/2 | dist2 >da/2)&(R<radius)) = 0;
% imwrite(gammacorrection(BackGroundImage),'C:\Kofiko\StimulusSet\BOSMemory\bkupwhite.tif','tif');
% imwrite(gammacorrection(1-BackGroundImage),'C:\Kofiko\StimulusSet\BOSMemory\bkupdark.tif','tif');
% imwrite(gammacorrection(BOSImage1),'C:\Kofiko\StimulusSet\BOSMemory\BOSupwhite.tif','tif');
% imwrite(gammacorrection(1-BOSImage1),'C:\Kofiko\StimulusSet\BOSMemory\BOSupbalck.tif','tif');
% imwrite(gammacorrection(BackGroundImage),'C:\Kofiko\StimulusSet\BOSMemory\bkupwhite.tif','tif');
% imwrite(gammacorrection(1-BackGroundImage),'C:\Kofiko\StimulusSet\BOSMemory\bkupdark.tif','tif');
% imwrite(gammacorrection(BOSImage2),'C:\Kofiko\StimulusSet\BOSMemory\BOSdownwhite.tif','tif');
% imwrite(gammacorrection(1-BOSImage2),'C:\Kofiko\StimulusSet\BOSMemory\BOSdownbalck.tif','tif');
imwrite(gammacorrection(0.5*ones(size(BOSImage1))),'C:\Kofiko\StimulusSet\BOSMemory\grey.tif','tif');

function im = gammacorrection(im);
im = uint8(round(double(im).^(1/1.77)*255));



% 
% dd = size(BaseImage,1);
% WhoImage = zeros(dd*6,dd);
% im = WhoImage; im(1:dd,:) = BOSImage2; im(dd+1:2*dd,:) = 1 - BackGroundImage; im(2*dd+1:3*dd,:) = 1 - BackGroundImage; im(3*dd+1:end,:) = im(1:3*dd,:);
% imagelist{1} = im;
% im2 = im; im2(1:dd,:) = 1- BOSImage1; imagelist{2} = im2;
% im3 = im; im3(dd+1:2*dd,:) = 1 - BOSImage1; im3(2*dd+1:3*dd,:) = 1 - BOSImage1; im3(3*dd+1:end,:) = im3(1:3*dd,:);imagelist{3} = im3;
% imagelist{4} = 1 -im; imagelist{5} = 1- im2; imagelist{6} = 1 - im3;
% im(1:dd,:) = BOSImage1; im(dd+1:2*dd,:) = BackGroundImage; im(2*dd+1:3*dd,:) = BackGroundImage; im(3*dd+1:end,:) = im(1:3*dd,:);
% imagelist{7} = im;
% im2 = im; im2(1:dd,:) = 1- BOSImage2; imagelist{8} = im2;
% im3 = im; im3(dd+1:2*dd,:) = 1 - BOSImage2; im3(2*dd+1:3*dd,:) = 1 - BOSImage2; im3(3*dd+1:end,:) = im3(1:3*dd,:); imagelist{9} = im3;
% imagelist{10} = 1 - im; imagelist{11} = 1 - im2; imagelist{12} = 1 - im3;
% 
% ImageParameter.Image = imagelist;
% ImageParameter.StimulusSizePix_X = radius * 2;
% ImageParameter.StimulusSizePix_Y = radius * 2;
% ImageParameter.Orientation = radius * 2;
% 
% 
% ImageParameter.DefaultValue.StimulusON_MS = 3000;
% ImageParameter.DefaultValue.StimulusOFF_MS = 500;
% ImageParameter.DefaultValue.BackgroundColor = [172 172 172];
