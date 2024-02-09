function [IIM, JJM, deltaI, Iabs, Imap] = ...
    Auto_points(handles, rect, sigma, quant, plot_flag, pointmode, ifbg)
% a function of particle detection. Use Delaunay triangulation to
% estimate local background intensity and t-test to determine true particles.
% Inputs: 
% im: an image, 
% rect: an region contains no particles. Used to estimate variance of background noisy.
% sigma: level of gaussian smoothing on the raw image
% quant: quantile for t-test to select particles
% plot_flag: 1 for plotting results
% developed by Yiyi Yu, Hao-Chih Lee, 2021
im = handles.im_norm;
if nargin == 4
    plot_flag = 0;
    pointmode = 1;
    ifbg = 1;
end
if ifbg == 1
    scrsz = handles.scrsz;
    pos_default = round([scrsz(3)/6 20 scrsz(3)/3*2 scrsz(4)-100]);    
    if isempty(findobj('type','figure','number',20))
        pos = pos_default;    
    else
        h1_handles = get(figure(20));
        pos = h1_handles.Position;
    end
    h1 = figure(20);
    clf('reset')
    set(h1,'Name', 'Select a background region','Position',pos);
    [bgpixel] = imcrop(im,rect);
    title('Select background region')
else
    bgpixel = im(im<quantile(im(:), handles.defaultPara.autofeature_bg));
end
I0 = mean(bgpixel(:));
sDN = std(bgpixel(:));                  % dark noise;  sqrt(alpha) in eq(2)
sP = 0;                             % Poisson noise

Gim = imfilter(im,fspecial('gaussian',6*ceil(sigma)+1,sigma),'replicate');

mask = reshape(eye(9),3,3,[]);
im_max = max(Gim(:));
im_rep_max = repmat(Gim,[1 1 9]);
im_rev = im_max-Gim;
for ii = 1:9
    im_rep_max(:,:, ii) =  imfilter(im_rev, mask(:,:,ii));
end

[temp, ind_max]= min(im_rep_max,[],3);
ImgMax = ind_max == 5;

sigma_fit = 2; % guassian fitting parameter
width = sigma_fit*6+1;
[xx, yy] = meshgrid(-width:width,-width:width);
T = exp(-(xx.^2+yy.^2)/2/sigma_fit^2);
T = T/max(T(:));
IT = sum(T(:));
N =numel(xx);
IM = imfilter(im,ones(size(xx,1),size(xx,1)),'replicate');
TM = imfilter(im,T,'replicate');
deltaI = (-IT*IM+N*TM)/(N*sum(T(:).^2)-IT^2);

if pointmode == 1
    % detect points at local maxima
    Imap = (ImgMax & deltaI>quant*sDN);
elseif pointmode == 2 
    % detect all significant points
    Imap = deltaI>quant*sDN;
end

[IIM, JJM] = find(Imap);
deltaI = deltaI(Imap);
Iabs = im(Imap);

if plot_flag ==1
    address = [IIM, JJM];
    figure, imshow(im,[]), hold on, plot(address(:,2), address(:,1),'*g')
end
