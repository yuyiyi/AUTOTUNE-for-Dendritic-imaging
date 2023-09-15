function deletId = call_deletefeature(handles, rois)

im_norm = handles.im_norm*0.8;
roimap = sum(bsxfun(@times, rois, reshape(1:size(rois,3),1,1,size(rois,3))),3);
roimap2 = roimap+im_norm;

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
imagesc(roimap2), colormap(gray), axis off    
title('Delet ROI by manual clicking (multiselection allowed). Press enter when finish')
hold on
[x,y,p] = impixel(roimap2);
deletId = roimap(sub2ind(handles.size(1:2),y,x));
deletId(deletId==0) = [];
deletId = unique(deletId);