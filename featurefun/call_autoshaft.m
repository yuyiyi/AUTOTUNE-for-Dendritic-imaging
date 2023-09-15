function handles = call_autoshaft(handles, ifGUIdraw)
f_wait = waitbar(0.5,'Finding dendritic shaft');
frames = java.awt.Frame.getFrames();
frames(end).setAlwaysOnTop(1); 
spine_seed = handles.roi_seed;    
rois = handles.roi;
spine_mask = sum(rois,3);    
imgsize = [size(spine_mask,1), size(spine_mask,2)];    
dend_line_all = [];
dend_mask = zeros(imgsize(1), imgsize(2));
for i = 1:length(handles.dendrite)
    dend_line = handles.dendrite(i).dend_line;
    if ~isempty(dend_line)
        dend_line_all = cat(1, dend_line_all, [dend_line, ones(size(dend_line,1),1)*i]);
        dend_pixel = handles.dendrite(i).dend_pixel;
        dend_mask(dend_pixel) = 1;
    end
end
pd = pdist2(spine_seed, dend_line_all(:,1:2));
[distmin, b] = min(pd,[],2);
% assignin('base', 'pd', pd);
shaft_seed = dend_line_all(b,:);
shaft_length = ceil(sqrt(sum(rois(:))/size(rois,3)));

clear dend_shaft
r_color_pool = linspace(0.1, 0.99, 10)';
si = mod(1:length(handles.spineROI), 10);
si(si==0) = 10;
r_color1 = r_color_pool(si);
r_color = hsv2rgb(cat(2, r_color1, ones(length(r_color1),1), ones(length(r_color1),1)));

for k = 1:length(handles.spineROI)
    f_wait
    shaft_pt = []; pointID = []; shaft_outline = []; tracetmp = [];
    if ~isempty(handles.spineROI(k).roi_seed)
        cc = shaft_seed(k,1:2);
        i = shaft_seed(k,3);
        linewidth = handles.dendrite(i).linewidth;
        dend_line = handles.dendrite(i).dend_line; 
        dend_pixel = handles.dendrite(i).dend_pixel;
        dd = pdist2(cc, dend_line);
        if distmin(k)<=linewidth*5
            shaft_pt = dend_line(dd<=shaft_length,:);
            [~, kymo_cordinate] = line_expand(shaft_pt', linewidth);
            polydot = kymo_cordinate';
            shaft_outline = [polydot(:,1:2); flip(polydot(:,end-1:end),1);polydot(1,1:2)];
            bw = poly2mask(shaft_outline(:,1),shaft_outline(:,2), imgsize(1), imgsize(2));
            bw = bw.*dend_mask;
            pointID = find(bw==1);
            tracetmp = mean(handles.mov(pointID,:),1)';
            if ifGUIdraw
               axes(handles.DisplayResult)
               drawploy_custom(shaft_outline, r_color(k,:), handles.Mver)
            end
        end
    end
    dend_shaft(k).shaft_line = shaft_pt;
    dend_shaft(k).shaft_pixel =  pointID;
    dend_shaft(k).dendriteID = i; 
    dend_shaft(k).shaft_outline = shaft_outline; 
    dend_shaft(k).shaft_trace = tracetmp;        
end
handles.dend_shaft = dend_shaft;
handles.shaft_flag = 1;
close(f_wait)
delete(f_wait)
