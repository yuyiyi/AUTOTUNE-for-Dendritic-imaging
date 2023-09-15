function y = wrapped_1gaussian(x, a, mu, sigma)
if nargin==2
    y = a(1) * exp(-min(abs(x - a(2)), a(2)+2*pi-x).^2 ./ (2 * a(3)^2));    
else
    % fmodel = 'f(x) = a1*exp(-((x-b1)/c1)^2)';                
    y = a * exp(-min(abs(x - mu), mu+2*pi-x).^2 ./ (2 * sigma^2));
end