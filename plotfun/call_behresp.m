function call_behresp(handles)
mainfig_pos = get(handles.mainfigure, 'Position');
clear trace_stamp_pool trace_num_all ttlabel_pool
for k = 1:length(handles.datafilename)
    handles = loadtrace(handles, k);
    framestamp = handles.framestamp{1};
    stampinfo = handles.stampinfo{1};
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
    %
end
neusel = []; ssel = [];
if sum(trace_num_all) == 0
    waitfor(msgbox('No trace data', 'Warning'))
else    
    %%%% set up behavior analysis %%%%%%%%    
    [stampsel, varsel, trialsel, trialIDsel, condsel, plotwin, neusel, dosave, varNames] = ...
        prepBehResp(handles, ttlabel_pool, mainfig_pos)
    trialsel_ID = [];
    ftdur = [0, 2];

    if ~isempty(trialsel) 
        ii = find(strcmp(varNames, trialsel));
        triallabel = table2array(stampinfo(:,ii(1)));
        triallist_all = unique(triallabel);
        if ~isempty(trialIDsel) 
            v = strsplit(trialIDsel, '-');
            tr = str2num(v{1});
            for i = 2:length(v)
                v1 = str2num(v{i});
                tr = cat(2, tr, tr(end):v1(1));
                tr = unique(cat(2, tr, v1));
            end
            trialsel_ID = intersect(tr, triallist_all);
        else
            trialsel_ID = triallist_all;
        end        
    else
        triallabel = [];
    end
    if ~isempty(plotwin)
        v = strsplit(plotwin, '-');
        if length(v) >= 2
            ftdur = [str2num(v{1}), str2num(v{2})];
        end
    end    
    if ~isempty(condsel) && ~strcmp(condsel, 'None')
        ii = find(strcmp(varNames, condsel));
        condflag = table2array(stampinfo(:,ii(1)));
    else
        condflag = [];
    end
    if ~isempty(neusel)
        ssel = neusel(:,2);
        neusel = neusel(:,1);
    end
    if ~isempty(neusel)
        k1 = 0;
        for k = 1:length(handles.datafilename)
            if sum(ssel==k)==0
                continue
            end  
            tc_T = handles.framestamp{k};
            stampinfo = handles.stampinfo{k};
            neusel1 = neusel(ssel==k);
            trace_stamp = trace_stamp_pool(k).trace_stamp(:,neusel1);
            trace_num = length(neusel1);
            ttlabel = ttlabel_pool(neusel1, k);
            datatitle = handles.datafilename{k}(1:end-4);
            
            % the first column should be the timing of behavior parameters
            beh_t = table2array(stampinfo(:,1)); 
            
            % featureflag can be delta function (eg. reward signal), 
            % continuous change (eg. speed), feature blocks (eg. wall feature in linear maze)
            featureflag = table2array(stampinfo(:,strcmp(varNames, stampsel)));
            varlist = table2array(unique(stampinfo(:,strcmp(varNames, stampsel))));
            figiniID = 100+k1;
            BehavResp = BehResp_Ana(handles, trace_stamp, tc_T, featureflag,...
                varsel, varlist, ftdur, condflag, triallabel, beh_t, trialsel_ID,...
                ttlabel, figiniID, datatitle);
            if isempty(condflag)
                savevariblename = ['BehavResp', nameappend];
            else
                figtitle = condsel;
                savevariblename = sprintf('BehavResp_%s%s', figtitle, nameappend);
            end
            if dosave==1 
                tempdata.(savevariblename) = BehavResp;
                save(fullfile(handles.datafilepath, handles.datafilename{k}),...
                    '-struct','tempdata', savevariblename, '-append')
                clear tempdata
            end
            k1 = k1+ceil(trace_num/20);
        end
        msgbox('Done plot')
    else
        msgbox('No trace data found')
    end
end
