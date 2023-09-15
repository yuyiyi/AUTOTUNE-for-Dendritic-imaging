function [samplelength, fileid] = ...
    savesubtif(handles, sampledreg, RegPara, fileid, sample_maxL, samplelength)


if handles.savesubsampletif == 1
    % save reg sample            
    sampledreg = max(single(sampledreg)-RegPara.I_min, 0);
    sampledreg = uint8(min(ceil(sampledreg/(RegPara.I_max*1.5)*255),255));
    for k1 = 1:size(sampledreg,3)
        samplelength = samplelength+1;
        if samplelength>sample_maxL
            fileid = fileid+1;
            samplelength = 1;
        end
        imwrite(sampledreg(:,:,k1), fullfile(handles.savepath, ...
        sprintf([RegPara.savenamebase,'_SubSample_%03d.tif'], fileid)),...
        'writemode', 'append');
    end
end
