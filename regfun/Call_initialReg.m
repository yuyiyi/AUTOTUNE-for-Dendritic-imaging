function [RegPara, ds_val_threshold] = Call_initialReg(RegPara, handles, k, fext, imageinfo, Nbatch)

RegPara.Corr_initial = 0;
if RegPara.NimgFirstRegistration >= 20
    ini_iter = 1; Corr_initial = 0;
    t0 = ceil(RegPara.Imagelength(1)*0.1);
    while Corr_initial < 0.2 && ini_iter <= 5
        I = []; 
        for i = (1:RegPara.NimgFirstRegistration)+(ini_iter-1)*RegPara.NimgFirstRegistration
            t1 = i + t0; % always skip the initial part of the movie
            if RegPara.MultiStackReg == 0
                if ~isempty(fext)
                    I1 = single(imread(handles.Datalist{k}, t1));
                else
                    I1 = single(imread(fullfile(handles.Datalist{k}, imageinfo(t1).name)));
                end
            else
                I1 = single(imread(fullfile(imageinfo(1).folder, imageinfo(1).name), t1));
            end
            I = cat(3, I, I1); 
        end
        RegPara.I_min = min(single(RegPara.I_min), min(single(I(:))));
        RegPara.I_max = max(single(RegPara.I_max), max(single(I(:))));
        [RegPara_tmp, Corr_initial] = reg_iterative(I, RegPara);
        if Corr_initial > RegPara.Corr_initial
            RegPara.AlignNanThresh = RegPara_tmp.AlignNanThresh;
            RegPara.ErrorInitialAlign = RegPara_tmp.ErrorInitialAlign;
            RegPara.dsprealign = RegPara_tmp.dsprealign;
            RegPara.Corr_initial = Corr_initial;
            RegPara.mimg = RegPara_tmp.mimg;
            d = sqrt(sum(RegPara.dsprealign.^2,2));
            ds_val_threshold = mean(d) + 3.5*std(d);
        end
        ini_iter = ini_iter+1;
    end
    RegPara.ini_iter = ini_iter;
elseif RegPara.NimgFirstRegistration < 20
    I = []; f_snr = []; 
    for i = 1:min(RegPara.NimgFirstRegistration*3, Nbatch)
            if RegPara.MultiStackReg == 0
                if ~isempty(fext)
                    I1 = single(imread(handles.Datalist{k}, i));
                else
                    I1 = single(imread(fullfile(handles.Datalist{k}, imageinfo(i).name)));
                end
            else
                I1 = single(imread(fullfile(imageinfo(1).folder, imageinfo(1).name), i));
            end
        f_snr = cat(1, f_snr, quantile(I1(:), 0.8));
        I = cat(3, I, I1);            
    end
        RegPara.I_min = min(single(RegPara.I_min), min(single(I(:))));
        RegPara.I_max = max(single(RegPara.I_max), max(single(I(:))));

    [~, idsel] = max(f_snr);
    if RegPara.NimgFirstRegistration >=3
        ix0 = max(idsel-RegPara.NimgFirstRegistration , 1);
        ix1 = min(idsel+RegPara.NimgFirstRegistration , RegPara.Imagelength(1));
        data = I(:,:,ix0:ix1);  
        [RegPara, Corr_initial] = reg_iterative(data, RegPara); 
        RegPara.Corr_initial = Corr_initial;
        d = sqrt(sum(RegPara.dsprealign.^2,2));
        ds_val_threshold = mean(d) + 3.5*std(d);
    elseif RegPara.NimgFirstRegistration <3
        data = I(:,:,idsel);
        RegPara.mimg = data;
        ds_val_threshold = 10;
    end
end

fprintf(['ds_val_threshold ', num2str(ds_val_threshold)])
fprintf(['Corr_initial ', num2str(Corr_initial), '\n'])
