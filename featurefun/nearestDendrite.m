function nearestID = nearestDendrite(roi_seed, dend_line_all)
nearestID = [];
for k = 1:size(roi_seed,1)
    if max(dend_line_all(:,3))>1
        pd = pdist2(roi_seed(k,:), dend_line_all(:,1:2));
        [~, ii] = min(abs(pd));
        id = dend_line_all(ii,3);
    else
        id = 1;
    end
    nearestID(k) = id;
end
