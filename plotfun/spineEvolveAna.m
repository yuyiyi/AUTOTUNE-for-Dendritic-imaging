function [spine_evolve, num_turnover, Dendrite_CrossSess,...
    filelist, targetdata, TranM, handles]...
    = spineEvolveAna(handles)

% funcsel = prepCrossSessReg(handles);
%     rb1 = 'Register to the last dataset';
%     rb2 = 'Register to dataset 1';     
%     rb3 = 'Use existing transform matrix'; 
spine_evolve = [];
num_turnover = [];
Dendrite_CrossSess = [];
filelist = '';
targetdata = '';
% setup cross-session comparison target
[thresh, targetID] = prep_TurnOverAna(handles);
if isempty(thresh) || isempty(targetID)
    return
end

datalist = setdiff(1:length(handles.datafilename), targetID);

handles = loadtrace(handles, targetID);
im_mask = handles.im_norm;
handles.im_norm_mask = im_mask;
roi_seed_master = handles.roi_seed;
handles.roi_seed_master = roi_seed_master;
if isempty(roi_seed_master) || isempty(im_mask)
    return
end
spineID_mask = handles.spine_title;
spinesize_mask = handles.spinesize;
spineparameters_mask = cat(2, spineID_mask, spinesize_mask);
areasummary = [];
areasummary = cat(1, areasummary, [spinesize_mask, ones(length(spinesize_mask),1)]);
dloc = [];
if isfield(handles.spineROI, 'dendloc_linear')
    spinelinarloc_mask = [handles.spineROI.dendloc_linear]';
    spinedendriteID_mask = [handles.spineROI.dendriteID]';
    tmp = sortrows([spinedendriteID_mask, spinelinarloc_mask], [1,2]);
    dloc_mask = diff(tmp);
    dloc_mask(dloc_mask(:,1)==1,:) = [];
    dloc = cat(1, dloc, [dloc_mask(:,2), ones(size(dloc_mask,1),1)]); 
    spineparameters_mask = cat(2, spineparameters_mask, [spinelinarloc_mask, spinedendriteID_mask]);
else
    spineparameters_mask = cat(2, spineparameters_mask, zeros(length(spineID_mask),2));
end
s0 = size(spineparameters_mask, 2);
subheadings = ["_spineID" "_area" "_loc" "_dendID"];

dend_line_mask = [];
arc_all_mask = [];
dendidmask = [];
dendloc0_mask = []; % the start points of the dendrite
if ~isempty(handles.dendrite)
    dend_line_mask = handles.dend_line_all;
    dendidmask = handles.dend_title; 
    dendloc0_mask = zeros(length(dendidmask),1);
    for k = 1:length(handles.dendrite)
        dend_line = handles.dendrite(k).dend_line;
        dC = diff(dend_line,1,1);
        arc = cumsum(sqrt(sum([zeros(1,2); dC].^2,2)));
        arc_all_mask = cat(1, arc_all_mask, arc); 
    end
end
handles.dend_line_mask = dend_line_mask;

handles.savepath = handles.datafilepath;
withrotation = 1;
hplot = figure(25); clf('reset')
scrsz = handles.scrsz;
set(hplot,'Name', 'Spine evolution', ...
'Position', [100 500 handles.scrsz(3)/2 handles.scrsz(4)/2])
c1 = ceil((length(handles.datafilename)+3)/3);
c2 = 3;

subplot(c1,c2,1), 
imshow(im_mask, [])
hold on, plot(roi_seed_master(:,1), roi_seed_master(:,2), '+b')
set(gca, 'Ydir', 'reverse')
title(sprintf('registration target: dataset %d', targetID))

overlap_totarget = [];
targetdata = handles.datanames{targetID};
filelist{1,1} = fullfile(handles.datafilepath, handles.datafilename(targetID));
k1 = 0;
k2 = 1;
k3 = 0;
frac = 1/(length(datalist)+1)*0.5;
f_wait = waitbar(frac,sprintf('Cross-session alignment data %d of %d',1, length(datalist)));
clear TranM
TranM(1).R_points = eye(3);
TranM(1).t_points = zeros(3,1);

for i2 = 1:length(datalist) %2:length(handles.datafilename)    
    i1 = datalist(i2);        
    k2 = k2+1;
    handles = loadtrace(handles, i1);
    handles.savename = handles.datafilename{i1};
    handles.filename = handles.datafilename{i1};
    filelist{k2,1} = fullfile(handles.datafilepath, handles.datafilename(i1));
    
    im_norm = handles.im_norm;
    [d1, d2] = size(im_norm);
    roi_current = handles.roi_seed;
    spineID_current = handles.spine_title;
    spinesize_current = handles.spinesize;
    areasummary = cat(1, areasummary, [spinesize_current, k2*ones(length(spinesize_current),1)]);
    spineparameters_current = cat(2, spineID_current, spinesize_current);
    if isfield(handles.spineROI, 'dendloc_linear')
        spinelinarloc_current = [handles.spineROI.dendloc_linear]';
        spinedendriteID_current = [handles.spineROI.dendriteID]';
        spineparameters_current = cat(2, spineparameters_current, [spinelinarloc_current, spinedendriteID_current]);
        tmp = sortrows([spinedendriteID_current, spinelinarloc_current], [1,2]);
        dloc_current = diff(tmp);
        dloc_current(dloc_current(:,1)==1,:) = [];
        dloc = cat(1, dloc, [dloc_current(:,2), k2*ones(size(dloc_current,1),1)]); 
    else
        spineparameters_current = cat(2, spineparameters_current, zeros(length(spineID_current),2));
    end
        
    if isempty(roi_current) || isempty(im_norm)
        num_turnover = cat(1, num_turnover, [length(spineID_mask), 0, length(spineID_current)]);
        if i2 == 1
            overlap_totarget = [spineparameters_mask, zeros(length(spineID_mask),s0)];
        else
            overlap_totarget(1:length(spineID_mask), k1+1:k1+s0) = 0;
            overlap_totarget(length(spineID_mask)+1:length(spineID_current), k1+1:k1+s0) = spineparameters_current;
        end 
        continue
    end
    
    R_points = []; t_points = [];
    frac = i2/length(datalist)*0.8;
    waitbar(frac, f_wait, sprintf('Cross-session alignment data %d of %d',...
        i2, length(datalist)));

    [R_points, t_points, im_mask_reg, handles]...
        = setupCross_SessionReg(handles, im_mask, withrotation, '');
%     waitbar(0.5, f_wait,'Feature Registration');
    TranM(k2).R_points = R_points;
    TranM(k2).t_points = t_points;
    if ~isempty(roi_seed_master) && ~isempty(R_points)
        if ~isempty(dendidmask)
            if ~isempty(handles.dendrite) 
                dend_roi_current = handles.dend_rois;
                dend_line_current = handles.dend_line_all;
                dendidcurrent = handles.dend_title;
                arc_all_current = [];
                for k = 1:length(handles.dendrite)
                    dend_line = handles.dendrite(k).dend_line;
                    dC = diff(dend_line,1,1);
                    arc = cumsum(sqrt(sum([zeros(1,2); dC].^2,2)));
                    arc_all_current = cat(1, arc_all_current, arc); 
                end
                % translate the template 
                dend_line_translate = R_points*[dend_line_mask(:,1:2)'; 1*randn(1,size(dend_line_mask(:,1:2),1))];
                dend_line_translate = bsxfun(@plus, dend_line_translate, t_points);
                dend_line_translate = round(dend_line_translate(1:2,:)');
                dend_line_translate(:,3) = dend_line_mask(:,3); % mask dendrite id
                % match translated dendrite with the dendritic point available
                % in the current session
                iiout = [find(min(dend_line_translate(:,1:2),[],2)<=0); find(dend_line_translate(:,1)>d2); find(dend_line_translate(:,2)>d1)];
                dend_line_translate(iiout,:) = [];
                dendpixelidx = sub2ind(size(im_norm), dend_line_translate(:,2), dend_line_translate(:,1));
                [c, itmp] = unique(dendpixelidx);
                dend_line_translate = dend_line_translate(itmp,:);
                dendpixelidx = dendpixelidx(itmp,:);
                dendlength1 = groupcounts(dend_line_translate(:,3));
                dendidtmp = dend_roi_current(dendpixelidx); % current dendrite id            
                % generate confusion matrix h [current id, mask id] translate
                % mask to match current (1. excluding pixels outside the current image; 
                % 2. match dendritic id by pixel overlap)
                dendorder = unique([dendidcurrent; dendidmask]);
                dendlength = zeros(length(dendorder),1)+eps;
                dendlength(ismember(dendidmask, dendorder)) = dendlength1;
                [h, dorder] = confusionmat(dendidtmp(dendidtmp~=0), dend_line_translate(dendidtmp~=0,3),'Order', dendorder);
                [matchv, matchid] = max(h); % matched dend in the current dataset            

                dendoverlaptmp = [];
                dendoverlaptmp = [dorder, dorder(matchid)]; 
                dendoverlaptmp(matchv./dendlength'<0.2,2) = 0;
                dendoverlaptmp(~ismember(dendoverlaptmp(:,1), dendidmask), :) = [];
                dendoverlaptmp = sortrows(dendoverlaptmp, 1);            

                % map the current dendritic start loc relative to the matched
                % template (linear location in pixel)
                dendiniloctmp = dendloc0_mask;
                for i3 = 1:size(dendoverlaptmp,1) 
                    did1 = dendoverlaptmp(i3,1);
                    did2 = dendoverlaptmp(i3,2);
                    if did1*did2>0
                        tmplinemask = dend_line_mask(dend_line_mask(:,3)==did1,1:2);
                        tmplinecurrent = dend_line_current(dend_line_current(:,3)==did2,1:2);
                        dd1 = pdist2(tmplinecurrent(1,:), tmplinemask);
                        [v1,idx1] = min(dd1,[],2);
                        arctmp = arc_all_mask(dend_line_mask(:,3)==did1);
                        arc1 = arctmp(idx1);
                        dd2 = pdist2(tmplinemask(1,:), tmplinecurrent);
                        [v2,idx2] = min(dd2,[],2);
                        arctmp = arc_all_mask(dend_line_current(:,3)==did2);
                        arc2 = arctmp(idx2);
                        
                        if arc1>=arc2
                            dendiniloctmp(i3,2) = arc1;
                        else
                            dendiniloctmp(i3,2) = -arc2;                        
                        end
                    else
                        dendiniloctmp(i3, 2) = nan;
                    end
                end
                % append new dendrite to the table
                if ~isempty(setdiff(dendidcurrent, dendoverlaptmp(:,2)))
                    tmp = setdiff(dendidcurrent, dendoverlaptmp(:,2));
                    dendoverlaptmp = cat(1, dendoverlaptmp, [nan(length(tmp),1), tmp]);
                    dendiniloctmp = cat(1, dendiniloctmp, [nan(length(tmp),1), zeros(length(tmp),1)]);
                end
            elseif isempty(handles.dendrite)
                dendoverlaptmp = [dendidmask, nan(length(dendidmask),1)];
                dendiniloctmp = [dendloc0_mask, nan(length(dendidmask),1)];
            end
            if i2 == 1
                Dendrite_CrossSess = [dendoverlaptmp(:,1),dendiniloctmp(:,1),dendoverlaptmp(:,2),dendiniloctmp(:,2)];
            else
                Dendrite_CrossSess(1:size(dendoverlaptmp,1), k3+1:k3+2) = [dendoverlaptmp(:,2),dendiniloctmp(:,2)];
            end
            k3 = size(Dendrite_CrossSess,2);
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
        overlaptmp = [spineparameters_mask(ia,:), spineparameters_current(ib,:)];
        if ~isempty(ia_miss)
            overlaptmp = cat(1, overlaptmp, [spineparameters_mask(ia_miss,:),...
                zeros(length(ia_miss), s0)]);
        end
        overlaptmp = sortrows(overlaptmp, 1);
        
        if i2 == 1
            overlap_totarget = overlaptmp;
        else
            overlap_totarget(1:size(overlaptmp,1), k1+1:k1+s0) = overlaptmp(:,s0+1:s0*2);
        end
        if ~isempty(ib_miss)
            overlaptmp_gain = [zeros(length(ib_miss),s0), spineparameters_current(ib_miss, 1:s0)];
            if i2 == 1
                overlap_totarget = cat(1, overlap_totarget, overlaptmp_gain);
            else
                overlap_totarget(size(overlaptmp,1)+[1:length(ib_miss)], k1+1:k1+s0)...
                    = overlaptmp_gain(:,s0+1:s0*2);
            end
        end 
        k1 = size(overlap_totarget, 2);
%         spine_evolve(i1).match = [spineID_mask(ia), spineID_current(ib)];        
%         spine_evolve(i1).new = spineID_current(ib_miss);
%         spine_evolve(i1).turnover = spineID_mask(ia_miss);
        
        num_turnover = cat(1, num_turnover, [length(ia_miss), length(ia), length(ib_miss)]);
    end
end
figure(25), subplot(c1,c2,i2+1),
legend('retained', 'lost', 'gained')

figure(25), subplot(c1,c2,length(handles.datafilename)+1),
bar(num_turnover', 'LineStyle', 'none')
    legend(handles.datanames([datalist]))
% if size(num_turnover,1)>2
%     subplot(c1,c2,length(handles.datafilename)+1), 
%     barwitherr(std(num_turnover,[],1)/sqrt(size(num_turnover,1)),mean(num_turnover,1))
% else
%     subplot(c1,c2,length(handles.datafilename)+1),
%     bar(mean(num_turnover,1))
% end
    box off, set(gca,'XTickLabel',{'lost', 'retain', 'gain'})
    ylabel('Number of spines')

num_turnover = array2table(num_turnover);
num_turnover.Properties.VariableNames = {'lost', 'retain', 'gain'};
overlap_totarget(overlap_totarget==0) = nan;
spine_evolve = array2table(overlap_totarget);
str = append(handles.datanames([targetID, datalist])',subheadings);
spine_evolve.Properties.VariableNames = reshape(str', 1, []);

handles.thresh = thresh;
handles.targetID = targetID;
handles.tabletitlesub = handles.datanames([targetID, datalist]);

% assignin('base', 'spine_evolve', spine_evolve);

if ~isempty(Dendrite_CrossSess)
%     assignin('base', 'Dendrite_CrossSess', Dendrite_CrossSess);
    Dendrite_CrossSess = array2table(Dendrite_CrossSess);
    subheadings = ["_dendID" "_startloc"];
    str = append(handles.datanames([targetID, datalist])',subheadings);
    Dendrite_CrossSess.Properties.VariableNames = reshape(str', 1, []);
end
close(f_wait), delete(f_wait)

if ~isempty(areasummary)
    xx = linspace(floor(min(areasummary(:,1))-1), ceil(max(areasummary(:,1))+1), 20);
    dx = mean(diff(xx));
    [h, Xedges, Yedges] = histcounts2(areasummary(:,1), areasummary(:,2),...
        xx, 1:length(handles.datafilename)+1);
    subplot(c1,c2,length(handles.datafilename)+2), 
    bar(xx(1:19)+dx/2, h, 'LineStyle', 'none')
    legend(handles.datanames([targetID, datalist]))
    box off, xlabel('Spine area (pixel)'), ylabel('Number of spines')
end

if ~isempty(dloc)
    xx = linspace(0, ceil(max(dloc(:,1))), 20);
    dx = mean(diff(xx));
    [h, Xedges, Yedges] = histcounts2(dloc(:,1), dloc(:,2),...
        xx, 1:length(handles.datafilename)+1);
    subplot(c1,c2,length(handles.datafilename)+3),
    bar(xx(1:19)+dx/2, h, 'LineStyle', 'none')
    legend(handles.datanames([targetID, datalist]))
    box off, xlabel('Spine distance (pixel)'), ylabel('Number of spines')
end
drawnow
