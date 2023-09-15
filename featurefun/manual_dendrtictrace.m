function handles = manual_dendrtictrace(handles)
im_norm = handles.im_norm;
scrsz = handles.scrsz;
Mver = handles.Mver;

if ~isempty(handles.linewidth)
    linewidth = handles.linewidth;
else
    linewidth = 6;
end

[d1,d2] = size(handles.im_norm);
r = min(scrsz(3)/3*2/d1, scrsz(4)-100/d2);
pos_dend = round([scrsz(3)/6 20 r*d1 r*d2]);    
h1 = figure(20);
clf('reset')
set(h1,'Name', 'Manual dendrite tracing','Position',pos_dend);
colormap('gray')
imagesc(im_norm, [quantile(im_norm(:), 0.3), quantile(im_norm(:), 0.99)])
showscalebar(handles.im_norm, handles.linewidth)
title('Click on a dendrites. Press Enter when finished')
drawnow
if ~isempty(handles.size)
    explinelength = sqrt(handles.size(1)^2 + handles.size(2)^2);
    arc_grad = round(explinelength/15);
    csgrad = round(explinelength*2);
else
    csgrad = 1000;
    arc_grad = 20;
end

mov2d_filt = handles.mov2d_filt;
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
pt_all([1;sum(diff(pt_all).^2,2)]==0,:) = [];
c = cscvn(pt_all');
xx = linspace(0, floor(max(c.breaks)), csgrad);
cspoints = ppval(c, xx);

cspoints(:,min(cspoints,[],1)<1) = [];
cspoints(:,cspoints(1,:)> handles.size(2)) = [];
cspoints(:,cspoints(2,:)> handles.size(1)) = [];

arc_grad = max(arc_grad, 20);
[~, kymo_cordinate] = line_expand(cspoints, linewidth, arc_grad);
polydot = kymo_cordinate';
dend_outline = [polydot(:,1:2); flip(polydot(:,end-1:end),1);polydot(1,1:2)];
bw = poly2mask(dend_outline(:,1),dend_outline(:,2), handles.size(1), handles.size(2));
pointID = find(bw==1);
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
handles.current_dendmask = bw;
handles.current_dend_pixel = dend_pixel;
handles.current_dend_outline = dend_outline;
handles.current_pt_all = pt_all;
handles.current_cspoints = cspoints;
handles.current_dend_trace = mean(handles.mov(dend_pixel,:),1)';



if isempty(findobj('type','figure','number',20))
    pos = pos_dend;    
else
    h1_handles = get(figure(20));
    pos = h1_handles.Position;
end
h1 = figure(20);
set(h1,'Name', 'Manual dendrite tracing','Position',pos);
colormap('gray')
if ~isempty(pointcormap)
    showROI(handles.size(1), handles.size(2), pointcormap, handles.im_norm)
else
    imshow(im_norm)
    fprintf('warning low SNR on dendrites')
end
if str2num(Mver(end-4:end))<2019
    h1 = impoly(gca, dend_outline);
    h1.Deletable = false;
    setVerticesDraggable(h1, false) 
else
    h1 = drawpolygon('Position', dend_outline, 'InteractionsAllowed', 'none', 'LineWidth', 0.2, 'FaceAlpha', 0);
end
drawnow
