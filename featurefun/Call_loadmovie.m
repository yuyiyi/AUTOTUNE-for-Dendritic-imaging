function handles = Call_loadmovie(loadmovieflag, I1, Mem_max, w, f_wait, handles)
tic
if loadmovieflag
    imageinfo = handles.imageinfo;
    grad = handles.movieinputgrad;
    fext = handles.fext;
    mov = zeros([size(I1), length(1:grad:length(imageinfo))], handles.WorkingPrecision);
    j1 = 1;
    for j = 1:grad:length(imageinfo)
        if ~isempty(fext)
            I1 = imread(fullfile(handles.filepath, handles.filename), j);
        else
            I1 = imread(fullfile(handles.filepath, handles.filename, imageinfo(j).name));
        end
        mov(:,:,j1) = I1;
        j1 = j1+1;
        waitbar(j/length(imageinfo), f_wait);
    end
    [d1,d2,T] = size(mov);
    handles.size = [d1, d2, T];
    maxL = min(floor((Mem_max-w.bytes*T)/w.bytes), 4000);
    G = fspecial('gaussian',[4 4], 2);
    subsample = max(ceil(T/maxL),1);
    movF = MovGaussFilter_v2(mov, G, subsample, handles.WorkingPrecision, handles.useGPU, handles);
%     assignin('base', 'movF', movF)
    mov2d_filt = reshape(movF,d1*d2,size(movF,3));
    im = mean(single(mov),3);
    handles.im = im;
    im_norm = im;
    im_norm = im_norm-quantile(im_norm(:), 0.02);
    im_norm(im_norm<0) = 0;
    im_norm = im_norm/max(im_norm(:));
    handles.im_norm = im_norm;
    handles.roimask = zeros(size(im_norm));
%     assignin('base', 'movF', movF);
    handles.mov2d_filt = mov2d_filt;
    handles.mov = reshape(mov, [], size(mov,3));
end
toc
    close(f_wait)
    delete(f_wait)

