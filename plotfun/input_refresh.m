function handles = input_refresh(handles, dataID)
    f_wait = waitbar(0.5,'Data loading');

    % load data
    handles = loadtrace(handles, dataID);
    if ~isempty(handles.im_norm)
        %%%% show spine rois
        handles = get_spineROImask(handles);
        roi_mask = handles.roi_mask;
%         roi_mask = zeros(size(handles.roi_mask));
        if max(roi_mask(:))>0
            if ~isempty(handles.roi) && isempty(handles.roi_seed)
                for i = 1:size(handles.roi,3)
                    stats = regionprops(handles.roi(:,:,i), 'centroid');
                    handles.roi_seed(i,:) = stats.Centroid;
                end
            end
        end
    end
%     assignin('base', 'handles', handles)
   
    % show frame stamp table
    if ~isempty(handles.framestamp)
    framestamp = handles.framestamp{1};
    stampinfo = handles.stampinfo{1};
    if ~isempty(framestamp)
        if min(size(stampinfo)) > 1
            if ~istable(stampinfo)
                stampinfo = array2table(stampinfo);
                handles.stampinfo{1} = stampinfo;
            end
        end
    end
    end
    assignin('base', 'handles', handles)    
    close(f_wait)
    delete(f_wait)