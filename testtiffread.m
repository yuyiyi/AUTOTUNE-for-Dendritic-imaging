filename = fullfile(imageinfo(1).folder, imageinfo(1).name);
I = imread(filename, 1);
tic
V = tiffreadVolume(filename,'PixelRegion',{size(I,1),size(I,2),300});
toc