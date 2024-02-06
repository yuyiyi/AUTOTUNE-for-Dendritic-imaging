function showROI_3D(Ly, Lx, rois, Img, rin)
if max(Img(:)) - min(Img(:))>0
    Img = imadjust(Img);
    Img = Img + 0.2;
    Img(Img>1) = 1;
end
Sat = ones(Ly, Lx);
% r = [0.1 1];
rois2 = bsxfun(@times, rois, reshape(1:size(rois,3),1,1,[]));
ROImap = max(rois2,[],3);
if nargin <5
    r = rand(size(rois,3)+1,1);
else
    r = [1, rin];
end
H = reshape(r(ROImap+1), Ly, Lx);
Sat(ROImap==0) = 0;    
rgb_image = hsv2rgb(cat(3, H, Sat, Img));
imshow(rgb_image)
axis off
drawnow