function [R, t, iter_err, reg_pointqueary] = ...
    ICP_point_regRTbalance(reg_points, reg_pointqueary, ops)
% This is an implementation of the Iterative Closest Point (ICP) algorithm.
% Arguments: pointcloud - 3 x n matrix of the x, y and z coordinates of data set 1
%            pointqueary - 3 x m matrix of the x, y and z coordinates of data set 2
%            res   - the tolerance distance for establishing closest point
%                     correspondences. Normally set equal to the resolution
%                     of data1
%            tri   - optional argument. obtained by tri = delaunayn(data1');
%
% Returns: R - 3 x 3 accumulative rotation matrix used to register pointqueary
%          t - 3 x 1 accumulative translation vector used to register pointqueary
%          corr - p x 3 matrix of the index no.s of the corresponding points of
%                 pointcloud and pointqueary and their corresponding Euclidean distance
%          error - the mean error between the corresponding points of pointcloud
%                  and pointqueary (normalized with res)
%          pointqueary - 3 x m matrix of the registered pointqueary 
%
% Copyright : This code is from Ajmal Saeed Mian {ajmal@csse.uwa.edu.au} by Yiyi Yu, 2021
if nargin > 2
    maxIter = ops.maxIter;
    tot = ops.tot;
    mindist = ops.distTh(1);
    maxdist = ops.distTh(2);
    dispreg = ops.dispreg;
    R = ops.R0;
    t = ops.t0;
    I1 = ops.fixed;
    I2 = ops.moving;
else
    maxIter = 100;
    tot = 10^-3;
    maxdist = 50;
    mindist = 2;
    dispreg = 1;
    R = eye(3);
    t = zeros(3,1);
end
if max(abs(t)) == 0 && R(1,1) == 1
[~, t] = icp_init_translation(reg_pointqueary, reg_points);
reg_pointqueary = bsxfun(@plus, reg_pointqueary, t);
if dispreg
    figure(1),
    clf('reset')
    hold on, plot(reg_points(1,:), reg_points(2,:), '.y')
    hold on, plot(reg_pointqueary(1,:), reg_pointqueary(2,:), '.r')
end
end
% waitforbuttonpress

%%%% initial rotation, useful for images with large rotation
tri = delaunayn(reg_points');
iter = 0;
c0 = 0;
c1 = 1;
e1 = 10^5;
e0 = e1*2;
iter_err = [];

while abs(e0-e1)>tot && iter < maxIter
    e0 = e1; 
    [idx, D] = dsearchn(reg_points', tri, reg_pointqueary');
    data_match = [idx, [1 : size(reg_pointqueary,2)]', D];    
%     distTh = mindist;
    distTh = max(quantile(data_match(:,3), 0.3), mindist);
    data_match(D>2*distTh,:) = [];
    if isempty(data_match)
        break
    end
    data_match = sortrows(data_match, [1, -3]);
    [~, ii, ~] = unique(data_match(:,1));
    if length(ii)<2
        break
    end
    data_match = data_match(ii,:);

    [R1, t1] = PointCloud_reg(reg_points(:,data_match(:,1)), reg_pointqueary(:,data_match(:,2)));
    reg_pointqueary = R1*reg_pointqueary;
    reg_pointqueary = [reg_pointqueary(1,:)+t1(1); reg_pointqueary(2,:)+t1(2); reg_pointqueary(3,:)+t1(3)];    
    R = R1*R;
    t = R1*t + t1; 

    c1 = length(ii);        
    e1 = sum(data_match(:,3))/c1;
    iter = iter + 1;
    iter_err(iter,:) = [e1, c1, distTh, asind(R1(1,2)), max(abs(t1))];
    fprintf(sprintf('Iter %d, error %0.3f \n', iter, e1));

    if dispreg
        figure(1),
        clf('reset')
        plot(reg_points(1,:), reg_points(2,:), '.b')
        hold on, plot(reg_points(1,data_match(:,1)), reg_points(2,data_match(:,1)), 'ob')
        hold on, plot(reg_pointqueary(1,:), reg_pointqueary(2,:), '.r')
        hold on, plot(reg_pointqueary(1,data_match(:,2)), reg_pointqueary(2,data_match(:,2)), 'or')
        title(sprintf('matching points %d error %0.2f', c1, e1))
        drawnow
%         waitforbuttonpress
    end
end

