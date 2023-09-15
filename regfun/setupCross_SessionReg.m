function [R_points, t_points, im_mask_reg, handles] =...
    setupCross_SessionReg(handles, im_mask, withrotation, maskdir)

%%%% im_mask_reg is a transformed version of im_mask to match
%%%% im_current
handles.roimask = [];
handles.pt = [];
handles.tempRoi = [];
handles.Temptrace = [];
handles.id = 0;
handles.roi_seed = [];
handles.roi = [];
handles.trace = [];
handles.spineROI = [];
handles.dendrite = [];
handles.dend_shaft = [];
im_current = handles.im_norm;
ops.maxIter = 150;
ops.tot = 10^-4;
ops.distTh = [2, 50];
ops.dispreg = 0;
ops.R0 = eye(3);
ops.t0 = zeros(3,1);
ops.fixed = im_mask;
ops.moving = im_current;

cc1 = 0;
cc0 = 0;
im_fix = im_mask;
im_mask_reg0 = im_mask;
iter = 1;
R_points_tot = ops.R0;
t_points_tot = ops.t0;
R_points_all = [];
t_points_all = [];
[d1,d2] = size(im_current);
[d3,d4] = size(im_mask);

[IIM, JJM, deltaI, Iabs, Imap] = pointfeature_detect2(im_current,2, 2.5, 0, 2);
data2 = [JJM, IIM];
if withrotation == 0 && d1==d3 && d2==d4
    [dv, ~, im_mask_reg] = phase_reg(im_mask, im_current);
    R_points = diag([1,1,1]);
    t_points = [-dv(2); -dv(1);0];
else
    while cc1<0.9 && iter<= 5
        im_mask = im_mask_reg0;
        [IIM, JJM, deltaI1, Iabs1, Imap1] = pointfeature_detect2(im_mask, 2, 2.5, 0, 2);
        data1 = [JJM, IIM];

        data3 = [data1';0.01*randn(1,size(data1,1))];
        data4 = [data2';0.01*randn(1,size(data2,1))];

        [R, t, iter_err, reg_pointqueary] = ICP_point_regRTbalance(data4, data3, ops);    
        R_points1 = R;
        t_points1 = t;
        R(1,2) = -R(1,2);
        R(2,1) = -R(2,1);
        R(:,3) = [0 0 1];
        R(3,:) = [t(1), t(2), 1];
        tform = affine2d(R);
        im_mask_reg1 = imwarp(im_mask,tform,'OutputView',imref2d(size(im_mask)));    
        cc1 = Im_reg_resize(im_current, im_mask_reg1);
        if cc1<0.8
            [R, t, iter_err, reg_pointqueary] = ICP_point_regRenhance(data4, data3, ops);
            R_points2 = R;
            t_points2 = t;
            R(1,2) = -R(1,2);
            R(2,1) = -R(2,1);
            R(:,3) = [0 0 1];
            R(3,:) = [t(1), t(2), 1];
            tform = affine2d(R);
            im_mask_reg2 = imwarp(im_mask,tform,'OutputView',imref2d(size(im_mask)));
            cc2 = Im_reg_resize(im_current, im_mask_reg2);
            if cc1 < cc2
                im_mask_reg = im_mask_reg2;
                R_points = R_points2;
                t_points = t_points2;
            else
                im_mask_reg = im_mask_reg1;
                R_points = R_points1;
                t_points = t_points1;
            end
        else
            im_mask_reg = im_mask_reg1;
            R_points = R_points1;
            t_points = t_points1;
        end
        cc1 = Im_reg_resize(im_current, im_mask_reg);
%         [iter, cc1]
        iter = iter + 1;
        if cc1 > cc0
            im_mask_reg0 = im_mask_reg;
            cc0 = cc1;
            R_points_all = cat(3, R_points_all, R_points);
            t_points_all = cat(2, t_points_all, t_points);
            R_points_tot = R_points_tot * R_points;
            t_points_tot = R_points*t_points_tot + t_points;
        end
    end
end

im_mask = im_fix;
h1 = figure(7); clf('reset')
if ~isempty( handles.filename)
    set(h1, 'Name', handles.filename, ...
        'Position', [50 100 handles.scrsz(3)/2 handles.scrsz(3)/4])
end
subplot(121), imshowpair(imadjust(im_mask), imadjust(im_current), 'Scaling','joint')
set(gca, 'Ydir', 'reverse')
title('Pre-registration')
subplot(122), imshowpair(imadjust(im_mask_reg), imadjust(im_current),'Scaling','joint')    
set(gca, 'Ydir', 'reverse')
title('Registered')
%%%% transform im_mask feature to match im_current features
[IIM, JJM, deltaI1, Iabs1, Imap1] = pointfeature_detect2(im_mask, 2, 2.5, 0, 2);
data1 = [JJM, IIM];
R_points = R_points_tot;
t_points = t_points_tot;

% aa = data1;
% bb = data2;
% cc = R_points*[aa'; 1*randn(1,size(aa,1))];
% cc = bsxfun(@plus, cc, t_points);
% % assignin('base', 't_points_all', t_points_all)
% % assignin('base', 'R_points_all', R_points_all)
% % assignin('base', 'data1', data1)
% % assignin('base', 'data2', data2)
% 
% subplot(133), plot(data2(:,1), data2(:,2),'.r')
% % hold on, plot(data1(:,1), data1(:,2),'.b')
% hold on, plot(cc(1,:)',cc(2,:)','og'), axis ij
im_target = im_mask;
im_target_postreg = im_mask_reg;
if ~isempty(handles.savepath)
    if exist(fullfile(handles.savepath, handles.savename), 'file')==0
        save(fullfile(handles.savepath, handles.savename), ...
            'R_points', 't_points', 'im_target', 'im_target_postreg', 'maskdir')
    else
        save(fullfile(handles.savepath, handles.savename), ...
            'R_points', 't_points', 'im_target', 'im_target_postreg', 'maskdir', '-append')
    end
end


function cc = Im_reg_resize(im_current, im_mask_reg)

[d1,d2] = size(im_current);
[d3,d4] = size(im_mask_reg);
if d1 > d3  
    im_mask_reg = cat(1, rand(d1-d3,d4)*0.01, im_mask_reg);
elseif d1<d3
    im_mask_reg(d1+1:end,:) = [];            
end
[d1,d2] = size(im_current);
[d3,d4] = size(im_mask_reg);
if d2 > d4
    im_mask_reg = cat(2, rand(d3, d2-d4)*0.01, im_mask_reg);
elseif d2<d4
    im_mask_reg(:,d2+1:end) = [];            
end
[d1,d2] = size(im_current);
[d3,d4] = size(im_mask_reg);
cc = corr(im_mask_reg(:), im_current(:));
