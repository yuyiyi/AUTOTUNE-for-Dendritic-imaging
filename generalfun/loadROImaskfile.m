function [im_mask, roi_seed_master, dendriteROI_mask, shaft_flag] ...
    = loadROImaskfile(maskfilepath, maskfilename)

variableinfo = who('-file', fullfile(maskfilepath, maskfilename));
im_mask = []; roi_seed_master = []; roi_seed = []; dendriteROI_mask = [];
if ismember('im_norm', variableinfo) 
    load(fullfile(maskfilepath, maskfilename), 'im_norm')
    im_mask = im_norm;
elseif ismember('im_target', variableinfo) 
    load(fullfile(maskfilepath, maskfilename), 'im_target')
    im_mask = im_target;    
end
if ismember('spineROI', variableinfo)
    load(fullfile(maskfilepath, maskfilename), 'spineROI')
    roi_seed_master = zeros(length(spineROI), 2);
    for i = 1:length(spineROI)
        if ~isempty(spineROI(i).roi_seed)
            roi_seed_master(i,:) = spineROI(i).roi_seed;
        else
            roi_seed_master(i,:) = [nan, nan];
        end
    end
else
    fprintf('No spine ROI mask found \n');  
end
if ismember('dendriteROI', variableinfo) 
    load(fullfile(maskfilepath, maskfilename), 'dendriteROI')
    dendriteROI_mask = dendriteROI;
else
    dendriteROI_mask = [];    
    fprintf('No dendrite ROI mask found \n');
end

if ismember('dend_shaft', variableinfo) 
    shaft_flag = 1;
else
    shaft_flag = 0;    
end

if ismember('shaft_flag', variableinfo)
    load(fullfile(maskfilepath, maskfilename), 'shaft_flag')
end

