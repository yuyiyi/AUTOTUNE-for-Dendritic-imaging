function para_default = defaultparameter
% ------------------ edit with caution ---------------------------------
%% movie denoise for feature detection (Don't change these parameters unless you are confident)
para_default.GaussKernel = [4, 4, 2];   % movie denoise kernel (kernel size, kernel size,  kernel SD)
para_default.maxLength = 4000;          % default dendritic width (pixel)

%% parameter to feature segmentation
para_default.linewidth = 6;             % default dendritic width (pixel) (popup variable in GUI)
para_default.th_grad = 2;               % feature segmentation at 1/th_grad of the correlation map
                                        % increase this value would generate larger segmentation,
                                        % change range > 1                                       
para_default.w = 3;                     % feature segmentation neighborhood = w*linewidth
                                        % increase the value, correlation map would be computed from a larger neighborhood
                                        
%% parameter to auto feature detection
para_default.minarea = 5;               % minimal allowed feature size (pixel)
para_default.maxareagrad = 4;           % maximal allowed feature area (pixel) = linewidth*maxareagrad 
para_default.MaxAR = 4;                 % maximal allowed feature aspect ratio
para_default.autofeature = [2, 3.5];    % parameter for autofeature detection (don't change unless you are confident)
para_default.autofeature_bg = 0.3;      % background thresholding parameter 
                                        % below this fraction of intensity
                                        % pixel will be counted as
                                        % background if not manually
                                        % selecting background
                                        
para_default.ifbg = 0;                  % if manually select background for auto detection 
                                        % set to 1, a window would pupup
                                        % allow users to select a background
                                        % area during autofeature detection. Facilitate
                                        % autodetection 
                                        
para_default.shaftlength = 60;          % default shaft length in pixel (popup variable in GUI)
para_default.spinedist = 3;             % distance from dendrites for autodetection 
                                        % spine search: spinedist * linewidth

%% cross-session alignment (Don't change these parameters unless you are confident)
para_default.ops.withrotation = 1;      % alignment with rotation 0(without)/1(with)
para_default.ops.maxIter = 150;         % max iteration
para_default.ops.tot = 10^-4;           % max tolerance
para_default.ops.distTh = [2, 50];      % [min max] distance threshold
para_default.ops.dispreg = 0;           % display 
para_default.ops.pointsdetection = [2, 2.5, 2]; % point cloud detection parameters 

%% motion correction (Don't change these parameters unless you are confident)
para_default.RegPara.PhaseCorrelation  = 1;     % set to 0 for non-whitened cross-correlation
para_default.RegPara.SubPixel = Inf;            % 2 is alignment by 0.5 pixel, Inf is the exact number from phase correlation
para_default.RegPara.maxDispPerFrame  = [];     % maximal displacement per frame. recommend [20, 20]; 
                                                % If empty, values set by 3.5*SD of displacement at initial alignment
                                                % Smaller value is not recommended 
                                                
para_default.RegPara.lowCorr = 0.1;             % minimal registered-to-target correlation. Larger value is not recommended

% initialize motion correction 
para_default.RegPara.NiterPrealign = 20;        % Number of iteration for initial registrition 
para_default.RegPara.iniSearchiter = 5;         % Max iteration for chunk searching for initial registrition. 
para_default.RegPara.FrameNoiniAlign  = 100;    % Number of frames for initial alignment.
                                                % This value would be bounded by system memory
                                                % and video length in processing                             
para_default.RegPara.MinCorr_initial = 0.2;     % chunk search continue when initial registrition correlation below this value

%% denoise trace (Input Mapping and Spine Turnover module)
para_default.Denoise.movingaverage = 5;         % moving average window size
para_default.Denoise.gaussfilt = [10, 0.3, 20]; % gaussian filtering [fps, signal filter kernel, baseline filter kernel]
para_default.spineRetain = 10;                   % threshold for mapping cross-session spines
