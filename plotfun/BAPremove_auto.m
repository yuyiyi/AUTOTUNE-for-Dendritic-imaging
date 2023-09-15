function [trace_noBAP, coef] = BAPremove_auto(spinedff, dend_dff, inputcoef)
x0 = dend_dff; 
y0 = spinedff;
coef = [];
Maxiter = 5;
Maxtolt = 0.05;
if nargin<3
    inputcoef = [];
end
if isempty(inputcoef)
    f = fittype('a.*x', 'dependent',{'y'}, 'independent', {'x'}, 'coefficients',{'a'});
    xx = linspace(min(min(dend_dff),0), max(dend_dff), 500);
    x2 = dend_dff(y0<x0,1);
    y2 = spinedff(y0<x0);
    if ~isempty(x2)
        iter = 1;
        dcoef = 1;
        coef0 = 1;
        while iter< Maxiter && dcoef > Maxtolt
            if ~isempty(y2)
                [obj2, gof2] = fit(x2, y2, f, 'StartPoint', 0.5);
                coef = obj2.a;
            else
                coef = 1;
            end 
            ypred = abs(y0 - coef*x0);
            y2 = spinedff(ypred<quantile(ypred,0.4));
            x2 = dend_dff(ypred<quantile(ypred,0.4));
            dcoef = abs(coef-coef0);
            coef0 = coef;
        end
    else
        %%%% dendritic signal is samller than dendritic signal all the time
        [obj2, gof2] = fit(x0, y0, f, 'StartPoint', 1);
        coef = obj2.a;        
    end
    coef = max(0, coef);
else
    coef = inputcoef;
end

trace_noBAP = y0-x0*coef;
