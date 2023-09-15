function [ops, mean_cor] = reg_iterative(data, ops)

fracImgPreAlign = getOr(ops, 'fracImgPreAlign', 1/2);
maxImgPreAlign = round(size(data,3) * fracImgPreAlign);

ops.mimg = pick_reg_init(data);

dsold = zeros(size(data,3), 2);
err = zeros(ops.NiterPrealign, 1);
%%
tempSubPixel = ops.SubPixel;
ops.SubPixel = Inf;
for i = 1:ops.NiterPrealign    
    
    [dsnew, Corr]  = registration_offsets_modified(data, ops, 1);
    dreg  = register_movie(data, ops, dsnew);
    [~, igood] = sort(Corr, 'descend');
    if i<floor(ops.NiterPrealign/2)        
        igood = igood(1:min(100,size(data,3)));  
    else
        igood = igood(1:maxImgPreAlign);  
    end
    ops.mimg = mean(dreg(:,:,igood),3);
    
    err(i) = mean(sum((dsold - dsnew).^2,2)).^.5;
        
    dsold = dsnew;
end
ops.SubPixel = tempSubPixel;
ops.AlignNanThresh = median(Corr) - 4*std(Corr);
ops.ErrorInitialAlign = err;
ops.dsprealign = dsnew;
mean_cor = mean(Corr(igood));
end 
