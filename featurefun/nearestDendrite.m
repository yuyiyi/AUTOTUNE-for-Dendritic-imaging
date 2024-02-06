function [nearestID, dend_arcloc, dendloc] = nearestDendrite(roi_seed, dendriteROI, handles)

scrsz = handles.scrsz;
im_norm = handles.im_norm;
[d1,d2] = size(im_norm);
r = min(scrsz(3)/3*2/d2, (scrsz(4)-100)/d1)/2;
pos_spine = round([scrsz(3)/3 20 r*d2 r*d1]);
if isempty(findobj('type','figure','number',15))
    pos = pos_spine;    
else
    h1_handles = get(figure(15));
    pos = h1_handles.Position;
end
hplot = figure(15);
cc = colormap(hsv(length(dendriteROI)+1));
clf('reset')
set(hplot,'Name', 'Spine on dendrites','Position', pos);
ax1 = subplot(3,2,1:4);
imshow(im_norm, [quantile(im_norm(:), 0.3), quantile(im_norm(:), 0.99)],"Border","tight");
title('Click on a spine to edit its dendritic association.')

dend_line_all = []; arc_all = []; 
dendtitle = []; dend_titlelist = ''; ii = 1;
for i = 1:length(dendriteROI)
    if ~isempty(dendriteROI(i).dend_line)
        dendtitle(ii) = i;
        dend_titlelist{ii} = sprintf('Dendrite %d', i);
        dend_line = dendriteROI(i).dend_line;
        dC = diff(dend_line,1,1);
        arc = cumsum(sqrt(sum([zeros(1,2); dC].^2,2)));
        dend_line_all = cat(1, dend_line_all, [dend_line, ones(size(dend_line,1),1)*i]);
        arc_all = cat(1, arc_all, arc);        
        hold(ax1, 'on');
        plot(dend_line(:,1), dend_line(:,2), 'color', cc(i,:), 'linewidth', 1)
        tmp = round(size(dend_line,1)*0.9);
        text(dend_line(tmp,1), dend_line(tmp,2), sprintf('d%d', i), 'Color', cc(i,:))
        ii = ii +1;
    end
end
dendtitle = cat(2, dendtitle, 0);
dend_titlelist = [dend_titlelist, 'None'];
nearestID = []; dend_arcloc = []; dendloc = [];
for k = 1:size(roi_seed,1)
    pd = pdist2(roi_seed(k,:), dend_line_all(:,1:2));
    [~, ii] = min(abs(pd));
    id = dend_line_all(ii,3);
    dendloc(k,:) = dend_line_all(ii,1:2);
    dend_arcloc(k) = arc_all(ii);
    nearestID(k) = id;
    hold(ax1, 'on');
    plot(roi_seed(k,1), roi_seed(k,2),'o', 'color', cc(id,:))
end
drawnow

panel2 = uipanel('Parent',hplot,...
        'Position',[0.1 0.1 0.8 0.3],...
        'FontSize', 10);

t = uicontrol('Parent',panel2,'Style','text',...
    'Units', 'normalized',...
    'fontsize', 10,...
    'position',[0.05 0.8 0.2 0.1],...
    'String', 'Spine');

c = uicontrol('Parent',panel2,'Style','popupmenu',...
    'Units', 'normalized',...
    'fontsize', 10,...
    'position',[0.05 0.6 0.2 0.1],...
    'String', dend_titlelist, ...
    'Enable', 'off', ...
    'Callback', @selection);

p1 = uicontrol('Parent',panel2,'style','pushbutton',...
        'String', 'Accept',...
        'Units', 'normalized',...
        'fontsize', 10,...
        'position',[0.05 0.3 0.2 0.15],...
        'Enable', 'off', ...
        'Callback', @acceptsel); 
    
p = uicontrol('Parent',panel2,'style','pushbutton',...
        'String', 'Finish',...
        'Units', 'normalized',...
        'fontsize', 10,...
        'position',[0.7 0.2 0.2 0.15],...
        'Callback', @Gopress);    
n = uicontrol('Parent',panel2,'style','pushbutton',...
        'String', 'New',...
        'Units', 'normalized',...
        'fontsize', 10,...
        'position',[0.7 0.5 0.2 0.15],...
        'Callback', @Newpress);   

idx = selectSpineforedit;

uiwait(hplot)
close(hplot)

    function idx = selectSpineforedit
        pt = ginput(1)
        [v, idx] = min(pdist2(pt(1,1:2), roi_seed))
        if v<10
            c.Enable = 'on';
            c.Value = find(dendtitle==nearestID(idx));
            p1.Enable = 'on';
            t.String = sprintf('Spine %d', idx);
        end
    end
    function selection(src,~)
        val = c.Value;
        str = c.String;
        disp(['Selection: ' str{val}]);
    end
    function acceptsel(hObject, eventdata)
        if get(hObject, 'Value') == 1
            val = c.Value;
            nearestID(idx) = dendtitle(val);
            if dendtitle(val)~=0
                dendtmp = dend_line_all(dend_line_all(:,3)==dendtitle(val),:);
                arctmp = arc_all(dend_line_all(:,3)==dendtitle(val));
                pd = pdist2(roi_seed(idx,:), dendtmp(:,1:2));
                [~, iitmp] = min(abs(pd));
                dendloc(idx,:) = dend_line_all(iitmp,1:2);
                dend_arcloc(idx) = arctmp(iitmp);
            else
                dendloc(idx,:) = [nan, nan];
                dend_arcloc(idx) = nan;
            end
            hold(ax1, 'on');
            plot(roi_seed(idx,1), roi_seed(idx,2),'o', 'color', cc(val,:))
    
            c.Enable = 'off';
            p1.Enable = 'off';
            idx = selectSpineforedit;
        end
    end
    function Newpress(hObject, eventdata)
        if get(hObject, 'Value') == 1
            idx = selectSpineforedit;
        end
    end
    function Gopress(hObject, eventdata)
        if get(hObject, 'Value') == 1
            uiresume;
            return
        end
    end
end