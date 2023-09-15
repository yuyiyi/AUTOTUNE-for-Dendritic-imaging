function handles = selectsinglefiles(handles)
if handles.datatype == 1
    [filelist, filepath, cCheck] = uigetfile({'*.tif'; '*.tiff'}, 'Select Movies To Be Processed');
    if (cCheck~=0)
        handles.filepath = filepath;
        if ~isempty(filelist)
            if ~isempty(filelist)
                handles.filename = filelist; 
            else
                handles.filename = '';             
            end 
        end
    end
elseif handles.datatype == 2
    root_filepath = uigetdir(handles.filepath, 'Select Folders To Be Processed');
    if root_filepath~=0
        [folder, name, extension] = fileparts(root_filepath);
        handles.filename = name;
        handles.filepath = folder;
    end    
elseif handles.datatype == 3
    [filelist, filepath, cCheck] = uigetfile({'*.mat'}, 'Select Movies To Be Processed');
    if (cCheck~=0)
        handles.filepath = filepath;
        if ~isempty(filelist)
            if ~isempty(filelist)
                handles.filename = filelist; 
            else
                handles.filename = '';             
            end 
        end
    end
end
if isempty(handles.savepath)
    handles.savepath = handles.filepath;
end