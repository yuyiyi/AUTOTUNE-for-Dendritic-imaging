function [v, smoothwin] = prep_filt(handles)
    v = 0;
    smoothwin = handles.defaultPara.Denoise.movingaverage;
    % smoothwin = 5;
    mainfig_pos = get(handles.mainfigure, 'Position');    
    scrsz = handles.scrsz;
    pos = mainfig_pos;
    pos(1) = pos(1)+100;
    pos(3) = 300;
    pos(4) = 300;
    
    hplot = figure(25); clf('reset')
    set(hplot, 'NumberTitle', 'off', ...
        'MenuBar', 'none', ...
        'ToolBar', 'none', ...        
        'Name', 'Set up denoise function', 'Position', pos);
    if_smooth = uicontrol(hplot,'Style','radiobutton',...
        'Units', 'normalized',...
        'String','Smooth traces by moving average ', ...
        'Position',[0.1 0.65 0.9 0.2],...
        'FontSize', 10,...
        'Callback', @selsmoothpress);
    
    % input variable smooth
    uicontrol('Parent',hplot, 'Style', 'text',...
        'Units', 'normalized',...
        'Position',[0.05 0.5 0.5 0.15],...
        'FontSize', 10, ...
        'string', 'Moving win size');
    fpsinput = uicontrol('Parent',hplot, 'Style','edit',...
        'Units', 'normalized',...
        'FontSize', 10, ...
        'Position',[0.5 0.55 0.3 0.15],...
        'String', smoothwin);
    if_gauss = uicontrol(hplot,'Style','radiobutton',...
        'Units', 'normalized',...
        'String','Denoise baseline by Gauss filt', ...
        'Position',[0.1 0.3 0.9 0.2],...
        'FontSize', 10,...
        'Callback', @selgausspress);
    
    % pushbutton
    p = uicontrol(hplot,'style','pushbutton',...
        'Units', 'normalized',...
        'String', 'Go',...
        'position', [0.5 0.2 0.3 0.1],...
        'FontSize', 11, ...
        'Callback', @Gopress); 
    
    uiwait(hplot)
    close(hplot)
    
    function selsmoothpress(hObject, eventdata)
         vsmooth = get(hObject, 'Value');
         if vsmooth==1
             set(if_gauss, 'Value', 0)
         end
    end
    function selgausspress(hObject, eventdata)
         vgauss = get(hObject, 'Value');
         if vgauss==1
             set(if_smooth, 'Value', 0)
         end
    end

    function Gopress(hObject, eventdata)
        if get(hObject, 'Value') == 1
            smoothwin = str2num(get(fpsinput,'String'));
            if get(if_smooth,'value') == 0 && get(if_gauss,'value') == 0
                v = 0;
            elseif get(if_smooth,'value') == 1 
                v = 1;
                set(if_gauss, 'Value', 0)
            elseif get(if_gauss,'value') == 1 
                v = 2;
                set(if_smooth, 'Value', 0)
            end
            uiresume;
            return
        end
    end

end
        


    
