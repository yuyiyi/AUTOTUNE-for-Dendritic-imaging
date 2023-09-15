function movF = MovGaussFilter_v2(mov, G, subsample, workingclass, useGPU, handles)
movF = zeros([size(mov, 1), size(mov, 2), length(1:subsample:size(mov,3))], workingclass);
k = 1;
if useGPU
    gpudev = gpuDevice(1);
    reset(gpudev)
    Mem_max = gpudev.AvailableMemory;
    batchsize = min(floor(Mem_max*0.8/handles.bytesPerImage), 20);
    G = gpuArray(G);
    proclist = 1:subsample:size(mov,3);
    x0 = 0; 
    movF = [];
    while x0<length(proclist)
        xi = x0 + [1:batchsize];
        xi(xi>length(proclist)) = [];        
        x0 = xi(end);
        f = proclist(xi);
        tmp = imfilter(gpuArray(mov(:,:,f)),G,'same');
        movF = cat(3, movF, gather(tmp));
        k = k+1;
    end 
else
    for f=1:subsample:size(mov,3)
        movF(:,:,k) = imfilter(mov(:,:,f),G,'same');
        k = k+1;
    end 
end
