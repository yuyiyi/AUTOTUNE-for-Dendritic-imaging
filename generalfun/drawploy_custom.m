function drawploy_custom(shapeoutline, shapecolor, Mver)

if str2double(Mver(end-4:end))<2019
    h1 = impoly(gca, shapeoutline);
    h1.Deletable = false;
    setColor(h1, shapecolor)
    setVerticesDraggable(h1, false) 
else         
    drawpolygon(gca,'Position', shapeoutline, ...
        'Color', shapecolor,...
        'FaceAlpha', 0.2, ...
        'InteractionsAllowed', 'none',...
        'Linewidth', 0.5);
end
