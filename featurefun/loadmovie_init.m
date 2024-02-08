function [loadmovieflag, I1, Mem_max, w, handles] = loadmovie_init(handles)

loadmovieflag = 0;
w = [];
I1 = [];
[imagefolder, imagefilename, fext] = fileparts(handles.filename);
handles.fext = fext;
savename = [regexprep(imagefilename,' ', '_'), '_roi.mat'];
handles.savename = savename;

figuretitlename = regexprep(imagefilename,'_', '\_');

[userview, systemview] = memory;
fprintf('Available memory')
disp(systemview.PhysicalMemory.Available)
Mem_max = systemview.PhysicalMemory.Available;

if ~isempty(fext)
    imageinfo = imfinfo(fullfile(handles.filepath, handles.filename));
else
    imageinfo = dir(fullfile(handles.filepath, handles.filename, '*.tif'));
    if isempty(imageinfo)
        imageinfo = dir(fullfile(handles.filepath, handles.filename, '*.tiff'));
    end
end
if isempty(imageinfo) 
    msgbox([figuretitlename, ' fail to load'] , 'Warning', 'warn');            
elseif length(imageinfo)==1
    msgbox([figuretitlename, ' is not a multi-frame movie'], 'Warning', 'warn');
else 
    if ~isempty(fext)
        I1 = imread(fullfile(handles.filepath, handles.filename), 1);
    else
        I1 = imread(fullfile(handles.filepath, handles.filename, imageinfo(1).name));
    end
    w = whos('I1');
    BitsPerSample = w.bytes/w.size(1)/w.size(2);
    handles.BitsPerSample = BitsPerSample;
    handles.bytesPerImage = w.bytes;
    handles.RawPrecision = class(I1);
    handles.imagelength = length(imageinfo);
    handles.imageinfo = imageinfo;
    gradraw1 = w.bytes*length(imageinfo)/(Mem_max*0.7);
    gradraw2 = length(imageinfo)/min(length(imageinfo), 10000);
    handles.WorkingPrecision = handles.RawPrecision;
    grad = max(ceil(gradraw1), ceil(gradraw2));
    handles.movieinputgrad = grad;
    handles.movieframeID = 1:grad:length(imageinfo);
%     length(1:grad:length(imageinfo))
    loadmovieflag = 1;
end