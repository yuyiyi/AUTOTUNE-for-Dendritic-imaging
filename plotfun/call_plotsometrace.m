function call_plotsometrace(handles)
mainfig_pos = get(handles.mainfigure, 'Position');
clear trace_stamp_pool trace_num_all ttlabel_pool
for k = 1:length(handles.datafilename)
    handles = loadtrace(handles, k);
    framestamp = handles.framestamp{1};
    stampinfo = handles.stampinfo{1};
    if handles.plotRawdff == 0 && handles.plotBAPdff == 0
        handles.plotRawdff = 1;
        set(handles.useBAPremove, 'Value', 0)
        set(handles.useRawtrace, 'Value', 1)        
    end
    %%%%% pool all trace for analysis
    [trace_stamp1, trace_num1, ttlabel1] = pooltrace(handles);

    ttlabel_pool(1:length(ttlabel1),k) = ttlabel1;
    trace_stamp_pool(k).trace_stamp = trace_stamp1;
    trace_num_all(k) = trace_num1;
    
end
    [neusel] = prepPlottrace(handles, ttlabel_pool, mainfig_pos);
    if ~isempty(neusel)
            scrsz = handles.scrsz;
            pos_BAPremove = round([50 50 min(scrsz(3)/2,600) scrsz(4)*0.8]);
            pos = pos_BAPremove;    
        for i1 = 1:ceil(size(neusel,1)/10)
            hplot = figure(22); clf('reset')
            set(hplot,'Name', 'Click on the figure to show more traces' ,'Position', pos);
            for i2 = 1:10
                i = i2+(i1-1)*10;
                if i<=size(neusel,1)
                    a = neusel(i,1);
                    b = neusel(i,2);
                    subplot(10,1,i2), plot(trace_stamp_pool(b).trace_stamp(:,a))
                    title(['dataset', num2str(b), '  ', ttlabel_pool{a,b}])
                end
            end
            if i1 < ceil(size(neusel,1)/10)
                waitforbuttonpress
            end
        end
    else
        traceplot22(handles)
    end
end
