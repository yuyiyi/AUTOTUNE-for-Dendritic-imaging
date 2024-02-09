function handles = call_manualspine(handles)

scrsz = handles.scrsz;
im_norm = handles.im_norm;
[d1,d2] = size(im_norm);
r = min(scrsz(3)/3*2/d2, (scrsz(4)-100)/d1);
pos_spine = round([scrsz(3)/3 20 r*d2 r*d1]);
if isempty(findobj('type','figure','number',15))
    pos = pos_spine;    
else
    h1_handles = get(figure(15));
    pos = h1_handles.Position;
end
h1 = figure(15);
clf('reset')
set(h1,'Name', 'Manual spine detection','Position', pos);
imagesc(handles.im_norm, [quantile(handles.im_norm(:), 0.3), quantile(handles.im_norm(:),0.99)]);
title('Click on the image to add ROI. Press return or click in gray area to end session')
drawnow
if ~isempty(handles.roi_seed)
    hold on, plot(handles.roi_seed(:,1), handles.roi_seed(:,2),'or')
end
while 1
    if isempty(findobj('type','figure','number',15))
        h1 = figure(15);
        set(h1,'Name', 'Manual spine detection','Position', pos);
        imagesc(handles.im_norm, [quantile(handles.im_norm(:), 0.3), quantile(handles.im_norm(:), 0.99)]);
        drawnow
        title('Click on the image to add ROI. Press return or left click in gray area to end session')
    end
    figure(15), hold on 
    [x,y,b] = ginput(1);
    if isempty(b)
        break
    end
    pt = [x,y];
    if min(x,y) < 0 || x > size(im_norm, 2) || y > size(im_norm, 1)
        break
    end
    pt = min([pt; [size(im_norm,2)-2, size(im_norm,1)-2]]);
    pt = max([pt; [3, 3]]);            
    nbd = im_norm(round(pt(2))+[-2:2],round(pt(1))+[-2:2]);
    [tmp, tmp2] = max(nbd(:));
    [dx, dy] = ind2sub([5 5], tmp2);
    pt(2) = pt(2) + dx-3;
    pt(1) = pt(1) + dy-3;
    hold on, plot(pt(1), pt(2), 'or')        
    handles.pt = pt;
    if ~isempty(handles.pt) 
        if handles.roimask(round(pt(2)), round(pt(1)))==0
            [Temptrace, tempRoi, handles] = Segmentation_autoThresh(handles);
            handles.tempRoi = tempRoi;
            handles.Temptrace = Temptrace;
            if sum(handles.tempRoi(:))>0
                handles.id = handles.id+1;
                handles.roi_seed(handles.id,:) = handles.pt;
                handles.roi(:,:,handles.id) = handles.tempRoi;
                handles.trace(:,handles.id) = handles.Temptrace;
                displayGUIplots(handles, 2, 0)
                pause(0.1)                
            end
        end
    end
end