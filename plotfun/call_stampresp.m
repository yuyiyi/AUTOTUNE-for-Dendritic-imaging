function call_stampresp(handles)
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
neusel = []; ssel = [];
if sum(trace_num_all) == 0
    waitfor(msgbox('No trace data', 'Warning'))
else
    %%%% set up fitting %%%%%%%%
    [stampsel, funcsel, neusel, fmodel,...
        fmodel_Independent,fmodel_Coefficients,fmodel_startpoint,dosave] = ...
        prepFitting(handles, ttlabel_pool, mainfig_pos);
    if ~isempty(neusel)           
        ssel = neusel(:,2);
        neusel = neusel(:,1);       
    end
    if isempty(stampsel)
        stampsel = 1:length(stampinfo);
    end
    xvalue = [];
    if iscell(stampinfo)
        xvalue = [];
        for j = 1:length(stampsel)
            tmp = stampinfo{stampsel(j)};
            if isnumeric(tmp)
                xvalue(j) = tmp;
            else
                xvalue(j) = str2double(tmp);
            end
        end
    elseif isnumeric(stampinfo)
        xvalue = stampinfo(stampsel);
    else
        msgbox('Stamp label should be numerical for simple fitting!')
        funcsel = 1;
    end
    if funcsel>1
        stampsel(isnan(xvalue)) = [];
        xvalue(isnan(xvalue)) = [];
        if length(xvalue)<3
            msgbox('Not enough distinct stamps for simple fitting!')
            funcsel = 1;
        end            
    end
    if handles.ifmultiplypi == 1
        xvalue = xvalue*pi;
    end

    if ~isempty(neusel)
        k1 = 0;
        for k = 1:length(handles.datafilename)
            if sum(ssel==k)==0
                continue
            end        
            neusel1 = neusel(ssel==k);
            trace_stamp = trace_stamp_pool(k).trace_stamp(:,neusel1);
            trace_num = length(neusel1);
            ttlabel = ttlabel_pool(neusel1, k);
            datatitle = handles.datafilename{k}(1:end-4);
            framestamp = handles.framestamp{k};
            stampinfo = handles.stampinfo{k};

            if funcsel == 1 || isempty(fmodel)
                figiniID = 100+k1;
                [trace_mean, trace_std, trace_sem, glist] = stampResp(...
                    trace_stamp, framestamp, stampinfo, ttlabel, stampsel,...
                    xvalue, handles,figiniID, datatitle);
                StampResp.trace_mean = trace_mean;
                StampResp.trace_std = trace_std;
                StampResp.trace_sem = trace_sem;
                StampResp.rowstamp = stampinfo;
                StampResp.coltitle = ttlabel;
                handles.StampResp = StampResp;
                if dosave==1
                    save(fullfile(handles.datafilepath, handles.datafilename{k}), 'StampResp', '-append')
                end            
            elseif funcsel > 1 && ~isempty(fmodel)
                figiniID = 500+k1;
                [fitresult, figtitle, fmodel, xx, y] = FitstampResp(...
                    trace_stamp, framestamp, stampsel, fmodel,...
                    fmodel_Independent,fmodel_startpoint,...
                    funcsel, xvalue, handles, ttlabel,figiniID, datatitle);
                StampRespFit.coefficient = fitresult;
                StampRespFit.notes = figtitle;
                StampRespFit.fitmodel = fmodel;
                StampRespFit.xdata = xx;
                StampRespFit.ydata = y;            
                StampRespFit.stamplabel = xvalue;
                StampRespFit.coltitle = ttlabel;
                savevariblename = sprintf('StampRespFit_%s', figtitle);
                handles.StampRespFit = StampRespFit;
                if dosave==1 
                    tempdata.(savevariblename) = StampRespFit;
                    save(fullfile(handles.datafilepath, handles.datafilename{k}),...
                        '-struct','tempdata', savevariblename, '-append')
                    clear tempdata
                end 
            end
            k1 = k1+ceil(trace_num/20);
        end
    else
        msgbox('No trace data found')
    end
end