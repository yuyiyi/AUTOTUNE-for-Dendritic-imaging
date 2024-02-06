function handles = spineROI_regmater(handles, t_points, R_points, roi_seed_master, dendID_master)
roi_seed = R_points*[roi_seed_master'; 1*randn(1,size(roi_seed_master,1))];
roi_seed = bsxfun(@plus, roi_seed, t_points);
roi_seed = roi_seed(1:2,:)';
im_norm = handles.im_norm;
d1 = handles.size(1);
d2 = handles.size(2);    

handles.id = size(roi_seed_master,1);
clear spineROI
for ii = 1:size(roi_seed_master,1)
    pt = roi_seed(ii,:);    
    if min(d2-2-pt(1), d1-2-pt(2))>0 && min(pt(1), pt(2))>=3 
    %     pt = min([pt; [size(im_norm,2)-2, size(im_norm,1)-2]]);
    %     pt = max([pt; [3, 3]]);            
        nbd = im_norm(round(pt(2))+[-2:2],round(pt(1))+[-2:2]);
        [tmp, tmp2] = max(nbd(:));
        [dx, dy] = ind2sub([5 5], tmp2);
        pt(2) = pt(2) + dx-3;
        pt(1) = pt(1) + dy-3;
        handles.pt = pt;
        tempRoi = zeros(handles.size(1:2));
        Temptrace = zeros(handles.size(3),1);
        if ~isempty(handles.pt)
            if min(round(handles.pt))<0 || round(handles.pt(1))>d2 || round(handles.pt(2))>d1
                handles.roi(:,:,ii) = tempRoi;
                handles.trace(:,ii) = nan(handles.size(3),1);
            else
                [Temptrace, tempRoi, handles] = Segmentation_autoThresh(handles, 0);
                if sum(tempRoi(:)) == 0
                    pt = handles.pt;
                    edg1 = [max(round(pt(2))-1,1), max(round(pt(1))-1,1)]; 
                    edg2 = [min(round(pt(2))+1,d1), min(round(pt(1))+1,d2)];
                    tempRoi(edg1(1):edg2(1),edg1(2):edg2(2)) = 1;
                    Temptrace = mean(handles.mov(tempRoi(:)==1,:),1)';
                end
                handles.tempRoi = tempRoi;
                handles.Temptrace = Temptrace;
            end
        end
        handles.roi(:,:,ii) = tempRoi;
        handles.trace(:,ii) = Temptrace;
        handles.roi_seed(ii,:) = handles.pt;
        spineROI(ii).roi_seed = handles.pt;
        bw = tempRoi;
        spineROI(ii).spine_pixel = find(bw==1);
        spineROI(ii).spine_trace = Temptrace;
    else
        handles.roi(:,:,ii) = zeros(d1, d2);
        handles.trace(:,ii) = zeros(handles.size(3),1);
        handles.roi_seed(ii,:) = [nan nan];        
        spineROI(ii).roi_seed = [];
        spineROI(ii).spine_pixel = [];
        spineROI(ii).spine_trace = [];
    end
    if ~isempty(dendID_master)
        spineROI(ii).dendriteID = dendID_master(ii);
    end
end

handles.spineROI = spineROI;
if exist(fullfile(handles.savepath, handles.savename), 'file')==0
    save(fullfile(handles.savepath, handles.savename), 'im_norm',  'spineROI')
else
    save(fullfile(handles.savepath, handles.savename), 'im_norm', 'spineROI', '-append')
end

