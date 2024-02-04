function [spine_evolve, num_turnover, Dendrite_CrossSess, filelist, targetdata] = spineEvolveAna(handles)

% funcsel = prepCrossSessReg(handles);
%     rb1 = 'Register to the last dataset';
%     rb2 = 'Register to dataset 1';     
%     rb3 = 'Use existing transform matrix'; 
spine_evolve = [];
num_turnover = [];

% setup cross-session comparison target
[thresh, targetID] = prep_TurnOverAna(handles);
if isempty(thresh) || isempty(targetID)
    return
end

datalist = setdiff(1:length(handles.datafilename), targetID);

handles = loadtrace(handles, targetID);
im_mask = handles.im_norm;
roi_seed_master = handles.roi_seed;
spineID_mask = handles.spine_title;
dend_roi_mask = [];
dend_line_mask = [];
dendidmask = [];
if ~isempty(handles.dendrite)
    dend_roi_mask = handles.dend_rois;
    dend_line_mask = handles.dend_line_all;
    dendidmask = handles.dend_title; 
end

handles.savepath = handles.datafilepath;
withrotation = 1;
num_turnover = [];
hplot = figure(25); clf('reset')
scrsz = handles.scrsz;
if (length(handles.datafilename)+1)>5
    set(hplot,'Name', 'Spine evolution', ...
    'Position', [100 500 handles.scrsz(3)/2 handles.scrsz(4)/4])
    c1 = ceil((length(handles.datafilename)+1)/5);
    c2 = 5;
else
    set(hplot,'Name', 'Spine evolution', ...
    'Position', [100 500 handles.scrsz(3)/2 handles.scrsz(4)/2])
    c2 = (length(handles.datafilename)+1);
    c1 = 1;
end
subplot(c1,c2,1), 
imshow(im_mask, [])
hold on, plot(roi_seed_master(:,1), roi_seed_master(:,2), '+b')
set(gca, 'Ydir', 'reverse')
title(sprintf('registration target: dataset %d', targetID))

overlap_totarget = [];
Dendrite_CrossSess = [];
targetdata = handles.datanames{targetID};
filelist{1,1} = fullfile(handles.datafilepath, handles.datafilename(targetID));

for i2 = 1:length(datalist) %2:length(handles.datafilename)    
    i1 = datalist(i2);        
    k1 = 1+i2;
    handles = loadtrace(handles, i1);
    handles.savename = handles.datafilename{i1};
    handles.filename = handles.datafilename{i1};
    filelist{k1,1} = fullfile(handles.datafilepath, handles.datafilename(i1));
    
    im_norm = handles.im_norm;
    [d1, d2] = size(im_norm);
    roi_current = handles.roi_seed;
    spineID_current = handles.spine_title;
    if isempty(roi_current) || isempty(im_norm)
        num_turnover = cat(1, num_turnover, [length(spineID_mask), 0, length(spineID_current)]);
        if i2 == 1
            overlap_totarget = [spineID_mask, zeros(length(spineID_mask),1)];
        else
            overlap_totarget(1:length(spineID_mask), k1) = 0;
            overlap_totarget(length(spineID_mask)+1:length(spineID_current), k1) = spineID_current;
        end 
        continue
    end
    
    R_points = []; t_points = [];
    f_wait = waitbar(0.2,'Feature Registration');
    [R_points, t_points, im_mask_reg, handles]...
        = setupCross_SessionReg(handles, im_mask, withrotation, '');
    waitbar(0.5, f_wait,'Feature Registration');

    if ~isempty(roi_seed_master) && ~isempty(R_points)
        if ~isempty(handles.dendrite) && ~isempty(dendidmask)
            dend_roi_current = handles.dend_rois;
            dend_line_current = handles.dend_line_all;
            dendidcurrent = handles.dend_title;
            dend_line_translate = R_points*[dend_line_mask(:,1:2)'; 1*randn(1,size(dend_line_mask(:,1:2),1))];
            dend_line_translate = bsxfun(@plus, dend_line_translate, t_points);
            dend_line_translate = round(dend_line_translate(1:2,:)');
            dend_line_translate(:,3) = dend_line_mask(:,3); % mask dendrite id
            dendpixelidx = sub2ind(size(im_norm), dend_line_translate(:,2), dend_line_translate(:,1));
            [c, itmp] = unique(dendpixelidx);
            dend_line_translate = dend_line_translate(itmp,:);
            dendpixelidx = dendpixelidx(itmp,:);
            dendlength1 = groupcounts(dend_line_translate(:,3));
            iiout = [find(min(dend_line_translate(:,1:2))<=0); find(dend_line_translate(:,1)>d2); find(dend_line_translate(:,2)>d1)];
            dend_line_translate(iiout,:) = [];
            dendpixelidx(iiout) = [];
            dendidtmp = dend_roi_current(dendpixelidx); % current dendrite id            
            % generate confusion matrix h [current id, mask id] translate
            % mask to match current
            dendorder = unique([dendidcurrent; dendidmask]);
            dendlength = zeros(length(dendorder),1)+eps;
            dendlength(ismember(dendidmask, dendorder)) = dendlength1;
            [h, dorder] = confusionmat(dendidtmp(dendidtmp~=0), dend_line_translate(dendidtmp~=0,3),'Order', dendorder);
            [matchv, matchid] = max(h); % matched dend in the current dataset
            
            dendoverlaptmp = [dorder, dorder(matchid)];
            dendoverlaptmp(matchv./dendlength'<0.2,2) = 0;
            dendoverlaptmp(~ismember(dendoverlaptmp(:,1), dendidmask), :) = [];
            dendoverlaptmp = sortrows(dendoverlaptmp, 1);
            if ~isempty(setdiff(dendidcurrent, dendoverlaptmp(:,2)))
                tmp = setdiff(dendidcurrent, dendoverlaptmp(:,2));
                dendoverlaptmp = cat(1, dendoverlaptmp, [zeros(length(tmp),1), tmp]);
            end
            if i2 == 1
                Dendrite_CrossSess = dendoverlaptmp;
            else
                Dendrite_CrossSess(1:size(dendoverlaptmp,1), k1) = dendoverlaptmp(:,2);
            end
        end
        roi_seed = R_points*[roi_seed_master'; 1*randn(1,size(roi_seed_master,1))];
        roi_seed = bsxfun(@plus, roi_seed, t_points);
        roi_seed = roi_seed(1:2,:)';
        dd = pdist2(roi_seed, roi_current);
        [v,idx] = min(dd,[],2);
        
        % spine retained
        ia = []; ib = [];
        ia1 = find(v<thresh);  % id in the target dataset      
        if ~isempty(ia1)
            ib1 = idx(ia1); % id in the current dataset
            tmpretain = [ia1, ib1, v(ia1)];
            [tmp, iitmp] = sortrows(tmpretain, [1,3]);
            idout = find(diff(tmp(:,1))==0);
            if ~isempty(idout)
                tmpretain(idout+1,:) = [];
            end
            [tmp, iitmp] = sortrows(tmpretain, [2,3]);
            idout = find(diff(tmp(:,2))==0);
            if ~isempty(idout)
                tmpretain(idout+1,:) = [];
            end
            if ~isempty(tmpretain)
                ia = tmpretain(:,1); % id in the target dataset  
                ib = tmpretain(:,2);  % id in the current dataset
            end
        end
        % lost
        if ~isempty(ia)
            ia_miss = setdiff(1:size(roi_seed,1), ia);
        else
            ia_miss = 1:size(roi_seed,1);
        end
        % gain
        if ~isempty(ib) 
            ib_miss = setdiff(1:size(roi_current,1), ib);
        else
            ib_miss = 1:size(roi_current,1);
        end    
        
        figure(25), subplot(c1,c2,i2+1)
        imshow(im_norm, [])
%         set(gca, 'Ydir', 'reverse')
%         hold on, plot(roi_seed(ia,1), roi_seed(ia,2), 'or') 
        % retain
        if ~isempty(ib)
        hold on, plot(roi_current(ib,1), roi_current(ib,2), '+b')
        else
        hold on, plot(nan,nan, '+b')
        end  
        % lost
        if ~isempty(ia_miss)
        hold on, plot(roi_seed(ia_miss,1), roi_seed(ia_miss,2), 'og')
        else
        hold on, plot(nan,nan, 'og')
        end
        % gain
        if ~isempty(ib_miss)
        hold on, plot(roi_current(ib_miss,1), roi_current(ib_miss,2), 'or')
        else
        hold on, plot(nan, nan, 'or')            
        end
        title(handles.datafilename{i1})
        title(sprintf('Dataset %d', i1))

        % generate overlapping table
        overlaptmp = [];
        overlaptmp = [spineID_mask(ia), spineID_current(ib)];
        if ~isempty(ia_miss)
            overlaptmp = cat(1, overlaptmp, [spineID_mask(ia_miss), zeros(length(ia_miss),1)]);
        end
        overlaptmp = sortrows(overlaptmp, 1);
        
        if i2 == 1
            overlap_totarget = overlaptmp;
        else
            overlap_totarget(1:size(overlaptmp,1), k1) = overlaptmp(:,2);
        end
        if ~isempty(ib_miss)
            overlaptmp_gain = [zeros(length(ib_miss),1), spineID_current(ib_miss)];
            if i2 == 1
                overlap_totarget = cat(1, overlap_totarget, overlaptmp_gain);
            else
                overlap_totarget(size(overlaptmp,1)+[1:length(ib_miss)], k1) = overlaptmp_gain(:,2);
            end
        end 
        
%         spine_evolve(i1).match = [spineID_mask(ia), spineID_current(ib)];        
%         spine_evolve(i1).new = spineID_current(ib_miss);
%         spine_evolve(i1).turnover = spineID_mask(ia_miss);
        
        num_turnover = cat(1, num_turnover, [length(ia_miss), length(ia), length(ib_miss)]);
    end
end
figure(25), subplot(c1,c2,i2+1),
legend('retained', 'lost', 'gained')


figure(25)
if size(num_turnover,1)>2
    subplot(c1,c2,length(handles.datafilename)+1), 
    barwitherr(std(num_turnover,[],1)/sqrt(size(num_turnover,1)),mean(num_turnover,1))
    box off, set(gca,'XTickLabel',{'turnover', 'no change', 'new'})
    ylabel('Number of spines')
else
    subplot(c1,c2,length(handles.datafilename)+1),
    bar(mean(num_turnover,1))
    box off, set(gca,'XTickLabel',{'turnover', 'no change', 'new'})
    ylabel('Number of spines')
end

num_turnover = array2table(num_turnover);
num_turnover.Properties.VariableNames = {'lost', 'retain', 'gain'};
overlap_totarget(overlap_totarget==0) = nan;
spine_evolve = array2table(overlap_totarget);
spine_evolve.Properties.VariableNames = handles.datanames([targetID, datalist]);
if ~isempty(Dendrite_CrossSess)
    Dendrite_CrossSess.Properties.VariableNames = handles.datanames([targetID, datalist]);
end
close(f_wait), delete(f_wait)
