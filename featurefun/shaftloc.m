function dend_shaft = shaftloc(dend_shaft, dendriteROI)
for i = 1:length(dendriteROI)
    if ~isempty(dendriteROI(i).dend_line)
        dend_line = dendriteROI(i).dend_line;
        dC = diff(dend_line,1,1);
        arc = cumsum(sqrt(sum([zeros(1,2); dC].^2,2)));
        dendriteROI(i).arc = arc;
    end
end

for k = 1:size(dend_shaft,1)
    if ~isempty(dend_shaft(k))
        roi_seed = dend_shaft(k).shaft_line;
        if ~isempty(roi_seed)
            l = round(size(roi_seed,1)/2);
            idx = dend_shaft(k).dendriteID;
            pd = pdist2(roi_seed(l,:), dendriteROI(idx).dend_line);
            [~, ii] = min(abs(pd));
            dend_shaft(k).dendloc_linear = dendriteROI(idx).arc(ii);
        else
            dend_shaft(k).dendloc_linear = nan;
        end
    else
        dend_shaft(k).dendloc_linear = nan;
    end
end
