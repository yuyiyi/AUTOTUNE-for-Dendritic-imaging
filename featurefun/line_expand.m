function [arc, kymo_cordinate] = line_expand(cspoints, linewidth, arc_grad)

[dC] = diff(cspoints,1,2);
arc = cumsum(sqrt(sum([zeros(2,1) dC].^2,1)));
dC = [dC(:,1) dC];
normC = sqrt(sum(dC.^2,1));
dC = dC./repmat(normC,[2 1]);

if nargin<3
    arc_grad = length(arc);
end

arc_cord = linspace(0, floor(max(arc)), arc_grad);
Xi = interp1(arc,cspoints(1,:),arc_cord,'linear');
Yi = interp1(arc,cspoints(2,:),arc_cord,'linear');
dX = interp1(arc,dC(1,:),arc_cord,'linear');
dY = interp1(arc,dC(2,:),arc_cord,'linear');
normX = sqrt(sum(dX.^2+dY.^2,1));
dX = dX./normX;
dY = dY./normX;
Nx = dY;
Ny = -dX;

linewidth = ceil(linewidth/2)*2+1;
w = (linewidth-1)/2;
gradM = 0*eye(2);
for i = 1:w
    gradM = [-w/2*i*eye(2);gradM;w/2*i*eye(2)];
end
kymo_cordinate = repmat([Xi;Yi],[linewidth 1]) + gradM*[Nx;Ny];
