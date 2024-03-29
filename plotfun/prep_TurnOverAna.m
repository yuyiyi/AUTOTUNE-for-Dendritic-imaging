function [thresholdvalue, targetID] = prep_TurnOverAna(handles)
    % thresholdvalue = 3;
    thresholdvalue = handles.defaultPara.spineRetain;
    targetID = 1;
    
    N = length(handles.datafilename);
    
    mainfig_pos = get(handles.mainfigure, 'Position');   
    scrsz = handles.scrsz;
    pos = mainfig_pos;
    pos(1) = pos(1)+50;
    pos(3) = 300;
    pos(4) = 300;
    hplot = figure(25); clf('reset')
    set(hplot, 'NumberTitle', 'off', ...
        'MenuBar', 'none', ...
        'ToolBar', 'none', ...        
        'Name', 'Set up turnover analysis', 'Position', pos);
   

    % list parameters
    panel1 = uipanel('Parent',hplot,'Title','Register to',...
        'Position',[0.05 0.7 0.9 0.25],...
        'FontSize', 10);
    datalist = uicontrol('Parent',panel1, 'Style', 'popupmenu',...
        'Units', 'normalized',...
        'Position',[0.05 0.8 0.9 0.08],...
        'FontSize', 10, ...
        'max', N,...
        'string',handles.datafilename,...
        'Callback', @updatevarPopup);      
    
    % user define time window for plot
    panel3 = uipanel('Parent',hplot,'Title','Threshold for spine matching (pixel):',...
        'Position',[0.05 0.3 0.9 0.25],...
        'FontSize', 10);
    
    answer = uicontrol('Parent',panel3, 'Style', 'edit',...
        'Units', 'normalized',...
        'Position',[0.05 0.5 0.3 0.3],...
        'FontSize', 10, 'Max', 1,...
        'String', num2str(thresholdvalue));
    
    % pushbutton
    uicontrol(hplot,'style','pushbutton',...
        'Units', 'normalized',...
        'String', 'Go',...
        'position', [0.6 0.1 0.3 0.1],...
        'FontSize', 11, ...
        'Callback', @Gopress); 
    
    uiwait(hplot)
    close(hplot)
    
    function updatevarPopup(src, ~)
        targetID = datalist.Value;
    end
  
    function Gopress(hObject, eventdata)
        if get(hObject, 'Value') == 1  
            if ~isempty(str2num(get(answer,'String')))
                thresholdvalue = max(0, str2num(get(answer,'String')));
            else
                thresholdvalue = 3;
            end
            if isempty(targetID)
                targetID = 1;
            end
            uiresume;
            return
        end
    end
end