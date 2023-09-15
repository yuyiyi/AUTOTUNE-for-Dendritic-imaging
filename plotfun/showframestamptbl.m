function handles = showframestamptbl(framestamp, stampinfo, handles)
if ~isempty(framestamp)
%     if min(size(stampinfo)) == 1
%         t0 = [1; find(diff(framestamp)~=0)+1];
%         t1 = [find(diff(framestamp)~=0);length(framestamp)];
%         g = framestamp(t0);
%         glist = sort(unique(g),1);
%         t = table(reshape(glist,[],1), reshape(stampinfo,[],1));
%         t = table2cell(t);
%         set(handles.uit, 'Data', t)
%         varNames = {handles.framestampvariable, handles.stampinfovariable};
%         set(handles.uit, 'ColumnName', varNames)
%     elseif min(size(stampinfo)) > 1
    if min(size(stampinfo)) > 1
        if ~istable(stampinfo)
            stampinfo = array2table(stampinfo);
            handles.stampinfo = stampinfo;
        end
        t = table2cell(stampinfo);
        varNames = stampinfo.Properties.VariableNames;
        set(handles.uit, 'Data', t)
        set(handles.uit, 'ColumnName', varNames)
    end
end