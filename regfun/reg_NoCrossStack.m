function RegPara = reg_NoCrossStack(RegPara, handles, imageinfo, figuretitlename, fext, k, w, f_wait)
[userview, systemview] = memory;
% fprintf('Available memory')
disp(systemview.PhysicalMemory.Available)
Mem_max = systemview.PhysicalMemory.Available;
if handles.useGPU
    Mem_max = min(systemview.PhysicalMemory.Available, handles.gpudev.AvailableMemory/2);
end

% frac = k/length(handles.Datalist)*0.1;
% f_wait = waitbar(frac, sprintf('Register data %d of %d', k, length(handles.Datalist)));

imglist = 1:length(imageinfo);
%%%%% registration initialization
Nbatch = min(floor(Mem_max/w.bytes/4), RegPara.Imagelength);
fprintf([figuretitlename, ' registration initializing \n'])
tic
RegPara.NimgFirstRegistration  = max(min(RegPara.FrameNoiniAlign, ceil(RegPara.Imagelength *0.1)),1);
RegPara.NimgFirstRegistration = min(RegPara.NimgFirstRegistration, Nbatch);
[RegPara, ds_val_threshold] = Call_initialReg(RegPara, handles, k, fext, imageinfo, Nbatch);
fprintf([figuretitlename, ' registration initialized '])
toc
% frac = k/length(handles.Datalist)*0.2;
% waitbar(frac, f_wait, sprintf('Register data %d of %d', k, length(handles.Datalist)));

%%%% registration 
[dregmode, Nbatch, savegrad] = reg_dregmode(handles, RegPara, figuretitlename, w, Nbatch); 

if isempty(RegPara.maxDispPerFrame )
    RegPara.maxDispPerFrame = ds_val_threshold;
end
ix0 = 0; 
ds_raw_all = []; CorrAll = []; 
ds_correct_all = [];
f_snr = []; f_max = 0; f_min = 0;
ds_default = [0, 0];
ds_default0 = [0, 0];
ds0 = [0, 0];
meanImg_PreReg = []; meanImg_PostReg = [];
binfileid = 1;
samplelength = 0;
samplefileid = 1;
sample_maxL =  round(4/(w.bytes/(10^9))); % limite tif size to 4GB

tic;  
dreg = [];
binLsaved = 0;
while ix0<RegPara.Imagelength
    clear mov sampledreg    
    indxr = ix0 + (1:Nbatch);   
    indxr(indxr>length(imglist)) = [];
    frac = indxr(end)/length(imglist)*0.8;
    waitbar(frac, f_wait, sprintf('Register data %d of %d', k, length(handles.Datalist)));

    f_sub = [];
    mov = zeros([size(RegPara.mimg), length(indxr)], RegPara.RawPrecision);
    for j = indxr(1):indxr(length(indxr))
        if ~isempty(fext)
            I1 = imread(handles.Datalist{k}, j);
        else
            I1 = imread(fullfile(handles.Datalist{k}, imageinfo(j).name));
        end
%         if handles.lowSNR
%             f_sub = cat(1, f_sub, quantile(single(I1(:)), 0.8));
%         end
        mov(:,:,j-ix0) = I1; 
    end
    if handles.lowSNR
        if max(mov(:)) > f_max
            f_max = max(mov(:));
        end
        if ix0 == 0
            f_min = min(mov(:));
        elseif min(mov(:)) < f_min
            f_min = min(mov(:));
        end
    end
    meanImg_PreReg = cat(3, meanImg_PreReg, mean(single(mov),3));
    [ds_raw, Corr_raw]  = registration_offsets_modified(mov, RegPara, 0);
    ds_raw_all = cat(1,ds_raw_all, ds_raw);      
    ds_correct = ds_raw;
    % smooth the ds if correlation is below the threshold
    if sum(Corr_raw <= RegPara.AlignNanThresh)>0
        ii1 = find(Corr_raw <= RegPara.AlignNanThresh);
        for ii2 = 1:length(ii1)
            if ii1(ii2) <= 3
                ds_correct(ii1(ii2), :) = ds_default;
            else                
            ix1 = max(1,ii1(ii2)-3):ii1(ii2)-1;
            ds_default = mean(ds_correct(ix1,:),1); 
            ds_correct(ii1(ii2), :) = ds_default;
            end
        end
    end
    dds = diff([ds0; ds_correct]);
    id_badframes = intersect(find(Corr_raw <= RegPara.lowCorr),...
    find( (abs(dds(:,1)) > RegPara.maxDispPerFrame(1))+(abs(dds(:,2)) > RegPara.maxDispPerFrame(2)) > 0));
    ix1 = indxr(id_badframes);
    id_badframes(ix1<=3) = [];
    if ~isempty(id_badframes)
        id_badframes
        for ii2 = 1:length(id_badframes)            
            if id_badframes(ii2) <= 3
                ds_correct(id_badframes(ii2), :) = ds_default0;
            else                
                ix1 = max(1,id_badframes(ii2)-3):id_badframes(ii2)-1;
                ds_default = mean(ds_correct(ix1,:),1); 
                ds_correct(id_badframes(ii2), :) = ds_default;
            end
        end
    end
    CorrAll = cat(1,CorrAll, Corr_raw);
    ix1 = max(1,length(indxr)-3):length(indxr);
    ds_default = mean(ds_correct(ix1,:),1); 
    ds_default0 = ds_default;
    ds_correct_all = cat(1, ds_correct_all, ds_correct); 
    ds0 = ds_correct(end,:);
    
    
    if dregmode > 0
        dregbatch = zeros([size(RegPara.mimg), length(indxr)], RegPara.RawPrecision);
        dregbatch = register_movie(mov, RegPara, ds_correct);
        % update target template
        if sum( Corr_raw >= RegPara.corrcut)>0
            ii_fortemp = find(Corr_raw >= RegPara.corrcut);
            RegPara.mimg = (RegPara.mimg*RegPara.mimgNframe +...
                sum(single(dregbatch(:,:,ii_fortemp)),3))/...
                (RegPara.mimgNframe+length(ii_fortemp));
            RegPara.mimgNframe = RegPara.mimgNframe+length(ii_fortemp);
        end
        meanImg_PostReg = cat(3, meanImg_PostReg, mean(single(dregbatch),3));
        if handles.savesubsampletif == 1
            [samplelength, samplefileid] = ...
                savesubtif(handles, dregbatch(:,:,1:savegrad:length(indxr)),...
                RegPara, samplefileid, ...
                sample_maxL, samplelength);
        end
        if  handles.savetoTif == 1
            saveDregdata(dregbatch, indxr, RegPara, handles, imageinfo, fext, k)
            RegPara.savename = RegPara.savenamebase;
        elseif  handles.savetoBin == 1
            binLsaved = binLsaved + size(dregbatch,3);
            RegPara.binfilelength(binfileid) = binLsaved;
            RegPara.savename{binfileid} = sprintf([RegPara.savenamebase,'_%03d.bin'], binfileid);
            nametmp = fullfile(handles.savepath, RegPara.savename{binfileid}); 
            fid = fopen(nametmp, 'a');
            fwrite(fid, dregbatch, RegPara.RawPrecision);
            fclose(fid);
            if binLsaved >= floor(handles.binMaxsize/(w.bytes/(10^9))) ...
                    || ix0 + Nbatch >= RegPara.Imagelength
                binLsaved = 0;
                binfileid = binfileid+1;
            end
        end
    elseif dregmode==0
        sampledreg = register_movie(mov(:,:,1:savegrad:end), RegPara, ds_correct(1:savegrad:end,:));  
        [samplelength, samplefileid] = ...
            savesubtif(handles, sampledreg, RegPara, samplefileid, ...
            sample_maxL, samplelength);       
        meanImg_PostReg = cat(3, meanImg_PostReg, mean(single(sampledreg),3));
    end        
    fprintf([figuretitlename, ' registration progressed ',...
        num2str(round(ix0/RegPara.Imagelength*100)), '%%', ' ']);
    toc
    clear dregbatch mov
    ix0 = ix0 + Nbatch;
end

RegPara.ds_raw_all = ds_raw_all;
RegPara.dsall = ds_correct_all;
RegPara.CorrAll = CorrAll;
RegPara.f_signal = f_snr;
RegPara.f_max = f_max;
RegPara.f_min = f_min;
frac = k/length(handles.Datalist)*0.8;
waitbar(frac, f_wait, sprintf('Register data %d of %d', k, length(handles.Datalist)));

meanImg_PreReg = mean(meanImg_PreReg,3);
meanImg_PreReg = meanImg_PreReg-min(meanImg_PreReg(:));
meanImg_PreReg = uint8(ceil(meanImg_PreReg/max(meanImg_PreReg(:))*255));
meanImg_PostReg = mean(meanImg_PostReg,3);
meanImg_PostReg = meanImg_PostReg-min(meanImg_PostReg(:));
meanImg_PostReg = uint8(ceil(meanImg_PostReg/max(meanImg_PostReg(:))*255));
RegPara.meanImg_PreReg = meanImg_PreReg;
RegPara.meanImg_PostReg = meanImg_PostReg;

frac = k/length(handles.Datalist);
waitbar(frac, f_wait, sprintf('Register data %d of %d', k, length(handles.Datalist)));
fprintf([figuretitlename, ' registration progressed ','100%% ']);
toc

assignin('base', 'RegPara', RegPara)
%%%%%%% show results %%%%%%%%%%%
if handles.showresult
    showregresult(RegPara, figuretitlename)    
end
    close(f_wait)
    delete(f_wait)
