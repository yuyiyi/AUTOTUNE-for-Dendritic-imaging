function Save_SingleData_bin(handles, f_wait, ifhold)
if nargin == 1
    f_wait = waitbar(0.2,'Saving');
end
if nargin < 3
    ifhold = 1;
end
moviedir = fullfile(handles.filepath, handles.filename);
im_norm = handles.im_norm;
Feature_parameters = handles.defaultPara;
Feature_parameters.BitsPerSample = handles.BitsPerSample;
Feature_parameters.bytesPerImage = handles.bytesPerImage;
Feature_parameters.RawPrecision = handles.RawPrecision;
Feature_parameters.imagelength = handles.imagelength;
Feature_parameters.imagesize = handles.size;
Feature_parameters.useGPU = handles.useGPU;
if exist(fullfile(handles.savepath, handles.savename), 'file')==0
    save(fullfile(handles.savepath, handles.savename), 'im_norm', 'moviedir','Feature_parameters', '-v7.3')
else
    save(fullfile(handles.savepath, handles.savename), 'im_norm', 'moviedir','Feature_parameters', '-append')
end
if ~isempty(handles.Regfile)
    RegResult = handles.Regfile;
    save(fullfile(handles.savepath, handles.savename), 'RegResult', '-append')
end
grad = handles.movieinputgrad;

dendriteROI = [];
spineROI = [];
dend_shaft = [];
if ~isempty(handles.dendrite)
    dendriteROI = handles.dendrite;
end
if ~isempty(handles.spineROI)
    spineROI = handles.spineROI;
    roi_seed = reshape([spineROI.roi_seed], 2,[])';
end
if ~isempty(handles.dend_shaft)
    dend_shaft = handles.dend_shaft;
    if ~isfield(dend_shaft, 'dendloc_linear')
        dend_shaft = shaftloc(dend_shaft, dendriteROI);
    end
    if ~isfield(dend_shaft, 'shaft_trace') && grad == 1
        for i = 1:length(dend_shaft)
            pointID = dend_shaft(i).shaft_pixel;
            tracetmp = mean(handles.mov(pointID,:),1)';
            dend_shaft(i).shaft_trace = tracetmp; 
        end
    end
end

if ~isempty(dendriteROI) && ~isempty(spineROI)
    if ~isfield(spineROI, 'dendriteID') || ~isfield(spineROI, 'dendloc_linear')
    [nearestID, dend_arcloc, dendloc] = nearestDendrite(roi_seed, dendriteROI, handles, ifhold);
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

if grad > 1 
    [Ly, Lx] = size(handles.im_norm);
    binfilelist = handles.RegPara.savename;
    spine_trace_full = []; dend_tracefull = []; shaft_tracefull = [];
    for j = 1:length(binfilelist)
%         moviedir{j} = fullfile(handles.filepath, binfilelist{j})
        clear mov; 
        waitbar(j/length(binfilelist)*0.5, f_wait, 'It is a long movie, saving in progress');
        fig = fopen(fullfile(handles.filepath, binfilelist{j}), 'r');
        mov = fread(fig, Ly*Lx*handles.imagelength(j), [handles.WorkingPrecision '=>' handles.WorkingPrecision]);
        mov = reshape(mov, Ly*Lx,handles.imagelength(j));
        fclose(fig);
        if ~isempty(mov)
            if ~isempty(spineROI)
                spine_trace_current = zeros(handles.imagelength(j), length(spineROI));
                for i=1:length(spineROI)
                    if ~isempty(spineROI(i).spine_pixel)
                        tc_tmp = mean(mov(spineROI(i).spine_pixel,:),1)';
                        spine_trace_current(:,i) = tc_tmp;
                    end
                end
                spine_trace_full = cat(1, spine_trace_full, spine_trace_current);
            end
            if ~isempty(dendriteROI)
                dend_trace_current = zeros(handles.imagelength(j), length(dendriteROI));
                for i = 1:length(dendriteROI)
                    if ~isempty(dendriteROI(i).dend_pixel)
                        dend_trace_tmp = mean(mov(dendriteROI(i).dend_pixel,:),1)';
                        dend_trace_current(:,i) = dend_trace_tmp;
                    end
                end
                 dend_tracefull = cat(1, dend_tracefull, dend_trace_current);
            end
            if ~isempty(dend_shaft)
                shaft_trace_current = zeros(handles.imagelength(j), length(dend_shaft));
                for i = 1:length(dend_shaft)
                    if ~isempty(dend_shaft(i).shaft_pixel)
                        shaft_trace_tmp = mean(mov(dend_shaft(i).shaft_pixel,:),1)';
                        shaft_trace_current(:,i) = shaft_trace_tmp;
                    end
                end
                shaft_tracefull = cat(1, shaft_tracefull, shaft_trace_current);
            end
        end
    end
    waitbar(0.9, f_wait, 'It is a long movie, saving in progress');
    if ~isempty(spineROI)
        for i=1:length(spineROI)
            if ~isempty(spineROI(i).spine_trace)
                spineROI(i).spine_trace = spine_trace_full(:,i);
            end
        end
    end
    if ~isempty(handles.dendrite)
        for i = 1:length(dendriteROI)
            if ~isempty(dendriteROI(i).trace)
                dendriteROI(i).trace = dend_tracefull(:,i);
            end
        end
    end
    if ~isempty(handles.dend_shaft)
        for i=1:length(dend_shaft)
            if ~isempty(dend_shaft(i).shaft_pixel)
                dend_shaft(i).shaft_trace = shaft_tracefull(:,i);
            end
        end
    end    
end
savedff_all(dendriteROI, spineROI, dend_shaft, handles)


waitbar(1, f_wait, 'Saving');
close(f_wait)
delete(f_wait)


function savedff_all(dendriteROI, spineROI, dend_shaft, handles)
    if ~isempty(dendriteROI)
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

    if ~isempty(spineROI)
        for k = 1:length(spineROI)
            spine_dff = [];
            spine_trace_current = spineROI(k).spine_trace;
            if ~isempty(spine_trace_current)
                spine_dff = getdff(spine_trace_current);
            end
            spineROI(k).spine_dff = spine_dff;
        end        
        save(fullfile(handles.savepath, handles.savename), 'spineROI', '-append')
    end
    if ~isempty(dend_shaft)
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


