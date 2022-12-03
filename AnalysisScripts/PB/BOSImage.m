function imall = BOSImage(ori);

im = zeros(300,300);

im(100:200,50:150) = 1;

im = im';
im = imrotate(im,ori,'crop');
imall{1} = im;
imall{3} = 1-im;

im = zeros(300,300);

im(100:200,151:250) = 1;
im = im';
im = imrotate(im,ori,'crop','bicubic');
imall{2} = im;
imall{4} = 1-im;

for i = 1:length(imall)
    xx = imall{i};
    xx(xx==0) = 0.2;
end
