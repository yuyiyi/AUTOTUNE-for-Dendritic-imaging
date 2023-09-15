function [IIM, JJM, deltaI, Iabs, Imap] = ...
    pointfeature_detect2(im, sigma, quant, plot_flag, pointmode)
% a function of particle detection. Use Delaunay triangulation to
% estimate local background intensity and t-test to determine true particles.
% Inputs: 
% im: an image, 
% rect: an region contains no particles. Used to estimate variance of background noisy.
% sigma: level of gaussian smoothing on the raw image
% quant: quantile for t-test to select particles
% plot_flag: 1 for plotting results
% developed by Yiyi Yu, Hao-Chih Lee, 2021

if nargin == 3
    plot_flag = 0;
    pointmode = 1;
elseif nargin == 4
    pointmode = 1;
end

bw = im2bw(im, 0.1);
tmp = im .* (1-bw);
I0 = mean(tmp(:));
sDN = std(tmp(:));                  % dark noise;  sqrt(alpha) in eq(2)
sP = 0;                             % Poisson noise


% bgpixel = im(im<quantile(im(:), 0.3));
% I0 = mean(bgpixel(:));
% sDN = std(bgpixel(:));              % dark noise;  sqrt(alpha) in eq(2)
% sP = 0;                             % Poisson noise


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
