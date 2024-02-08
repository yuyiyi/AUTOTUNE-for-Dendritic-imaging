function [loadmovieflag, Mem_max, w, handles] = loadbin_init(handles)
if isempty(handles.RegPara)
    RegPara = []; 
    variableinfo = who('-file', fullfile(handles.filepath, handles.filename));
    if ismember('RegPara', variableinfo)
        load(fullfile(handles.filepath, handles.filename), 'RegPara')        
        handles.RegPara = RegPara;
        handles.Regfile = handles.filename;
    end
end
loadmovieflag = 0;
[imagefolder, imagefilename, fext] = fileparts(handles.filename);
handles.fext = fext;
savename = [regexprep(imagefilename(1:end-13),' ', '_'), '_roi.mat'];
handles.savename = savename;

figuretitlename = regexprep(imagefilename(1:end-13),'_', '\_');
[userview, systemview] = memory;
fprintf('Available memory')
disp(systemview.PhysicalMemory.Available)
Mem_max = systemview.PhysicalMemory.Available;

if strcmp(fext, '.mat') && ~isempty(handles.RegPara)
    RegPara = handles.RegPara;
    switch RegPara.RawPrecision
        case 'single'
            BitsPerSample = 4;
        case 'double'
            BitsPerSample = 8;
        case 'int8'
            BitsPerSample = 1;
        case 'uint8'
            BitsPerSample = 1;
        case 'int16'
            BitsPerSample = 2;
        case 'uint16'
            BitsPerSample = 2;
    end    
    w.size = RegPara.Imagesize;
    w.bytes = BitsPerSample * w.size(1) * w.size(2);
    handles.size = w.size;
    handles.BitsPerSample = BitsPerSample;
    handles.bytesPerImage = w.bytes;
    handles.RawPrecision = RegPara.RawPrecision;
    if isfield(RegPara, 'binfilelength')
    handles.imagelength = RegPara.binfilelength;
    else
    handles.imagelength = RegPara.Imagelength;        
    end
    gradraw1 = w.bytes*sum(RegPara.Imagelength)/(Mem_max*0.7);
    gradraw2 = sum(RegPara.Imagelength)/min(sum(RegPara.Imagelength), 40000);
    handles.WorkingPrecision = handles.RawPrecision;
    grad = max(ceil(gradraw1), ceil(gradraw2));
    handles.movieinputgrad = grad;
    handles.movieframeID = 1:grad:sum(RegPara.Imagelength);
    loadmovieflag = 1;
else
    msgbox([figuretitlename, ' fail to load'] , 'Warning', 'warn');            
end