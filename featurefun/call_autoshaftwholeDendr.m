function handles = call_autoshaftwholeDendr(handles, ifGUIdraw)
f_wait = waitbar(0.5,'Finding dendritic shaft');
frames = java.awt.Frame.getFrames();
frames(end).setAlwaysOnTop(1); 
clear dend_shaft
r_color_pool = linspace(0.1, 0.99, 10)';
k2 = 0;
imgsize = size(handles.im_norm);    
dend_mask = zeros(imgsize(1), imgsize(2));
shaft_length = max([handles.dendrite.linewidth])*10;

for i = 1:length(handles.dendrite)
    linewidth = handles.dendrite(i).linewidth;
    dend_pixel = handles.dendrite(i).dend_pixel;
    dend_mask(dend_pixel) = 1;
    dend_line = handles.dendrite(i).dend_line;
    dd = sqrt(sum((dend_line(1:end-1,:) - dend_line(2:end,:)).^2, 2));
    d1 = cumsum(dd);
    i1 = unique([1; find(diff(ceil(d1/shaft_length)))+1;size(dend_line,1)]);
    for k = 1:length(i1)-1
        shaft_pt = []; pointID = []; shaft_outline = []; tracetmp = [];
        k2 = k2+1;
        shaft_pt = dend_line(i1(k):i1(k+1),:);
        [~, kymo_cordinate] = line_expand(shaft_pt', linewidth);
        polydot = kymo_cordinate';
        shaft_outline = [polydot(:,1:2); flip(polydot(:,end-1:end),1);polydot(1,1:2)];
        bw = poly2mask(shaft_outline(:,1),shaft_outline(:,2), imgsize(1), imgsize(2));
        bw = bw.*dend_mask;
        pointID = find(bw==1);
        tracetmp = mean(handles.mov(pointID,:),1)';
        if ifGUIdraw
            si = mod(k2, 10)+1;
            r_color1 = r_color_pool(si);
            r_color = hsv2rgb(cat(2, r_color1, ones(length(r_color1),1), ones(length(r_color1),1)));
            axes(handles.DisplayResult)
            drawploy_custom(shaft_outline, r_color, handles.Mver)
        end
        dend_shaft(k2).shaft_line = shaft_pt;
        dend_shaft(k2).shaft_pixel =  pointID;
        dend_shaft(k2).dendriteID = i; 
        dend_shaft(k2).shaft_outline = shaft_outline; 
        dend_shaft(k2).shaft_trace = tracetmp; 
    end
end
close(f_wait)
delete(f_wait)

handles.dend_shaft = dend_shaft;
handles.shaft_flag = 2;