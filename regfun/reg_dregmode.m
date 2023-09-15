function [dregmode, Nbatch, savegrad] = reg_dregmode(handles, RegPara, figuretitlename, w, Nbatch)
savename = RegPara.savenamebase;
if handles.savetoTif == 0 && handles.savetoBin == 0 && handles.savesubsampletif == 0
    handles.savetoBin = 1;
    set(handles.savetoBin_check, 'Value',  handles.savetoBin)
    drawnow
end
if handles.savetoTif == 1
    RegPara.savename{1} = savename;
    if not(exist(fullfile(handles.savepath,savename), 'dir'))
        mkdir(fullfile(handles.savepath,savename))
    end
end
fprintf([figuretitlename, ' data size ']); fprintf('%e\n', w.bytes*RegPara.Imagelength)

if handles.savetoBin == 1
    if w.bytes*RegPara.Imagelength(1) > handles.binMaxsize
        fprintf('registration results will be saved as multiple bin files \n')
    end
end

savegrad = 1;
if handles.savesubsampletif == 1
    if handles.subsampleRate==0
        handles.subsampleRate = 0.1;
        set(handles.ind_subsample, 'String',  handles.subsampleRate*100)
        drawnow
    end
    savegrad = max(1, min(round(1/handles.subsampleRate), RegPara.Imagelength(1)));
    Nbatch = floor(Nbatch/savegrad)*savegrad; %%%% need to change
end
Nbatch = max(Nbatch, 1);
fprintf('Batch size %d \n', Nbatch)

if handles.savetoTif == 1 && handles.savetoBin == 0 
    dregmode = 1;
elseif handles.savetoTif == 0 && handles.savetoBin == 1 
    dregmode = 2;
elseif handles.savetoTif == 0 && handles.savetoBin == 0 && handles.savesubsampletif == 1
    % only save subsample results
    dregmode = 0;        
end
fprintf('Dreg mode %d \n', dregmode)
