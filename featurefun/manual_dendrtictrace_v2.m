function handles = manual_dendrtictrace_v2(handles)
im_norm = handles.im_norm;
scrsz = handles.scrsz;
Mver = handles.Mver;

if isempty(handles.linewidth)
    handles.linewidth = 6;
end
linewidthtmp = handles.linewidth;
[d1,d2] = size(handles.im_norm);
r = min(scrsz(3)/3*2/d2, (scrsz(4)-100)/d1);
pos_dend = round([scrsz(3)/6 20 r*d2 r*d1]);    
hplot = figure(20);
clf('reset')
set(hplot,'Name', 'Manual dendrite tracing','Position',pos_dend);
colormap('gray')
imagesc(im_norm, [quantile(im_norm(:), 0.3), quantile(im_norm(:), 0.99)])
title('Click on a dendrites. Press Enter when finished')
drawnow

%%%% manual tracing 
if ~isempty(handles.size)
    explinelength = sqrt(handles.size(1)^2 + handles.size(2)^2);
    arc_grad = round(explinelength/15);
    csgrad = round(explinelength*2);
else
    csgrad = 1000;
    arc_grad = 20;
end
pt = [0 0];
pt_all = [];
figure(20), hold on
while ~isempty(pt) && ~isempty(findobj('type','figure','number',20))
    pt = ginput(1);
    if ~isempty(pt)
        pt = min([pt; [size(im_norm,2)-2, size(im_norm,1)-2]]);
        pt = max([pt; [3, 3]]);            
        nbd = im_norm(round(pt(2))+[-2:2],round(pt(1))+[-2:2]);
        [tmp, tmp2] = max(nbd(:));
        [dx, dy] = ind2sub([5 5], tmp2);
        pt(2) = pt(2) + dx-3;
        pt(1) = pt(1) + dy-3;
        plot(pt(1),pt(2),'.r', 'markersize', 15)
        pt_all =[pt_all ; pt];
    end
end
if ~isempty(pt_all)
    pt_all([1;sum(diff(pt_all).^2,2)]==0,:) = [];
    c = cscvn(pt_all');
    xx = linspace(0, floor(max(c.breaks)), csgrad);
    cspoints = ppval(c, xx);
    cspoints(:,min(cspoints,[],1)<1) = [];
    cspoints(:,cspoints(1,:)> handles.size(2)) = [];
    cspoints(:,cspoints(2,:)> handles.size(1)) = [];
    arc_grad = max(arc_grad, 20);
    [~, kymo_cordinate] = line_expand(cspoints, linewidthtmp, arc_grad);
    polydot = kymo_cordinate';
    dend_outline = [polydot(:,1:2); flip(polydot(:,end-1:end),1);polydot(1,1:2)];

    showDendROI(handles)
    handles = getdendsignal(handles);
end
    %%%% extract dendritic signal, fine tune ROI
    function handles = getdendsignal(handles)
        bw = poly2mask(dend_outline(:,1),dend_outline(:,2), handles.size(1), handles.size(2));
        pointID = find(bw==1);
        mov2d_filt = handles.mov2d_filt;
        pointtrace = single(mov2d_filt(pointID,:));
        pointID_C = sub2ind(size(im_norm), round( cspoints(2,:)'), round( cspoints(1,:)'));
        pointtrace_c = single(mov2d_filt(pointID_C,:));
        pointC = corr(mean(pointtrace_c)',pointtrace');
        pointcormap = zeros(size(im_norm));
        pointcormap(pointID) = pointC;
        pointcormap(pointcormap<max(pointC(:))/2) = 0;
        pointcormap(pointcormap>0) = 1;
        [~, defaultline] = line_expand(cspoints, 1, csgrad);
        defaultline1 = sub2ind(size(im_norm), round(reshape(defaultline(2:2:end,:),[],1)),...
            round(reshape(defaultline(1:2:end,:),[],1)));
        pointcormap(defaultline1) = 1;
        dend_pixel = find(pointcormap>0);
        if isempty(pointcormap)
            fprintf('warning low SNR on dendrites')
        end
        handles.current_dendmask = bw;
        handles.current_dend_pixel = dend_pixel;
        handles.current_dend_outline = dend_outline;
        handles.current_pt_all = pt_all;
        handles.current_cspoints = cspoints;
        handles.current_dend_trace = mean(handles.mov(dend_pixel,:),1)';
    end

    function showDendROI(handles)
        if isempty(findobj('type','figure','number',20))
            pos = pos_dend;    
        else
            hplot = get(figure(20));
            pos = hplot.Position;
        end
        hplot = figure(20); clf('reset')
        set(hplot,'Name', 'Manual dendrite tracing','Position',pos);

        drawDendROI
        linewidthtmp = handles.linewidth;
        showscalebar(handles.im_norm, linewidthtmp)
        drawnow
        uicontrol(hplot,'style','Text',...
            'String', 'Set Linewidth',...
            'Fontsize', 12,...
            'Units', 'normalized', 'position',[0.6 0.05 0.1 0.04])
        setlinewidth = uicontrol(hplot,'style','edit',...
            'String', num2str(linewidthtmp),...
            'Fontsize', 12,...
            'Units', 'normalized', 'position',[0.6 0.02 0.1 0.04],...
            'Callback', @refreshDendROI);
        p = uicontrol(hplot,'style','pushbutton',...
            'String', 'Accept',...
            'Units', 'normalized',...
            'Fontsize', 12,...
            'position',[0.8 0.02 0.1 0.06],...
            'Callback','uiresume(gcbf)');    
        uiwait(hplot)
    end

    function refreshDendROI(hObject, event)
        linewidthtmp = str2double(get(hObject, 'String'));
        if linewidthtmp ~= handles.linewidth
            handles.linewidth = linewidthtmp;
            [~, kymo_cordinate] = line_expand(cspoints, linewidthtmp, arc_grad);
            polydot = kymo_cordinate';
            dend_outline = [polydot(:,1:2); flip(polydot(:,end-1:end),1);polydot(1,1:2)];
            drawDendROI       
        end
    end

    function drawDendROI
        hplot = figure(20);
        subaxe = uipanel('Parent', hplot, 'Units', 'normalized', 'Position', [0 0.1 1 0.9]);
        cla(axes(subaxe), 'reset'), colormap('gray')
        imagesc(im_norm, [quantile(im_norm(:), 0.3), quantile(im_norm(:), 0.99)])        
        drawploy_custom(dend_outline, [0 0.5 0.8], Mver)
        title('Dendritic ROI')
        linewidthtmp = handles.linewidth;
        showscalebar(handles.im_norm, linewidthtmp)
        drawnow        
    end
end