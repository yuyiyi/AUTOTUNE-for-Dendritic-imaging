function [handles, RegPara] = callregistration(handles)

for k = 1:length(handles.Datalist)
    clear RegPara
    RegPara.savepath               = handles.savepath;
    RegPara.useGPU                 = handles.useGPU; % if you can use a GPU in matlab this accelerate registration approx 3 times
    RegPara.PhaseCorrelation       = 1; % set to 0 for non-whitened cross-correlation
    RegPara.SubPixel               = Inf; % 2 is alignment by 0.5 pixel, Inf is the exact number from phase correlation
%     frac = k/length(handles.Datalist)*0.1;
    frac = 0.1;
    f_wait = waitbar(frac, sprintf('Register data %d of %d', k, length(handles.Datalist)));
    [RegPara, handles, imageinfo, figuretitlename, continueflag, w, fext]...
        = get_imageinfo(handles, k, RegPara);
    handles.crossSessionReg
    if continueflag == 0
        continue
    end
    
    if handles.crossSessionReg == 0
        RegPara = reg_NoCrossStack(RegPara, handles, imageinfo, figuretitlename, fext, k, w, f_wait);
    else
        RegPara = reg_WithCrossStack(RegPara, handles, imageinfo, figuretitlename, fext, k, w, f_wait);
    end
    %%%%%% save registration results %%%%%%
    save(fullfile(RegPara.savepath, [RegPara.savenamebase,'Parameter.mat']), 'RegPara');  
    fprintf([figuretitlename, ' registration results saved ']);
    toc
%     close(f_wait)
%     delete(f_wait)
end

