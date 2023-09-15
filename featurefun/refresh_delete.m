function handles = refresh_delete(handles, deletId)
handles.savingflag = 0;
spId = deletId(deletId<=handles.id);
dendId = deletId(deletId>handles.id)-handles.id;
if ~isempty(spId)
    handles.id = handles.id-length(spId);
    handles.roi_seed(spId,:) = [];
    handles.roi(:,:,spId) = [];
    handles.trace(:,spId) = [];
    spineROI = saveSpine(handles.roi_seed, handles.roi, ...
        handles.trace, handles.im_norm, ...
        handles.savepath, handles.savename);
    handles.spineROI = spineROI;
end
if ~isempty(dendId)
    handles.dendrite(dendId) = [];
    handles = generateDendritemask(handles);
    dendriteROI = handles.dendrite;
    im_norm = handles.im_norm;
    if exist(fullfile(handles.savepath, handles.savename), 'file')==0
        save(fullfile(handles.savepath, handles.savename), 'im_norm', 'dendriteROI')       
    else
        save(fullfile(handles.savepath, handles.savename), 'im_norm', 'dendriteROI','-append')
    end
end

