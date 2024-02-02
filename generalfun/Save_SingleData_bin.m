function Save_SingleData_bin(handles, f_wait)
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
    
grad = handles.movieinputgrad;
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
            if ~isempty(handles.spineROI)
                spineROI = handles.spineROI;
                spine_trace_current = zeros(handles.imagelength(j), length(spineROI));
                for i=1:length(spineROI)
                    if ~isempty(spineROI(i).spine_pixel)
                        tc_tmp = mean(mov(spineROI(i).spine_pixel,:),1)';
                        spine_trace_current(:,i) = tc_tmp;
                    end
                end
                spine_trace_full = cat(1, spine_trace_full, spine_trace_current);
            end
            if ~isempty(handles.dendrite)
                dendriteROI = handles.dendrite;                
                dend_trace_current = zeros(handles.imagelength(j), length(dendriteROI));
                for i = 1:length(dendriteROI)
                    if ~isempty(dendriteROI(i).dend_pixel)
                        dend_trace_tmp = mean(mov(dendriteROI(i).dend_pixel,:),1)';
                        dend_trace_current(:,i) = dend_trace_tmp;
                    end
                end
                 dend_tracefull = cat(1, dend_tracefull, dend_trace_current);
            end
            if ~isempty(handles.dend_shaft)
                dend_shaft = handles.dend_shaft;
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
    
else
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
        save(fullfile(handles.savepath, handles.savename), 'spineROI', '-append')
    end
    if ~isempty(handles.dend_shaft)
        dend_shaft = handles.dend_shaft;
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
end

waitbar(1, f_wait, 'Saving');
close(f_wait)
delete(f_wait)
