function para_default = defaultparameter

%%%%%% movie denoise for feature detection
para_default.GaussKernel = [4, 4, 2]; % movie denoise kernel
para_default.maxLength = 4000; % default dendritic width (pixel)

%%%%%% parameter to feature detection
para_default.linewidth = 6; % default dendritic width (pixel)
para_default.th_grad = 2; % feature segmentation at 1/th_grad of the correlation map
para_default.w = 3; % feature search neightborhood = w*linewidth

%%%%%% parameter to auto feature detection
para_default.minarea = 5; % minimal feature area (pixel)
para_default.maxareagrad = 4; % max feature area (pixel) = linewidth*maxareagrad 
para_default.MaxAR = 4; % max feature aspect ratio
para_default.autofeature = [2, 3.5]; % parameter for autofeature detection
para_default.shaftlength = 60; % default shaft length (pixel)

%%%%%% cross-session alignment
para_default.ops.withrotation = 1; % alignment with rotation 0/1
para_default.ops.maxIter = 150; % max iteration
para_default.ops.tot = 10^-4; % max tolerance
para_default.ops.distTh = [2, 50]; % [min max] distance threshold
para_default.ops.dispreg = 0; % display 
para_default.ops.pointsdetection = [2, 2.5, 2]; % point cloud detection parameters 

%%%%%% motion correction 
para_default.RegPara.PhaseCorrelation  = 1; % set to 0 for non-whitened cross-correlation
para_default.RegPara.SubPixel = Inf; % 2 is alignment by 0.5 pixel, Inf is the exact number from phase correlation
para_default.RegPara.NiterPrealign = 20; % Number of iteration for initial registrition 