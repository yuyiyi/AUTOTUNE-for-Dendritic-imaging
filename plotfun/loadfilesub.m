function [framestamp, stampinfo, handles]= loadfilesub(variableinfo, framestampvariable,...
    stampinfovariable,k, filename, filepath, dirtemp, datafilename, handles)
    framestamp = [];
    stampinfo = [];
    if ismember(framestampvariable, variableinfo) 
        a = load(dirtemp, framestampvariable);
        framestamp = a.(framestampvariable);
        handles.framestampname{k} = filename;
        handles.framestamppath{k} = filepath;
    else
        handles.framestampname{k} = '';
        handles.framestamppath{k} = '';
    end
    if ismember(stampinfovariable, variableinfo) 
        b = load(dirtemp, stampinfovariable);
        stampinfo = b.(stampinfovariable);        
        handles.stampinfoname{k} = filename;
        handles.stampinfopath{k} = filepath;
    else
        handles.stampinfoname{k} = '';
        handles.stampinfopath{k} = '';
    end
%     if ~isempty(framestamp) && isempty(stampinfo)
%         if size(framestamp, 2) == 1
%             t0 = [1; find(diff(framestamp)~=0)+1];
%             t1 = [find(diff(framestamp)~=0);length(framestamp)];
%             g = framestamp(t0);
%             glist = sort(unique(g),1);
%             if isempty(stampinfo) || length(glist) ~= length(stampinfo)
%                 stampinfo = glist';
%             end
% 
%             if ~isempty(stampinfo)
%                 save(fullfile(handles.datafilepath, datafilename), 'stampinfo', '-append')
%             end
%         end
%     end
end

