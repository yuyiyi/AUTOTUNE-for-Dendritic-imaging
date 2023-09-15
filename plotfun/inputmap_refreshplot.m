function handles = inputmap_refreshplot(handles, dataID)
    f_wait = waitbar(0.5,'Data loading');

    % load data
    cla(handles.DisplayResult, 'reset')
    set(handles.uit, 'Data', {})
    handles = loadtrace(handles, dataID);
    axes(handles.DisplayResult), set(gca, 'Ydir', 'reverse')
    %%%% display rois and traces
    if ~isempty(handles.im_norm)
        %%%% show spine rois
        handles = get_spineROImask(handles);
        roi_mask = handles.roi_mask;
%         roi_mask = zeros(size(handles.roi_mask));
        if max(roi_mask(:))>0
            axes(handles.DisplayResult)
            r_color = handles.spinecolor;
            cc = hsv2rgb(cat(2, r_color, ones(length(r_color),1), ones(length(r_color),1)));
%             showROI_3D(size(handles.im_norm,1), size(handles.im_norm,2), roi_mask, ones(size(handles.im_norm)), r_color')
            showROI_3D(size(handles.im_norm,1), size(handles.im_norm,2), roi_mask, handles.im_norm, r_color')
            drawnow
            handles.DisplayResult;
            if ~isempty(handles.roi_seed)
                for i = 1:size(handles.roi_seed,1)
                    text(handles.roi_seed(i,1)-10, handles.roi_seed(i,2)+5,...
                        num2str(handles.spine_title(i)))
                end
            elseif ~isempty(handles.roi) && isempty(handles.roi_seed)
                handles.DisplayResult;
                for i = 1:size(handles.roi,3)
                    stats = regionprops(handles.roi(:,:,i), 'centroid');
                    handles.roi_seed(i,:) = stats.Centroid;
                    text(handles.roi_seed(i,1)-10, handles.roi_seed(i,2)+5,...
                        num2str(handles.spine_title(i)))
                end
            end
        end
        %%%% show dendrite
        if ~isempty(handles.dendrite)
            axes(handles.DisplayResult)
            for i = 1:length(handles.dendrite)
                dend_line = handles.dendrite(i).dend_line;
                if ~isempty(dend_line)
                    id = round(size(dend_line,1)*0.9);
                    hold on, plot(dend_line(:,1),dend_line(:,2))
                    text(dend_line(id,1), dend_line(id,2), sprintf('d%d', i))
                end
            end
            drawnow
        end
        %%%% show dendritic shaft
        if ~isempty(handles.dend_shaft)
            r_color = handles.spinecolor;
            cc = hsv2rgb(cat(2, r_color, ones(length(r_color),1), ones(length(r_color),1)));
            axes(handles.DisplayResult), hold on
            shaft_title = handles.shaft_title;
            spine_title = handles.spine_title;
            for i = 1:length(shaft_title)                
                shaft_line = handles.dend_shaft(shaft_title(i)).shaft_line;
                i1 = find(spine_title==shaft_title(i));
                if isempty(i1)
                    if i>length(r_color)
                        j = mod(i, length(r_color));
                        if j==0
                            j = length(r_color);
                        end
                    else
                        j = i;
                    end
                else
                    j = i1;
                end
                handles.shaftcolor(i,1) = r_color(j);
                h1a = plot(shaft_line(:,1), shaft_line(:,2), 'linewidth',6,'color',cc(j,:));
                h1a.Color(4) = 0.4;
%               shaft_outline = handles.dend_shaft(i).shaft_outline; 
%               drawploy_custom(shaft_outline, cc(j,:), handles.Mver)
                drawnow
            end
        end
        plotrawtrace(handles)
    end
%     assignin('base', 'handles', handles)
   
    % show frame stamp table
    framestamp = handles.framestamp{1};
    stampinfo = handles.stampinfo{1};
    handles = showframestamptbl(framestamp, stampinfo, handles);
    assignin('base', 'handles', handles)    
    close(f_wait)
    delete(f_wait)