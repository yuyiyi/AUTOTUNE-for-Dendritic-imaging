function [handles] = callBAPsubtract_master(handles, dataID)
if nargin<2
    dataID = 1;
end
f_wait = waitbar(0.5, 'Auto processing Backpropagation removal');
scrsz = handles.scrsz;
handles = call_autoBAP(handles);
traceplot22(handles)
close(f_wait);
delete(f_wait);
if handles.openGUI==0
    comIn = input('Start manual BAP removal Y/N [y/n]: ', 's');    
    if strcmp(comIn, 'y')
        if ~isempty(handles.spineROI)
            spID = handles.spine_title;
        [handles.spine_BAPremoval_coef, handles.spine_trace_BAPremoval] = ...
            BAPupdate_CMD(handles.spine_dff, handles.spine_BAPremoval_coef,...
            handles.spine_trace_BAPremoval,handles.spine_BAP_current, scrsz, 'Spine', spID);
        end
        if ~isempty(handles.dend_shaft)
            shID = handles.shaft_title;
        [handles.shaft_BAPremoval_coef, handles.shaft_trace_BAPremoval] = ...
            BAPupdate_CMD(handles.shaft_dff, handles.shaft_BAPremoval_coef,...
            handles.shaft_trace_BAPremoval,handles.shaft_BAP_current, scrsz, 'Shaft', shID);
        end
    end
    traceplot22(handles)
    fprintf('All spine processed \n')
else
    comIn = questdlg('Start manual BAP removal');
    if strcmp(comIn, 'Yes')
        if ~isempty(handles.spineROI)
            spID = handles.spine_title;
        [handles.spine_BAPremoval_coef, handles.spine_trace_BAPremoval] = ...
            BAPupdate_GUI(handles.spine_dff, handles.spine_BAPremoval_coef,...
            handles.spine_trace_BAPremoval,handles.spine_BAP_current, scrsz, 'Spine', spID);
        end
        if ~isempty(handles.dend_shaft)
            shID = handles.shaft_title;
        [handles.shaft_BAPremoval_coef, handles.shaft_trace_BAPremoval] = ...
            BAPupdate_GUI(handles.shaft_dff, handles.shaft_BAPremoval_coef,...
            handles.shaft_trace_BAPremoval,handles.shaft_BAP_current, scrsz, 'Shaft', shID);
        end
        traceplot22(handles)
        msgbox('All spine processed');
    end 
end
if ~isempty(handles.spineROI)
    spID = handles.spine_title;
    spineROI = handles.spineROI;
    for i = 1:length(spID)
        spineROI(spID(i)).dff_BAPremoval = handles.spine_trace_BAPremoval(:,i);
        spineROI(spID(i)).BAPremoval_coef = handles.spine_BAPremoval_coef(:,i);    
        spineROI(spID(i)).BAP_current = handles.spine_BAP_current(:,i);
    end
    handles.spineROI = spineROI;
    save(fullfile(handles.datafilepath, handles.datafilename{dataID}), 'spineROI', '-append')
end
if ~isempty(handles.dend_shaft)
    shID = handles.shaft_title;
    dend_shaft = handles.dend_shaft;
    k = 0;
    for i = 1:length(dend_shaft)
        if ~isempty(dend_shaft(i).shaft_trace)
            k = k+1;
            dend_shaft(i).dff_BAPremoval = handles.shaft_trace_BAPremoval(:,k);
            dend_shaft(i).BAPremoval_coef = handles.shaft_BAPremoval_coef(:,k);    
            dend_shaft(i).BAP_current = handles.shaft_BAP_current(:,k);
        else
            dend_shaft(i).dff_BAPremoval = [];
            dend_shaft(i).BAPremoval_coef = [];    
            dend_shaft(i).BAP_current = [];            
        end
    end
    handles.dend_shaft = dend_shaft;
    save(fullfile(handles.datafilepath, handles.datafilename{dataID}), 'dend_shaft', '-append')
end

notesBAPremoval = 'BAPremoval on df/f';
save(fullfile(handles.datafilepath, handles.datafilename{dataID}), 'notesBAPremoval', '-append')
