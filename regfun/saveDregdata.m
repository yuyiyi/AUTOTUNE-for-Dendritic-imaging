function saveDregdata(dreg, indxr, RegPara, handles, imageinfo, fext, k, indxr_base)
savename = RegPara.savenamebase;
if handles.crossSessionReg == 0
    for k1 = 1:size(dreg,3)
        nametmp = sprintf(['%0', num2str(floor(log10(RegPara.Imagelength))+1),'d.tif'], indxr(k1)); 
        if ~isempty(fext)
            imwrite2tif(dreg(:,:,k1), imageinfo(indxr(k1)),  ...
                fullfile(handles.savepath, savename, nametmp), RegPara.RawPrecision)
        else
%             fullfile(handles.Datalist{k}, imageinfo(indxr(k1)).name)
            imageinfo_tmp = imfinfo(fullfile(handles.Datalist{k}, imageinfo(indxr(k1)).name));
            imwrite2tif(dreg(:,:,k1), imageinfo_tmp,  ...
                fullfile(handles.savepath, savename, nametmp), RegPara.RawPrecision)
        end
    end
else
    for k1 = 1:size(dreg,3)
        nametmp = sprintf(['%0', num2str(floor(log10(sum(RegPara.Imagelength)))+1),'d.tif'], indxr(k1)+indxr_base); 
        imwrite2tif(dreg(:,:,k1), imageinfo(indxr(k1)),  ...
            fullfile(handles.savepath, savename, nametmp), RegPara.RawPrecision)
    end
end