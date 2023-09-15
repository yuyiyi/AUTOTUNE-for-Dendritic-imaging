function handles = refreshspine(handles)
roi_cent = handles.roi_seed;
spId = [];
if ~isempty(handles.dendrite)
    for k = 1:length(handles.dendrite)
        dend_outline = handles.dendrite(k).dend_outline;
        if ~isempty(dend_outline)
            in_dendr = inpolygon(roi_cent(:,1), roi_cent(:,2), dend_outline(:,1), dend_outline(:,2));
            spId = cat(1, spId, find(in_dendr==1));        
        end
    end
    if ~isempty(spId)
        handles.id = handles.id-length(spId);
        handles.roi_seed(spId,:) = [];
        handles.roi(:,:,spId) = [];
        handles.trace(:,spId) = [];
    end
    if ~isempty(handles.roi)
       tmp = bsxfun(@times,handles.roi, ones(size(handles.im_norm))-handles.roimask);
       handles.roi = tmp;
    end       
end

spineROI = saveSpine(handles.roi_seed, handles.roi, handles.trace,...
    handles.im_norm, handles.savepath, handles.savename);
handles.spineROI = spineROI;
