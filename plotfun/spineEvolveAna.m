function [spine_evolve, num_turnover] = spineEvolveAna(handles)

% funcsel = prepCrossSessReg(handles);
%     rb1 = 'Register to the last dataset';
%     rb2 = 'Register to dataset 1';     
%     rb3 = 'Use existing transform matrix'; 
spine_evolve = [];
num_turnover = [];
prompt = {'\fontsize{9} Threshold for spine matching (pixel):'};
dlgtitle = 'Input';
dims = [1.6 60];
definput = {'3'};
opts.Interpreter = 'tex'; 
answer = inputdlg(prompt,dlgtitle,dims,definput,opts);
if ~isempty(answer)
    thresh = str2num(answer{1});
else
    return
end
handles = loadtrace(handles, 1);
im_mask = handles.im_norm;
roi_seed_master = handles.roi_seed;
spineID_mask = handles.spine_title;

handles.savepath = handles.datafilepath;
withrotation = 1;
num_turnover = [];
hplot = figure(25); clf('reset')
scrsz = handles.scrsz;
set(hplot,'Name', 'Spine evolution');
if (length(handles.datafilename)+1)>5
    c1 = ceil((length(handles.datafilename)+1)/5);
    c2 = 5;
else
    c2 = (length(handles.datafilename)+1);
    c1 = 1;
end
subplot(c1,c2,1), 
imshow(im_mask, [])
hold on, plot(roi_seed_master(:,1), roi_seed_master(:,2), '+b')
set(gca, 'Ydir', 'reverse')
title('data 1')

for i1 = 2:length(handles.datafilename)    
    handles = loadtrace(handles, i1);
    handles.savename = handles.datafilename{i1};
    handles.filename = handles.datafilename{i1};
    im_norm = handles.im_norm;
    roi_current = handles.roi_seed;
    spineID_current = handles.spine_title;
    
    R_points = []; t_points = [];
    f_wait = waitbar(0.2,'Feature Registration');
    [R_points, t_points, im_mask_reg, handles]...
        = setupCross_SessionReg(handles, im_mask, withrotation, '');
    waitbar(0.5, f_wait,'Feature Registration');

    if ~isempty(roi_seed_master) && ~isempty(R_points)
        roi_seed = R_points*[roi_seed_master'; 1*randn(1,size(roi_seed_master,1))];
        roi_seed = bsxfun(@plus, roi_seed, t_points);
        roi_seed = roi_seed(1:2,:)';
        dd = pdist2(roi_seed, roi_current);
        [v,idx] = min(dd,[],2);
        % spine didn't change
        ia = find(v<thresh);
        ib = idx(ia);
        ia_miss = setdiff(1:size(roi_seed,1), ia);
        ib_miss = setdiff(1:size(roi_current,1), ib);
        figure(25), subplot(c1,c2,i1)
        imshow(im_norm, [])
%         set(gca, 'Ydir', 'reverse')
%         hold on, plot(roi_seed(ia,1), roi_seed(ia,2), 'or') 
        if ~isempty(ib)
        hold on, plot(roi_current(ib,1), roi_current(ib,2), '+b')
        else
        hold on, plot(nan,nan, '+b')
        end  
        if ~isempty(ia_miss)
        hold on, plot(roi_seed(ia_miss,1), roi_seed(ia_miss,2), 'og')
        else
        hold on, plot(nan,nan, 'og')
        end
        if ~isempty(ib_miss)
        hold on, plot(roi_current(ib_miss,1), roi_current(ib_miss,2), 'or')
        else
        hold on, plot(nan, nan, 'or')            
        end
        title('data2')
        spine_evolve(i1).match = [spineID_mask(ia), spineID_current(ib)];        
        spine_evolve(i1).new = spineID_current(ib_miss);
        spine_evolve(i1).turnover = spineID_mask(ia_miss);
        num_turnover = cat(1, num_turnover, [length(ia_miss), length(ia), length(ib_miss)]);
    end
end
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
close(f_wait), delete(f_wait)
