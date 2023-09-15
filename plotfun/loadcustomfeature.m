function [cfeature_dff, cfeature_trace, feature_title]...
    = loadcustomfeature(variablename, variableinfo, datafilepath, datafilename)

variableinfo2 = whos('-file', fullfile(datafilepath, datafilename));    

cfeature_dff = [];
cfeature_trace = [];
feature_title = [];
featurenum = 1;
if ~isempty(variablename)
    for k1 = 1:length(variablename)
        ii = strcmp(variableinfo, variablename{k1});
        if isempty(ii)
            continue
        end
        k = find(ii==1);
        if ~strcmp(variableinfo{k}, 'framestamp') && ~strcmp(variableinfo{k}, 'stampinfo')...
            && variableinfo2(k).size(1)>10 && length(variableinfo2(k).size) == 2 ...
            && (strcmp(variableinfo2(k).class, 'single') || strcmp(variableinfo2(k).class, 'double'))
            temp = load(fullfile(datafilepath, datafilename), variableinfo{k}); 
            aa = fieldnames(temp); 
            tracetmp =  temp.(aa{1});
            cfeature_trace = cat(2, cfeature_trace, tracetmp);
            for i = 1:size(tracetmp, 2)
                cfeature_dff = cat(2, cfeature_dff, getdff(tracetmp(:,i))); 
                feature_title{featurenum} = [variableinfo{k},' ', num2str(i)];
                featurenum = featurenum+1;
            end
        end
    end
end
