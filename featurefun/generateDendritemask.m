function handles = generateDendritemask(handles)
handles.roimask = zeros(size(handles.im_norm));
for k = 1:length(handles.dendrite)
    ii = handles.dendrite(k).dend_pixel;
    dendroi = zeros(size(handles.im_norm));
    dendroi(ii) = 1;
    handles.roimask = handles.roimask + dendroi;
end