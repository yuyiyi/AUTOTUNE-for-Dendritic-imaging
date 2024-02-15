function deletId = call_deletefeature(handles, rois)
assignin('base', 'handles', handles);
assignin('base', 'rois', rois);
im_norm = handles.im_norm;
roimap = max(bsxfun(@times, rois, reshape(1:size(rois,3),1,1,size(rois,3))),[],3);
roimap2 = roimap;
roimap2(roimap2>1) = 1;
% roimap2 = roimap2+im_norm;


scrsz = handles.scrsz;
[d1,d2] = size(im_norm);
r = min(scrsz(3)/3*2/d2, (scrsz(4)-100)/d1);
pos_spine = round([scrsz(3)/3 20 r*d2 r*d1]);
if isempty(findobj('type','figure','number',15))
    pos = pos_spine;    
else
    h1_handles = get(figure(15));
    pos = h1_handles.Position;
end
h1 = figure(15); clf('reset')
set(h1,'Name', 'Manual feature detection','Position', pos);
%     axes(handles.PickROI)
% imagesc(roimap2,[0 1]), colormap(gray), axis off 

if max(im_norm(:)) - min(im_norm(:))>0
    im_norm = imadjust(im_norm);
    im_norm = im_norm + 0.2;
    im_norm(im_norm>1) = 1;
end
Sat = ones(d1, d2);
% r = rand(size(rois,3)+1,1);
r = [0.1 1];
H = reshape(r(roimap2+1), d1, d2);
Sat(roimap2==0) = 0;    
roimap2 = hsv2rgb(cat(3, H, Sat, im_norm));
imagesc(roimap2)

title('Delet ROI by manual clicking (multiselection allowed). Press enter when finish')
hold on
[x,y,p] = impixel(roimap2);
idout = [find(min([x,y],[],2) < 0); find( x > size(im_norm, 2)); find(y > size(im_norm, 1))];
x(idout) = [];
y(idout) = [];
deletId = [];
if ~isempty(x)
deletId = roimap(sub2ind(handles.size(1:2),y,x));
deletId(deletId==0) = [];
deletId = unique(deletId);
end