function [handles, ListOfImageNames] = listselectedfiles(handles)
ListOfImageNames = handles.Datalist;
if handles.datatype == 1 
    [filelist, filepath, cCheck] = uigetfile({'*.tif'; '*.tiff'},...
                                'Select Movies To Be Processed', ...
                                'MultiSelect', 'on');
    if (cCheck~=0)
        handles.filepath = filepath;
        if ~isempty(filelist)
            if iscell(filelist)
                handles.currentImagelist = filelist;
            elseif ~isempty(filelist)
                handles.currentImagelist = {filelist}; 
            else
                handles.currentImagelist = '';             
            end 
        end
        for Index = 1:length(handles.currentImagelist)
            % Get the base filename and extension.
            baseFileName = fullfile(handles.filepath, handles.currentImagelist{Index});
            if isempty(ListOfImageNames) || ~any(strcmp(baseFileName, ListOfImageNames))
                ListOfImageNames{end+1} = baseFileName;
                handles.Datalist{end+1} = baseFileName;
            end
        end
    end
elseif handles.datatype == 2
    root_filepath = uigetdir(handles.filepath, 'Select Folders To Be Processed');
    if root_filepath~=0
        allSubfolders = genpath(root_filepath);
        subFolders = regexp(allSubfolders, ';', 'split');
        if length(subFolders)>2
           handles.filepath = root_filepath;
           for k = 2:length(subFolders)
                % Get this subfolder.
                thisSubFolder = subFolders{k};
                if (~isempty(dir(fullfile(thisSubFolder, '*.tif'))) ||...
                        ~isempty(dir(fullfile(thisSubFolder, '*.tiff')))) &&...
                        ~isempty(thisSubFolder)
                    handles.currentImagelist{end+1} = thisSubFolder; 
                end
            end
        else
            [folder, name, extension] = fileparts(root_filepath);
            handles.currentImagelist{end+1} = root_filepath;
            handles.filepath = folder;
        end        
        for Index = 1:length(handles.currentImagelist)
            % Get the base filename and extension.
            baseFileName = handles.currentImagelist{Index};
            if isempty(ListOfImageNames) || ~any(strcmp(baseFileName, handles.Datalist))
                ListOfImageNames{end+1} = baseFileName;
                handles.Datalist{end+1} = baseFileName;
            end
        end
    end
    
elseif handles.datatype == 3
    [filelist, filepath, cCheck] = uigetfile({'*.mat'},...
                                'Select the .RegParameter.mat file To Be Processed', ...
                                'MultiSelect', 'on');
    if (cCheck~=0)
        handles.filepath = filepath;
        if ~isempty(filelist)
            if iscell(filelist)
                handles.currentImagelist = filelist;
            elseif ~isempty(filelist)
                handles.currentImagelist = {filelist}; 
            else
                handles.currentImagelist = '';             
            end 
        end
        for Index = 1:length(handles.currentImagelist)
            % Get the base filename and extension.
            baseFileName = fullfile(handles.filepath, handles.currentImagelist{Index});
            if isempty(ListOfImageNames) || ~any(strcmp(baseFileName, ListOfImageNames))
                ListOfImageNames{end+1} = baseFileName;
                handles.Datalist{end+1} = baseFileName;
            end
        end
    end
end