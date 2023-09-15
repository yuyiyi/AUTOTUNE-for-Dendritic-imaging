function dff = getdff(trace)
if ~isempty(trace)
    f = quantile(trace,0.4,1); % This seems to work nicely for most signals, but it may need to be changed for highly active cells
    fmean = mean(trace,1);
    b = ones(1, size(trace,2));
    th = max(trace,[],1)*0.01;
    dff = [];
    for k = 1:size(trace,2)
        if f(k)<=th(k)
            b(k) = fmean(k);
            f(k) = fmean(k);
        end
    end
    df = bsxfun(@minus, trace, f);
    dff = bsxfun(@rdivide, df, f);
    
%         df = bsxfun(@rdivide, trace, f);
%         dff = bsxfun(@minus, df, b);
else
    dff = [];
end