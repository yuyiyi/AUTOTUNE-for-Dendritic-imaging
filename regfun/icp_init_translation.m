function [XX, t] = icp_init_translation(XX, YY)
% tri = delaunayn(YY');
% [idx, D] = dsearchn(YY', tri, XX');
% data_match = [idx, [1 : size(XX,2)]', D];    
% %     distTh = mindist;
% data_match = sortrows(data_match, [1, -3]);
% [~, ii, ~] = unique(data_match(:,1));
% data_match = data_match(ii,:);

% x0 = mean(XX(:,data_match(:,2)),2);
% y0 = mean(YY(:,data_match(:,1)),2);
x0 = mean(XX,2);
y0 = mean(YY,2);
t = zeros(3,1);
if max(abs(x0 - y0))> 10
    t = y0 - x0;
    XX = bsxfun(@plus, XX, y0-x0);
end