function [handles, refreshflag] = addDendrites(handles)
flagadd = 1;
refreshflag = 0;
im_norm = handles.im_norm;
while flagadd == 1
    handles.current_dend_pixel = [];
    handles.current_dend_outline = [];
    handles.current_pt_all = [];
    handles.current_cspoints = [];
    handles.current_dend_trace = [];
    handles.current_dendmask = [];
    flagadd = 0;
    handles = manual_dendrtictrace_v2(handles);
%     handles = manual_dendrtictrace(handles);    
    choice = questdlg('Accept dendrite?', 'Add dendrite', 'Yes and add', 'Yes and finish', 'No and finish', 'No and finish');
    switch choice
        case 'Yes and finish'
            comIn = 'y';
        case 'No and finish'
            comIn = 'n';
        case 'Yes and add'
            comIn = 'y';
            flagadd = 1;
        case ''
            comIn = 'n';                
    end
%         prompt = 'accept dendrite Y/N [y]: ';
%         comIn = input(prompt, 's');
    if (isempty(comIn) || strcmp(comIn, 'y') || strcmp(comIn, 'Y')) &&...
            ~isempty(handles.current_dend_outline)
        handles.dendrite(end+1).dend_pixel = handles.current_dend_pixel;
        handles.dendrite(end).dend_outline = handles.current_dend_outline;
        handles.dendrite(end).points = handles.current_pt_all;
        handles.dendrite(end).dend_line = handles.current_cspoints';
        handles.dendrite(end).trace = handles.current_dend_trace;
        handles.dendrite(end).linewidth = handles.linewidth;
        handles.roimask = handles.roimask + handles.current_dendmask;
        refreshflag = 1;
        axes(handles.DisplayResult)
        hold on, 
        if str2double(handles.Mver(end-4:end))<2019
            h1 = impoly(gca, handles.current_dend_outline);
            h1.Deletable = false;
            setVerticesDraggable(h1, false) 
        else
            h1 = drawpolygon('Position', handles.current_dend_outline, 'InteractionsAllowed', 'none', 'LineWidth', 0.2, 'FaceAlpha', 0);
        end        
        axes(handles.CalciumTrace_dendrite), hold on, plot(1:handles.size(3), handles.current_dend_trace)
        drawnow
        dendriteROI = handles.dendrite;
        if exist(fullfile(handles.savepath, handles.savename), 'file')==0
            save(fullfile(handles.savepath, handles.savename), 'im_norm', 'dendriteROI')
        else
            save(fullfile(handles.savepath, handles.savename), 'im_norm', 'dendriteROI', '-append')        
        end
    end
end
close(figure(20))
