function showbatchfeature(handles, im_mask_reg, ifspine, ifdendrite, ifshaft)
hplot = figure;
set(hplot, 'Name', handles.filename)
if handles.withmask == 1 && ~isempty(handles.im_mask)
    subplot(121), imshowpair(im_mask_reg, handles.im_norm,'Scaling','joint'), title('Registered')
    subplot(122),
end
if ifspine == 1
    % plot spine roi and trace
    roi_mask = [];
    r_color_pool = linspace(0.1, 0.99, 10)';
    ii = mod(1:size(handles.roi,3), 10);
    ii(ii==0) = 10;
    r_color = r_color_pool(ii);

    if ~isempty(handles.roi)
        if size(handles.roi,3) ~= size(handles.trace,2)
            msgbox('Number of trace and number spine ROI inconsistent', 'Warning', 'warn')
        end
        roi_mask = handles.roi;
%         r_color = linspace(0.1, 0.99, size(handles.trace,2))';
        cc = hsv2rgb(cat(2, r_color, ones(length(r_color),1), ones(length(r_color),1)));

    else
        roi_mask = zeros(size(handles.im_norm));
    end
    showROI_3D(size(handles.im_norm,1), size(handles.im_norm,2), roi_mask, handles.im_norm, r_color')
    drawnow
end

if ~isempty(handles.dendrite) && ifdendrite > 0
    % plot dendrite roi
    for i = 1:length(handles.dendrite)        
        dend_line = handles.dendrite(i).dend_line;
        if ~isempty(dend_line)
            hold on, plot(dend_line(:,1),dend_line(:,2))
        end
    end
end

if ~isempty(handles.dendrite) && ifshaft == 1
    r_color_pool = linspace(0.1, 0.99, 10)';
    si = mod(1:length(handles.dend_shaft), 10);
    si(si==0) = 10;
    r_color1 = r_color_pool(si);
    r_color = hsv2rgb(cat(2, r_color1, ones(length(r_color1),1), ones(length(r_color1),1)));

    for k = 1:length(handles.dend_shaft)
        shaft_outline = handles.dend_shaft(k).shaft_outline;
        if ~isempty(shaft_outline)
            drawploy_custom(shaft_outline, r_color(k,:), handles.Mver)
        end
    end
end
