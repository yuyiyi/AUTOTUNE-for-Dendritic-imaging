function [R1, t1] = PointCloud_reg(XX, YY)
x0 = mean(XX,2);
y0 = mean(YY,2);
n = size(XX,2);
Y_center = bsxfun(@minus, YY, y0);
Xshifted = bsxfun(@minus, XX, x0);


H = Y_center*Xshifted';
H = H/n;
[U, ss, V] = svd(H);
R1 = V*U';
if det(R1)<0
    B = eye(3);
    B(3,3) = det(V*U');
    R1 = V*B*U';
end
t1 = x0 - R1*y0;
