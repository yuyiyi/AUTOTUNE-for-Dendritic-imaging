function [Temptrace, tempRoi] = updatesegment_threshold(handles)
mov = handles.handles;
mov2d_filt = handles.mov2d_filt;
im = handles.im;
areathreshold = 5;
th = handles.thresh;
d1 = handles.size(1);
d2 = handles.size(2);    
pt = handles.pt;
if ~isempty(pt)
    tempRoi = zeros(d1,d2);
    if pt(1)>0 && pt(2)>0 && pt(1)<d2 && pt(2)<d1
        trail = mov2d_filt(sub2ind([d1,d2],round(pt(2)),round(pt(1))),:)';
        edg1 = [max(round(pt(2))-20,1), max(round(pt(1))-20,1)]; 
        edg2 = [min(round(pt(2))+20,d1), min(round(pt(1))+20,d2)];
        nbd = im(edg1(1):edg2(1),edg1(2):edg2(2));
        [d3,d4] = size(nbd);
        rowsub = repmat([edg1(1):edg2(1)]',1,d4);
        colsub = repmat(edg1(2):edg2(2),d3,1);
        linearInd = sub2ind([d1,d2], reshape(rowsub,d3*d4,1), reshape(colsub,d3*d4,1));
        ptInd = sub2ind([d1,d2], round(pt(2)),round(pt(1)));
        pt_nbd = [round(pt(2))-edg1(1)+1,round(pt(1))-edg1(2)+1]; 
        covm = reshape(corr(double(trail), double(mov2d_filt(linearInd,:))'),d3,d4);

        % segmentation 
        bw_covm = zeros(size(covm));
        bw_result = zeros(size(covm));
        bw_covm(covm>th) = 1;
        bw_covm = bwmorph(bw_covm,'hbreak');
        bw_covm = bwmorph(bw_covm,'open');
        bw_covm = bwmorph(bw_covm,'clean');

        if sum(bw_covm(:))<=areathreshold
            bw_covm = 0;  
        else
            stats = regionprops(bw_covm, 'Area', 'Centroid','PixelIdxList');
            dd = max([d3,d4]); PixelList = [];
            for ii = 1:length(stats)
                if stats(ii).Area>areathreshold && pdist2(stats(ii).Centroid, pt_nbd)<dd
                    dd = pdist2(stats(ii).Centroid, pt_nbd);
                    PixelList = stats(ii).PixelIdxList;
                end
            end
            if ~isempty(PixelList)
                bw_result(PixelList) = 1;
            end
        end
        figure(2), subplot(1,4,1), imagesc(nbd), title('neighboring view')
        subplot(1,4,2), imagesc(covm), title('correlation map')
        subplot(1,4,3), imagesc(bw_covm), title('raw segmentation')
        subplot(1,4,4), imagesc(bw_result), title('cleaned segmentation')
        tempRoi(linearInd) = bw_result;
    end
    % plot traces
    Temptrace = [];
    if sum(tempRoi(:))>0
        [x,y] = find(tempRoi==1);
        PixelList = [y,x];
%             roi_pixel = regionprops(tempRoi, 'PixelList');
%             PixelList = roi_pixel.PixelList;
        Temptrace = reshape(mean(mean(mov(PixelList(:,2),PixelList(:,1),:))),[],1);
        axes(handles.CalciumTrace), plot(Temptrace)
        box off; 
    elseif pt(1)>0 && pt(2)>0 && pt(1)<d2 && pt(2)<d1
        axes(handles.CalciumTrace)
        plot(squeeze(mov(round(pt(2)),round(pt(1)),:)))
        box off; 
    elseif pt(1)<0 || pt(2)<0 || pt(1)>d2 || pt(2)>d1
        ax1 = handles.CalciumTrace;
        cla(ax1)
    end
end