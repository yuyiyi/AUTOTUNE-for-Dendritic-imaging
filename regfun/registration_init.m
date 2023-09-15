function handles = registration_init(handles)
handles.savingflag = 0;
handles.savepath = '';

% set input data type
if handles.datatype == 1
    set(handles.moviedata_check, 'Value', 1)
    set(handles.imageseq_check, 'Value', 0)
elseif handles.datatype == 2
    set(handles.moviedata_check, 'Value', 0)
    set(handles.imageseq_check, 'Value', 1)
end

handles.currentImagelist = '';
handles.savenamelist = '';
set(handles.savenametable, 'Enable', 'off')
set(handles.savenametable, 'Data', handles.savenamelist')

handles.filepath = '';
handles.currentImagelist = '';
set(handles.filelistbox, 'Enable', 'off');
set(handles.filelistbox, 'string', '');
set(handles.currentsavingpath, 'String',  handles.savepath)

% reset multi-stack registration
handles.crossSessionReg = 0;
set(handles.CrossSessionReg_check, 'Value',  handles.crossSessionReg)

% low snr check
set(handles.lowSNR_check, 'Value',  handles.lowSNR)

set(handles.showresult_check, 'Value',  handles.showresult)

% set save data type
set(handles.savetoBin_check, 'Value',  handles.savetoBin)
set(handles.savetoTif_check, 'Value',  handles.savetoTif)
set(handles.saveSubsample_check, 'Value',  handles.savesubsampletif)
set(handles.ind_subsample, 'String',  handles.subsampleRate*100)
set(handles.ind_fileNum, 'String',  0)
