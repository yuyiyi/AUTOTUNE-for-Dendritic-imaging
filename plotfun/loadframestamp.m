function handles = loadframestamp(framestampname, datafilepath, handles)

framestampvariable = handles.framestampvariable;
stampinfovariable = handles.stampinfovariable;

if isempty(framestampname)
    % load frame stamp from data directory
    for k = 1:length(handles.datafilename)
        datafilename = handles.datafilename{k};
        dirtemp = fullfile(datafilepath, datafilename);
        variableinfo = who('-file', fullfile(datafilepath, datafilename));
        [framestamp, stampinfo, handles] = loadfilesub(variableinfo, framestampvariable,...
            stampinfovariable,k, datafilename, datafilepath, dirtemp, datafilename, handles);
        handles.framestamp{k} = framestamp;
        handles.stampinfo{k} = stampinfo;
    end
else
    % load frame stamp from a different directory
    for k = 1:min(length(framestampname), length(handles.datafilename))
        datafilename = handles.datafilename{k};
        dirtemp = fullfile(datafilepath, framestampname{k});
        variableinfo = who('-file', dirtemp);
        
        if ~ismember(framestampvariable, variableinfo) 
            disptext = 'Select custom framestamp column vector';
            variablesel = featuresel(variableinfo, handles, disptext);
            handles.framestampvariable = variableinfo{variablesel(1)};
        end
        framestampvariable = handles.framestampvariable;
        
        if ~ismember(stampinfovariable, variableinfo) 
            disptext = 'Select custom stampinfo vector';
            variablesel = featuresel(variableinfo, handles, disptext);
            handles.stampinfovariable =  variableinfo{variablesel(1)};
        end
        stampinfovariable = handles.stampinfovariable;

        [framestamp, stampinfo, handles] = loadfilesub(variableinfo, ...
            framestampvariable, stampinfovariable,k,...
            framestampname{k}, datafilepath, dirtemp, datafilename, handles);
    
        handles.framestamp{k} = framestamp;
        handles.stampinfo{k} = stampinfo;
        if ~isempty(framestamp)
            save(fullfile(handles.datafilepath, datafilename), 'framestamp', '-append')
        end
        if ~isempty(stampinfo)
            save(fullfile(handles.datafilepath, datafilename), 'stampinfo', '-append')
        end
    end
end

end
