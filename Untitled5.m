
mkdir('newlocalizer2');

for i = 1:5
for j = [1 3 4 5 7 8];
imtt = imgall(:,:,j,tt(i));
imtt(imtt==255) = 128;
imwrite(imtt,['./newlocalizer2/high' int2str(i) '_' int2str(j) '.tif']);
end
end



for i = 1:5
for j = [1 3 4 5 7 8];
imtt = imgall(:,:,j,tt(end+1-i));
imwrite(imtt,['./newlocalizer2/face' int2str(i) '_' int2str(j) '.tif']);
end
end


for i = 1:5
for j = [1 3 4 5 7 8];
imtt = imgall(:,:,j,tt(42+1-i));
imwrite(imtt,['./newlocalizer2/low' int2str(i) '_' int2str(j) '.tif']);
end
end