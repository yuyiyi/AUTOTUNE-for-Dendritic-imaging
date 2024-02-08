function spineROI = saveSpine(roi_seed, roi, trace, im_norm, savepath, savename)
if ~isempty(roi_seed)
    clear spineROI
    k1 = 1;
    for k = 1:size(roi_seed,1)
        if ~isnan(roi_seed(k, 1))
            spineROI(k1).roi_seed = roi_seed(k,:);
            bw = roi(:,:,k);
            spineROI(k1).spine_pixel = find(bw==1);
            spineROI(k1).spine_trace = trace(:,k);
            k1 = k1+1;
        end
    end
    if exist(fullfile(savepath, savename), 'file')==0
        save(fullfile(savepath, savename), 'im_norm',  'spineROI', '-v7.3')
    else
        save(fullfile(savepath, savename), 'im_norm', 'spineROI', '-append')
    end
else
    spineROI = [];
end