function showscalebar(im, s)
[d1, d2] = size(im);
d3 = ceil(d1*0.05);
d4 = ceil(d2*0.05);
hold on, plot([d4 d4], d1-[d3, d3-1+s], 'color', 'm', 'linewidth', 2)


