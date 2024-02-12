function h = DendriticSpine_hist(handles, ax1, ax2, targetID, ...
    binvalue, spine_evolve, Dendrite_CrossSess)    

DendLoc = table2array(Dendrite_CrossSess);
DendLoc_plot = DendLoc(DendLoc(:,1)==targetID,:);
SpineLoc = table2array(spine_evolve);   
NumSess = length(handles.datafilename);
im = handles.im_norm_mask;
axes(ax1), 
cla(ax1,'reset')
imshow(im, [min(im(:)), quantile(im(:), 0.98)],'Parent', ax1)
dend_line = handles.dend_line_mask;
pp = dend_line(dend_line(:,3)==targetID, 1:2);
rois = handles.roi_seed_master;
roi_ondend = find(SpineLoc(:,4)==targetID);
if ~isempty(pp)
    axes(ax1)
    hold on, plot(pp(:,1), pp(:,2), 'Linewidth', 1)
end
if ~isempty(roi_ondend)
    axes(ax1), plot(rois(roi_ondend,1), rois(roi_ondend,2), 'or')
end
drawnow

xx_min = min(DendLoc_plot(:,2:2:end));
xx_max = ceil(max(max(SpineLoc(:,3:4:end))));
L = (ceil((xx_max-xx_min)/binvalue)+1)*binvalue;
xx = xx_min:binvalue:L;
h = zeros(length(xx)-1, NumSess);
for k = 1:NumSess
    dendid = DendLoc_plot(2*(k-1)+1);
    dendloctmp = DendLoc_plot(2*k);
    SpineLoctmp = [];
    if dendid>0
        SpineLocSel = SpineLoc(:,4*(k-1)+1:4*k);
        SpineLoctmp = SpineLocSel(SpineLocSel(:,4)==dendid, 3);
        SpineLoctmp = SpineLoctmp+dendloctmp;
    end
    if ~isempty(SpineLoctmp)
        h(:,k) = histcounts(SpineLoctmp, xx);    
    end
end
axes(ax2),
bar(xx(1:end-1), h, 'LineStyle', 'none'); box off
ylabel('Number of spines')
xlabel('Linear loc on dendrits (pixel)')
title('Spine distribution')
legend(handles.tabletitlesub)