function circularfit
fmodel = fittype('a*exp(kappa*(cos(x-mu)-1) ) / (2*pi*besseli(0,kappa,1))',...
    'independent', 'x');
xx = min(abs(mu-x), mu+2*pi-x);
y = exp(-xx.^2/(2*1^2));
figure, plot(x, y)
[fitobject1, gof1] = fit(x', y', fmodel, 'Startpoint', [1,1,1]);