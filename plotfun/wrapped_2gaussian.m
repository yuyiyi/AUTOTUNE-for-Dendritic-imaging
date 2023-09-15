function y = wrapped_2gaussian(x, a1, a2, mu, sigma1, sigma2)
if nargin==2
    coef = a1;
    a1 = coef(1);
    a2 = coef(2);
    mu = coef(3);
    sigma1 = coef(4);
    sigma2 = coef(5);
end

% 'f(x) = a1*exp(-((x-b1)/c1)^2) + a2*exp(-((x-(b1+pi))/c2)^2)'; 
y = a1 * exp(-min(abs(x - mu), mu+2*pi-x).^2 ./ (2 * sigma1^2)) +...
    a2 * exp(-min(abs(x - mu+pi), mu+pi-x).^2 ./ (2 * sigma2^2));
