function [Temptrace_batch, tempRoi_batch, trace_cor, handles] = SegmentationBatch_autoThresh(handles, disppara)
if nargin<2
    disppara=1;
end
scrsz = get(groot,'ScreenSize');
pos_seg = round([scrsz(3)*0.1 scrsz(4)*0.55 scrsz(3)*0.4 scrsz(4)/3]);
mov = handles.mov;
mov2d_filt = handles.mov2d_filt;
%%%%%% setup parameters
areathreshold = handles.defaultPara.minarea;
th_grad = handles.defaultPara.th_grad;
linewidth = handles.linewidth;
w = linewidth*handles.defaultPara.w;
MaxAR = handles.defaultPara.MaxAR;
maxareagrad = handles.defaultPara.maxareagrad;
maxarea = maxareagrad * linewidth;

d1 = handles.size(1);
d2 = handles.size(2);    
ptbatch = handles.pt;
im = handles.im_norm;
roimask = ones(size(im)) - handles.roimask;
if ~isempty(handles.roi)
    roimask = roimask-sum(handles.roi,3);
end
ptbatchInd = sub2ind([d1,d2], round(ptbatch(:,2)),round(ptbatch(:,1)));
ptbatch(roimask(ptbatchInd)==0,:) = [];
dendtrace = []; p_in_id = [];
if ~isempty(handles.dendrite)
    for k = 1:length(handles.dendrite)
        cspoints = handles.dendrite(k).dend_line;
        [~, kymo_cordinate] = line_expand(cspoints', linewidth*3, 20);
        polydot = kymo_cordinate';
        intr_outline = [polydot(:,1:2); flip(polydot(:,end-1:end),1);polydot(1,1:2)];
        in_region = inpolygon(ptbatch(:,1), ptbatch(:,2), intr_outline(:,1), intr_outline(:,2));
        dend_outline = handles.dendrite(k).dend_outline;
        in_dendr = inpolygon(ptbatch(:,1), ptbatch(:,2), dend_outline(:,1), dend_outline(:,2));
        p_in_id = cat(1, p_in_id, find(in_region==1 & in_dendr==0));        
        dendtrace(:,k) = handles.dendrite.trace;
    end
    ptbatch = ptbatch(unique(p_in_id), :);
end
tempRoi_batch = [];
Temptrace_batch = [];
trace_cor = [];
if ~isempty(ptbatch)
    for k = 1:size(ptbatch, 1)
        pt = ptbatch(k,:);
        tempRoi = zeros(d1,d2);
        if pt(1)>0 && pt(2)>0 && pt(1)<d2 && pt(2)<d1
            ptInd = sub2ind([d1,d2], round(pt(2)),round(pt(1)));
            trail = mov2d_filt(ptInd,:)';
            edg1 = [max(round(pt(2))-w,1), max(round(pt(1))-w,1)]; 
            edg2 = [min(round(pt(2))+w,d1), min(round(pt(1))+w,d2)];
            nbd = im(edg1(1):edg2(1),edg1(2):edg2(2));
            nbd_mask = roimask(edg1(1):edg2(1),edg1(2):edg2(2));
            [d3,d4] = size(nbd);
            rowsub = repmat([edg1(1):edg2(1)]',1,d4);
            colsub = repmat(edg1(2):edg2(2),d3,1);
            linearInd = sub2ind([d1,d2], reshape(rowsub,d3*d4,1), reshape(colsub,d3*d4,1));
            pt_nbd = [round(pt(2))-edg1(1)+1,round(pt(1))-edg1(2)+1]; 
            %%%% initial autosegment
            cov_nbd = corr(double(trail), double(mov2d_filt(linearInd,:))');
    %         assignin('base', 'cov_nbd', cov_nbd)
            % segmentation 
            th_80 = quantile(cov_nbd(:), 0.8);
            th_max = max(cov_nbd(:));
            th_min = quantile(cov_nbd(:), 0.01);
            th = max(th_80, (th_max-th_min)/th_grad+th_min);
            tmpInd = linearInd(cov_nbd>=th);
            trail = mean(mov2d_filt(tmpInd,:),1)';
            %%%% polish auto segmentation
            cov_nbd = reshape(corr(double(trail), double(mov2d_filt(linearInd,:))'),d3,d4);
    %         assignin('base', 'cov_nbd', cov_nbd)
            % segmentation 
            bw_covm = zeros(size(cov_nbd));
            bw_result = zeros(size(cov_nbd));
            th_80 = quantile(cov_nbd(:), 0.8);
            th_max = max(cov_nbd(:));
            th_min = quantile(cov_nbd(:), 0.01);
            th = max(th_80, (th_max-th_min)/th_grad+th_min);
            bw_covm(cov_nbd>th) = 1;
            bw_covm = bwmorph(bw_covm,'hbreak');
            bw_covm = bwmorph(bw_covm,'open');
            bw_covm = bwmorph(bw_covm,'clean');
    %         bw_covm = bwmorph(bw_covm, 'majority');
            % remove pixels inside a dendrite
            bw_covm = bw_covm.*nbd_mask;       

            
            if sum(bw_covm(:))<=areathreshold
                bw_covm = 0; 
%                 fprintf('No spine found, please avoid clicking a point inside dendritic ROI \n')
            else            
                stats = regionprops(bwlabel(bw_covm), 'Area', 'Centroid',...
                    'PixelIdxList', 'MajorAxisLength', 'MinorAxisLength');
                dd = max([d3,d4]); PixelList = []; at = 1; cent = [];
                for ii = 1:length(stats)
                    if stats(ii).Area>areathreshold && pdist2(stats(ii).Centroid, pt_nbd)<dd
                        dd = pdist2(stats(ii).Centroid, pt_nbd);
                        PixelList = stats(ii).PixelIdxList;
                        ar = stats(ii).MajorAxisLength/stats(ii).MinorAxisLength;
                        cent = stats(ii).Centroid + [edg1(2), edg1(1)];
%                         cent_linearInd = sub2ind([d1,d2], round(cent(2)), round(cent(1)));
                    end
                end
                if ~isempty(PixelList) && dd < 2
                    bw_result(PixelList) = 1;
                end
            end
            if disppara==1
                if isempty(findobj('type','figure','number',4))
                    pos = pos_seg;    
                else
                    h1_handles = get(figure(4));
                    pos = h1_handles.Position;
                end
                h1 = figure(4);
                set(h1,'Name', 'Spine segmentation','Position', pos);
                subplot(2,4,1), imagesc(nbd), title('neighbor view')
                subplot(2,4,2), imagesc(cov_nbd), title('correlation map')
                subplot(2,4,3), imagesc(bw_covm), title('raw segment')
                subplot(2,4,4), imagesc(bw_result), title('cleaned segment')
                drawnow
            end
            tempRoi(linearInd) = bw_result;
        end
        % plot traces
        Temptrace = zeros(handles.size(3),1);
%         if sum(tempRoi(:))>sum(handles.linewidth.^2)/2 && ar < 4
        if sum(tempRoi(:))>maxarea && ar < MaxAR
            tmp = mov(tempRoi(:)==1,:);
            Temptrace = mean(double(tmp), 1)';
            roimask = roimask-tempRoi;
            cc = corr(double(tmp'), double(Temptrace));
            trace_cor = cat(1, trace_cor, mean(cc));            
            Temptrace_batch = cat(2, Temptrace_batch, Temptrace);
            tempRoi_batch = cat(3, tempRoi_batch, tempRoi);
            handles.id = handles.id+1;
            handles.roi_seed(handles.id,:) = cent;
            handles.roi(:,:,handles.id) = tempRoi;
            handles.trace(:,handles.id) = Temptrace;
        end
        if disppara==1
            if isempty(findobj('type','figure','number',4))
                pos = pos_seg;    
            else
                h1_handles = get(figure(4));
                pos = h1_handles.Position;
            end
            h1 = figure(4); subplot(2,4,5:8), plot(Temptrace)
        end
    end
end
