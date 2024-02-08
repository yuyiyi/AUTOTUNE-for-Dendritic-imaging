function handles = call_autoshaftDendr(handles, ifGUIdraw, resetparameter, ifhold)
if nargin < 4
    ifhold = 1;
end
if resetparameter
    prompt = {'Enter shaft segment length:'};
    dlgtitle = 'Input';
    dims = [1 35];
    definput = {num2str(handles.defaultPara.shaftlength)};
    answer = inputdlg(prompt,dlgtitle,dims,definput);
    if ~isempty(answer{1})
        handles.defaultPara.shaftlength = str2num(answer{1});
    end
end
shaft_length = handles.defaultPara.shaftlength;

f_wait = waitbar(0.5,'Finding dendritic shaft');
frames = java.awt.Frame.getFrames();
frames(end).setAlwaysOnTop(1); 
clear dend_shaft
r_color_pool = linspace(0.1, 0.99, 10)';
imgsize = size(handles.im_norm);    
dendriteROI = handles.dendrite;
spineROI = handles.spineROI;
dend_mask = zeros(imgsize(1), imgsize(2));
for k = 1:length(dendriteROI)
    dend_pixel = handles.dendrite(k).dend_pixel;
    dend_mask(dend_pixel) = 1;
end
if handles.shaft_flag==1
    spine_seed = handles.roi_seed;    
    rois = handles.roi;    
    if ~isempty(dendriteROI) && ~isempty(spineROI) 
        if ~isfield(spineROI, 'dendriteID') || ~isfield(spineROI, 'dendloc_linear')
            [nearestID, dend_arcloc, dendloc] = nearestDendrite(spine_seed, dendriteROI, handles, ifhold);
            i = 0;
            for k = 1:length(spineROI)
                if ~isempty(spineROI(k).roi_seed)
                    i = i+1;
                    spineROI(k).dendriteID = nearestID(i);
                    spineROI(k).dendloc_linear = dend_arcloc(i);
                    spineROI(k).dendloc_pixel = dendloc(i,:);
                end
            end
        end
    end
    assignin('base', 'spineROI', spineROI);
    handles.spineROI = spineROI;
    shaft_seed = reshape([spineROI.dendloc_pixel],2, [])';
    dendID = [spineROI.dendriteID];
    si = mod(1:length(handles.spineROI), 10);
    si(si==0) = 10;
    r_color1 = r_color_pool(si);
    r_color = hsv2rgb(cat(2, r_color1, ones(length(r_color1),1), ones(length(r_color1),1)));
    k2 = 1;
    for k = 1:length(handles.spineROI)
        shaft_pt = []; pointID = []; shaft_outline = []; tracetmp = [];
        if ~isempty(handles.spineROI(k).roi_seed)
            cc = shaft_seed(k2,1:2);
            i = dendID(k);
            if i>0
                linewidth = handles.dendrite(i).linewidth;
                dend_line = handles.dendrite(i).dend_line; 
                dend_pixel = handles.dendrite(i).dend_pixel;
                dd = pdist2(cc, dend_line);
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
                   drawploy_custom(shaft_outline, r_color(k2,:), handles.Mver)
                end
            end
        end
        dend_shaft(k2).shaft_line = shaft_pt;
        dend_shaft(k2).shaft_pixel =  pointID;
        dend_shaft(k2).dendriteID = i; 
        dend_shaft(k2).shaft_outline = shaft_outline; 
        k2 = k2+1;
%         dend_shaft(k).shaft_trace = tracetmp;     
    end

elseif handles.shaft_flag == 2
    k2 = 0;
    % shaft_length = max([handles.dendrite.linewidth])*10;
    shaft_length = handles.defaultPara.shaftlength;

    for i = 1:length(handles.dendrite)
        linewidth = handles.dendrite(i).linewidth;
        dend_pixel = handles.dendrite(i).dend_pixel;
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
%             tracetmp = mean(handles.mov(pointID,:),1)';
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
%             dend_shaft(k2).shaft_trace = tracetmp; 
        end
    end
end
close(f_wait)
delete(f_wait)
handles.dend_shaft = dend_shaft;
