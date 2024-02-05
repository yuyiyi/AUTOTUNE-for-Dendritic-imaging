function Save_SingleData(handles, f_wait)
if nargin == 1
    f_wait = waitbar(0.2,'Saving');
end
moviedir = fullfile(handles.filepath, handles.filename);
im_norm = handles.im_norm;
if exist(fullfile(handles.savepath, handles.savename), 'file')==0
    save(fullfile(handles.savepath, handles.savename), 'im_norm', 'moviedir', '-v7.3')
else
    save(fullfile(handles.savepath, handles.savename), 'im_norm', 'moviedir', '-append')
end
if ~isempty(handles.Regfile)
    RegResult = handles.Regfile;
    save(fullfile(handles.savepath, handles.savename), 'RegResult', '-append')
end

if ~isempty(handles.dendrite)
    dendriteROI = handles.dendrite;
    for i = 1:length(dendriteROI)
        dend_dff = [];
        dend_trace_current = dendriteROI(i).trace;
        if ~isempty(dend_trace_current)
        dend_dff = getdff(dend_trace_current);
        end
        dendriteROI(i).dff = dend_dff;
    end
    save(fullfile(handles.savepath, handles.savename), 'dendriteROI', '-append')
end

if ~isempty(handles.spineROI)
    spineROI = handles.spineROI;
    for k = 1:length(spineROI)
        spine_dff = [];
        spine_trace_current = spineROI(k).spine_trace;
        if ~isempty(spine_trace_current)
            spine_dff = getdff(spine_trace_current);
        end
        spineROI(k).spine_dff = spine_dff;
    end 
    
    if ~isempty(dendriteROI) && ~isempty(spineROI)
        if ~isfield(spineROI, 'dendriteID') || ~isfield(spineROI, 'dendloc_linear')
        [nearestID, dend_arcloc, dendloc] = nearestDendrite(roi_seed, dendriteROI, handles);
        i = 0;
        for k = 1:length(spineROI)
            if ~isempty(spineROI(k).roi_seed)
                i = i+1;
                spineROI(k).dendriteID = nearestID(i);
                spineROI(k).dendloc_linear = dend_arcloc(i);
                spineROI(k).dendloc_pixel = dendloc(i,:);
            end
        end
        end
    end
    save(fullfile(handles.savepath, handles.savename), 'spineROI', '-append')
end
if ~isempty( handles.dend_shaft)
    dend_shaft = handles.dend_shaft;

    if ~isfield(dend_shaft, 'dendloc_linear')
        dend_shaft = shaftloc(dend_shaft, dendriteROI);
    end

    for k = 1:length(dend_shaft)
        shaft_dff = [];
        shaft_trace_current = dend_shaft(k).shaft_trace;
        if ~isempty(shaft_trace_current)
            shaft_dff = getdff(shaft_trace_current);        
            dend_shaft(k).shaft_dff = shaft_dff;
        end
    end
    shaft_flag = handles.shaft_flag;
    save(fullfile(handles.savepath, handles.savename), 'dend_shaft', 'shaft_flag', '-append')
end

grad = handles.movieinputgrad;
L = handles.imagelength;
fext = handles.fext;
if grad > 1 
    waitbar(0.5, f_wait, 'It is a long movie, saving in progress');
    currentframeID = handles.movieframeID;
    if ~isempty(handles.spineROI)
        spine_trace_full = zeros(L, length(spineROI));
        for i=1:length(spineROI)
            trace_current = spineROI(i).spine_trace;
            if ~isempty(trace_current)
                spine_trace_full(currentframeID,i) = trace_current;
            end
        end
    end
    if ~isempty(handles.dendrite)
        dend_tracefull = zeros(L, length(dendriteROI));
        for i = 1:length(dendriteROI)
            dend_trace_current = dendriteROI(i).trace;
            if ~isempty(dend_trace_current)
                dend_tracefull(currentframeID,i) = dend_trace_current;
            end
        end
    end    
    if ~isempty( handles.dend_shaft)
        shaft_tracefull = zeros(L, length(dend_shaft));
        for i = 1:length(dend_shaft)            
            if ~isempty(dend_shaft(i).shaft_trace)
                shaft_trace_current = dend_shaft(i).shaft_trace;
                if ~isempty(shaft_trace_current)
                    shaft_tracefull(currentframeID,i) = shaft_trace_current;
                end
            end
        end
    end

    xi = 2;
    while xi<=grad
        mov = zeros([handles.size(1)*handles.size(2), length(xi:grad:L)], handles.WorkingPrecision);
        j1 = 1;
        for j = xi:grad:L
            if ~isempty(fext)
                I1 = imread(fullfile(handles.filepath, handles.filename), j);
            else
                I1 = imread(fullfile(handles.filepath, handles.filename, handles.imageinfo(j).name));
            end
            mov(:,j1) = I1(:);
            j1 = j1+1;
        end
        currentframeID = xi:grad:L;
        if ~isempty(spineROI)
            for i=1:length(spineROI)
                if ~isempty(spineROI(i).spine_pixel)
                    tc_tmp = mean(mov(spineROI(i).spine_pixel,:),1)';
                    spine_trace_full(currentframeID,i) = tc_tmp;
                end
            end
        end
        if ~isempty(handles.dendrite)
            for i = 1:length(dendriteROI)
                if ~isempty(dendriteROI(i).dend_pixel)
                    dend_trace_tmp = mean(mov(dendriteROI(i).dend_pixel,:),1)';
                    dend_tracefull(currentframeID,i) = dend_trace_tmp;
                end
            end
        end
        if ~isempty(handles.dend_shaft)
            for i = 1:length(dend_shaft)
                if ~isempty(dend_shaft(i).shaft_pixel)
                    shaft_trace_tmp = mean(mov(dend_shaft(i).shaft_pixel,:),1)';
                    shaft_tracefull(currentframeID,i) = shaft_trace_tmp;
                end
            end
        end
        waitbar(0.8, f_wait, 'It is a long movie, saving in progress');
        xi = xi+1;
    end
    
    if ~isempty(handles.spineROI)
        for i=1:length(spineROI)
            if ~isempty(spineROI(i).spine_trace)
                spineROI(i).spine_trace = spine_trace_full(:,i);
                spine_dff = getdff(spine_trace_full(:,i));
                spineROI(i).spine_dff = spine_dff;
            end
        end
        save(fullfile(handles.savepath, handles.savename), 'spineROI', '-append')
    end
    if ~isempty(handles.dendrite)
        for i = 1:length(dendriteROI)
            if ~isempty(dendriteROI(i).trace)
                dendriteROI(i).trace = dend_tracefull(:,i);
                dend_dff = getdff(dend_tracefull);
                dendriteROI(i).dff = dend_dff(:,i);
            end
        end
        save(fullfile(handles.savepath, handles.savename), 'dendriteROI', '-append')
    end
    if ~isempty(handles.dend_shaft)
        for i=1:length(dend_shaft)
            if ~isempty(dend_shaft(i).shaft_pixel)
                dend_shaft(i).shaft_trace = shaft_tracefull(:,i);
                shaft_dff = getdff(shaft_tracefull(:,i));
                dend_shaft(i).shaft_dff = shaft_dff;
            else
                dend_shaft(i).shaft_trace = [];
                dend_shaft(i).shaft_dff = [];
            end
        end
        save(fullfile(handles.savepath, handles.savename), 'dend_shaft', '-append')
    end
end

waitbar(1, f_wait, 'Saving');
close(f_wait)
delete(f_wait)
