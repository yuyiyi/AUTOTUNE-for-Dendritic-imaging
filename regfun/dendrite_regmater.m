function handles = dendrite_regmater(handles, t_points, R_points, dendriteROI_mask)
handles.roimask = zeros(size(handles.im_norm));

im_norm = handles.im_norm;
scrsz = handles.scrsz;
pos_dend = round([scrsz(3)/6 20 scrsz(3)/3*2 scrsz(4)-100]);    
[d1,d2] = size(im_norm);
if ~isempty(handles.size)
    explinelength = sqrt(handles.size(1)^2 + handles.size(2)^2);
    arc_grad = round(explinelength/15);
    csgrad = round(explinelength*2);
else
    csgrad = 1000;
    arc_grad = 20;
end
k1 = 1;
for k = 1:length(dendriteROI_mask)
    dend_seed_master = dendriteROI_mask(k).points;
    %%%%%% 
    pt_all = R_points*[dend_seed_master'; 1*randn(1,size(dend_seed_master,1))];
    pt_all = bsxfun(@plus, pt_all, t_points);
    pt_all = pt_all(1:2,:)';
%     pt_all = bsxfun(@minus, dend_seed_master, [dv(2), dv(1)]);
    pt_all([1;sum(diff(pt_all).^2,2)]==0,:) = [];
    c = cscvn(pt_all');
    xx = linspace(0, floor(max(c.breaks)), csgrad);
    cspoints = ppval(c, xx);
    cspoints(:,min(cspoints,[],1)<1) = [];
    cspoints(:,cspoints(1,:)> d2) = [];
    cspoints(:,cspoints(2,:)> d1) = [];
    if ~isempty(cspoints)
        if ~isempty(dendriteROI_mask(k).linewidth)
            linewidth = dendriteROI_mask(k).linewidth;
        else
            linewidth = handles.linewidth;
        end
        arc_grad = max(arc_grad, 20);
        [~, kymo_cordinate] = line_expand(cspoints, linewidth, arc_grad);
        polydot = kymo_cordinate';
        dend_outline = [polydot(:,1:2); flip(polydot(:,end-1:end),1);polydot(1,1:2)];
        bw = poly2mask(dend_outline(:,1),dend_outline(:,2), handles.size(1), handles.size(2));
        pointID = find(bw==1);
        pointtrace = single(handles.mov2d_filt(pointID,:));
        pointID_C = sub2ind(size(im_norm), round( cspoints(2,:)'), round( cspoints(1,:)'));
        pointtrace_c = single(handles.mov2d_filt(pointID_C,:));
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
        
        handles.dendrite(k1).dend_pixel = dend_pixel;
        handles.dendrite(k1).dend_outline = dend_outline;
        handles.dendrite(k1).points = pt_all;
        handles.dendrite(k1).dend_line = cspoints';
        handles.dendrite(k1).trace = mean(handles.mov(dend_pixel,:),1)';        
        handles.dendrite(k1).linewidth = linewidth;
        handles.roimask = handles.roimask + bw;
        k1 = k1+1;
%     else
%         handles.dendrite(k).dend_pixel = [];
%         handles.dendrite(k).dend_outline = [];
%         handles.dendrite(k).points = [];
%         handles.dendrite(k).dend_line = [];
%         handles.dendrite(k).trace = [];         
%         handles.dendrite(k).linewidth = [];
    end
end

% dendriteROI = handles.dendrite;
% if exist(fullfile(handles.savepath, handles.savename), 'file')==0
%     save(fullfile(handles.savepath, handles.savename), 'im_norm', 'dendriteROI','-v7.3')       
% else
%     save(fullfile(handles.savepath, handles.savename), 'im_norm', 'dendriteROI','-append')
% end