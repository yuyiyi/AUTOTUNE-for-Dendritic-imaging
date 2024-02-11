function [RegPara, handles, imageinfo, figuretitlename, continueflag, w, fext]...
    = get_imageinfo(handles, k, RegPara)
continueflag = 1;
[imagefolder, imagefilename, fext] = fileparts(handles.Datalist{k});
RegPara.imagefolder = imagefolder;
RegPara.filename = imagefilename;
savename = handles.savenamelist{k};
figuretitlename = regexprep(imagefilename,'_', '\_');
RegPara.savenamebase = savename;

if ~isempty(fext)
    % single file image stack
    imageinfo = imfinfo(handles.Datalist{k});
    handles.crossSessionReg = 0;
    if isempty(imageinfo) 
        msgbox([figuretitlename, ' fail to load'] , 'Warning', 'warn');            
        continueflag = 0;
    elseif length(imageinfo)==1
        tmp = imfinfo(fullfile(imageinfo(1).folder, imageinfo(1).name));
        if length(tmp) == 1
            msgbox([figuretitlename, ' is not a multi-frame movie'], 'Warning', 'warn');
            continueflag = 0;
        else
            handles.Datalist{k} = fullfile(imageinfo(1).folder, imageinfo(1).name);
            imageinfo = imfinfo(handles.Datalist{k});
        end
    end

else
    % folder of imaging sequence (allow cross stack registration)
    imageinfo = dir(fullfile(handles.Datalist{k}, '*.tif'));
    if isempty(imageinfo)
        imageinfo = dir(fullfile(handles.Datalist{k}, '*.tiff'));
    end
    tmp = imfinfo(fullfile(imageinfo(1).folder, imageinfo(1).name));
    if length(imageinfo)==1 && length(tmp) == 1
        msgbox([figuretitlename, ' is not a multi-frame movie'], 'Warning', 'warn');
        continueflag = 0;
    elseif length(imageinfo)>1 && length(tmp) == 1
        handles.crossSessionReg = 0;
    end
    if length(tmp) > 1
        handles.crossSessionReg = 1;
    end
end
% assignin('base', 'imageinfo', imageinfo);
    
if continueflag == 1 && handles.crossSessionReg == 0
%     imglist = 1:length(imageinfo);
    RegPara.Imagelength = length(imageinfo);
    assignin('base', 'imageinfo', imageinfo)
%     RegPara.NiterPrealign = 20;
    if ~isempty(fext)
        I1 = imread(handles.Datalist{k}, 1);
    else
        I1 = imread(fullfile(handles.Datalist{k}, imageinfo(1).name));
    end
    w = whos('I1');
    RegPara.RawPrecision = class(I1);
    RegPara.Imagesize = size(I1);
    RegPara.I_min = min(I1(:));   
    RegPara.I_max = max(I1(:));
    if not(strcmp(RegPara.RawPrecision, 'single') || strcmp(RegPara.RawPrecision, 'double') ...
            || strcmp(RegPara.RawPrecision, 'int8') || strcmp(RegPara.RawPrecision, 'int16') ...
            || strcmp(RegPara.RawPrecision, 'uint8') || strcmp(RegPara.RawPrecision, 'uint16'))
        msgbox([RegPara.RawPrecision, ' is not a supported format'], 'Warning', 'warn');
        continueflag = 0;
    end
    
elseif continueflag == 1 && handles.crossSessionReg == 1
    for i = 1:length(imageinfo)
        tmp = imfinfo(fullfile(imageinfo(i).folder, imageinfo(i).name));
        RegPara.Imagelength(i) = length(tmp);        
    end
    
%     RegPara.NiterPrealign = 20;
    I1 = imread(fullfile(handles.Datalist{k}, imageinfo(1).name), 1);
    w = whos('I1');
    RegPara.RawPrecision = class(I1);
    RegPara.Imagesize = size(I1);
    RegPara.I_min = min(I1(:));   
    RegPara.I_max = max(I1(:));
    if not(strcmp(RegPara.RawPrecision, 'single') || strcmp(RegPara.RawPrecision, 'double') ...
            || strcmp(RegPara.RawPrecision, 'int8') || strcmp(RegPara.RawPrecision, 'int16') ...
            || strcmp(RegPara.RawPrecision, 'uint8') || strcmp(RegPara.RawPrecision, 'uint16'))
        msgbox([RegPara.RawPrecision, ' is not a supported format'], 'Warning', 'warn');
        continueflag = 0;
    end
end
RegPara.MultiStackReg = handles.crossSessionReg;
