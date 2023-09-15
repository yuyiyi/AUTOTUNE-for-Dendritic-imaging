function spineROI = saveSpine(roi_seed, roi, trace, im_norm, savepath, savename)
if ~isempty(roi_seed)
    clear spineROI
    for k = 1:size(roi_seed,1)
        if ~isnan(roi_seed(k, 1))
            spineROI(k).roi_seed = roi_seed(k,:);
            bw = roi(:,:,k);
            spineROI(k).spine_pixel = find(bw==1);
            spineROI(k).spine_trace = trace(:,k);
        else
            spineROI(k).roi_seed = [];
            spineROI(k).spine_pixel = [];
            spineROI(k).spine_trace = [];
        end
    end
    if exist(fullfile(savepath, savename), 'file')==0
        save(fullfile(savepath, savename), 'im_norm',  'spineROI')
    else
        save(fullfile(savepath, savename), 'im_norm', 'spineROI', '-append')
    end
else
    spineROI = [];
end