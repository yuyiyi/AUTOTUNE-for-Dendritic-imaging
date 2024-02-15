function call_stampresp_v2(handles)
mainfig_pos = get(handles.mainfigure, 'Position');
clear trace_stamp_pool trace_num_all ttlabel_pool
for k = 1:length(handles.datafilename)
    handles = loadtrace(handles, k);
    if handles.plotRawdff == 0 && handles.plotBAPdff == 0 && handles.plotFiltdff == 0
        handles.plotRawdff = 1;
        set(handles.useBAPremove, 'Value', 0)
        set(handles.useRawtrace, 'Value', 1) 
    elseif handles.plotRawdff == 1
        nameappend = '_raw';
    elseif handles.plotBAPdff == 1 
        nameappend = '_BAPremove';
    elseif handles.plotFiltdff == 1 
        nameappend = '_filt';       
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
    [varsel] = SelVar(handles, mainfig_pos);
    if isempty(varsel)
        return
    else
        varsel = varsel(1);
        [stampsel, glist_all, funcsel, neusel, ifcircular, fmodel,...
         fmodel_Independent,fmodel_Coefficients,fmodel_startpoint,dosave] = ...
         prepFitting(handles, ttlabel_pool, varsel, mainfig_pos);
        handles.circularfit = ifcircular;
        if ~isempty(neusel)           
            ssel = neusel(:,2);
            neusel = neusel(:,1);       
        end
        if isempty(stampsel)
            stampsel = 1:length(glist_all);
        end
        xvalue = [];
        for j = 1:length(stampsel)
            tmp = glist_all(stampsel(j));
            if isnumeric(tmp)
                xvalue(j) = tmp;
            elseif isnumeric(str2double(tmp))
                xvalue(j) = str2double(tmp);
            else
                msgbox('Stamp label should be numerical for simple fitting!')
                funcsel = 1;
                xvalue(j) = nan;
            end
        end
        if funcsel>1
            if sum(~isnan(xvalue))<3
                msgbox('Not enough distinct numerical stamps for simple fitting!')
                funcsel = 1;
            else
                stampsel(isnan(xvalue)) = [];
                xvalue(isnan(xvalue)) = [];
            end
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
                    [trace_mean, trace_std, trace_sem, glist] = stampResp_v2(...
                        trace_stamp, framestamp, stampinfo, ttlabel, stampsel, ...
                        varsel, glist_all,...
                        xvalue, handles,figiniID, datatitle);
                    StampResp.trace_mean = trace_mean;
                    StampResp.trace_std = trace_std;
                    StampResp.trace_sem = trace_sem;
                    StampResp.rowstamp = glist;
                    StampResp.coltitle = ttlabel;
                    savevariblename = sprintf('StampResp_%s%s', nameappend);
                    handles.StampResp = StampResp;
                    if dosave==1
%                         save(fullfile(handles.datafilepath, handles.datafilename{k}),...
%                             ['StampResp', nameappend], '-append')
                        tempdata.(savevariblename) = StampResp;
                        save(fullfile(handles.datafilepath, handles.datafilename{k}),...
                            '-struct','tempdata', savevariblename, '-append')
                        clear tempdata
                    end            
                elseif funcsel > 1 && ~isempty(fmodel)
                    figiniID = 500+k1;
                    [fitresult, figtitle, fmodel, xx, y] = FitstampResp_v2(...
                        trace_stamp, framestamp, stampsel, stampinfo, glist_all, varsel,...
                        fmodel, fmodel_Independent,fmodel_startpoint,...
                        funcsel, xvalue, handles, ttlabel,figiniID, datatitle);
                    StampRespFit.coefficient = fitresult;
                    StampRespFit.notes = figtitle;
                    StampRespFit.fitmodel = fmodel;
                    StampRespFit.xdata = xx;
                    StampRespFit.ydata = y;            
                    StampRespFit.stamplabel = xvalue;
                    StampRespFit.coltitle = ttlabel;
                    savevariblename = sprintf('StampRespFit_%s%s', figtitle, nameappend);
                    handles.StampRespFit = StampRespFit;
                    handles.MetaInfor.StampRespfiltertype = figtitle;
                    handles.MetaInfor.StampRespfilterFunc = fmodel;
                    if dosave==1 
                        MetaInfor = handles.MetaInfor;
                        save(fullfile(handles.datafilepath, handles.datafilename{k}), 'MetaInfor', '-append')
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
end