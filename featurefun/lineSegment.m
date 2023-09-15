function [H_abs_ROI, H_abs, theta_map, px, py] = lineSegment(im, line_width)

filter_sigma = line_width/3^0.5;
filter_size = 6*floor(line_width)+1;
% filter_size = line_width;

g_x_sigma_x_y = zeros(filter_size*2+1);
g_y_sigma_x_y = zeros(filter_size*2+1);
g_xx_sigma_x_y = zeros(filter_size*2+1);
g_xy_sigma_x_y = zeros(filter_size*2+1);
g_yy_sigma_x_y = zeros(filter_size*2+1);
for x = -filter_size:filter_size
    for y = -filter_size:filter_size
        
        g_sigma_x = 1/((2*pi)^0.5*filter_sigma)*exp(-x.^2/2/filter_sigma^2);
        g_sigma_y = 1/((2*pi)^0.5*filter_sigma)*exp(-y.^2/2/filter_sigma^2);
        g_sigma_x_1 = -x./((2*pi)^0.5*filter_sigma^3).*exp(-x.^2/2/filter_sigma^2);
        g_sigma_y_1 = -y./((2*pi)^0.5*filter_sigma^3).*exp(-y.^2/2/filter_sigma^2);
        g_sigma_x_2 = (x.^2-filter_sigma^2)./((2*pi)^0.5*filter_sigma^5).*exp(-x.^2/2/filter_sigma^2);
        g_sigma_y_2 = (y.^2-filter_sigma^2)./((2*pi)^0.5*filter_sigma^5).*exp(-y.^2/2/filter_sigma^2);
        
        g_x_sigma_x_y(x+filter_size+1, y+filter_size+1) = g_sigma_y*g_sigma_x_1;
        g_y_sigma_x_y(x+filter_size+1, y+filter_size+1) = g_sigma_y_1*g_sigma_x;
        g_xx_sigma_x_y(x+filter_size+1, y+filter_size+1) = g_sigma_y*g_sigma_x_2;
        g_xy_sigma_x_y(x+filter_size+1, y+filter_size+1) = g_sigma_y_1*g_sigma_x_1;
        g_yy_sigma_x_y(x+filter_size+1, y+filter_size+1) = g_sigma_y_2*g_sigma_x;
        
    end
end

r_x = imfilter(im,g_x_sigma_x_y,'replicate');
r_y = imfilter(im, g_y_sigma_x_y,'replicate');
r_xx = imfilter(im, g_xx_sigma_x_y,'replicate');
r_xy = imfilter(im, g_xy_sigma_x_y,'replicate');
r_yy = imfilter(im, g_yy_sigma_x_y,'replicate');

[row, col] = size(r_x);
H_abs = zeros(row, col);
H_nx = zeros(row, col);
H_ny = zeros(row, col);

lambda = zeros(row,col,2);
lambda(:,:,1) = abs((r_yy + r_xx)-sqrt((r_xx-r_yy).^2+4*r_xy.^2))/2;
lambda(:,:,2) = abs((r_yy + r_xx)+sqrt((r_xx-r_yy).^2+4*r_xy.^2))/2;
[H_abs, index] = max(lambda,[],3);
index = (index - 1.5)*2;
H_nx = 2*r_xy./((r_yy-r_xx)+index.*sqrt((r_xx-r_yy).^2+4*r_xy.^2));
H_ny = ones(size(H_nx));
H_nn = sqrt(H_nx.^2+H_ny.^2);
H_nx = H_nx./H_nn;
H_ny = H_ny./H_nn;


t = -(r_x.*H_nx+r_y.*H_ny)./(r_xx.*H_nx.^2+2*r_xy.*H_nx.*H_ny+r_yy.*H_ny.^2);

px = t.*H_ny;
py = t.*H_nx;

theta_map = atand(H_ny./(H_nx+eps));
H_abs_ROI = H_abs.*(abs(px)<=0.5).*(abs(py)<=0.5);
