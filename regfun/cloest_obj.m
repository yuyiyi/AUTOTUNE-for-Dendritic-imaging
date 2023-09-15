function obj = cloest_obj(data1, data2, tx, ty)

data1 = [data1(:,1)+tx data1(:,2)+ty];
distmap = pdist2(data1, data2);
obj = sum(min(distmap,[],1)) + sum(min(distmap,[],2));