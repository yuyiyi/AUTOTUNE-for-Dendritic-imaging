function showregresult(RegPara, imagefilename)
scrsz = get(groot,'ScreenSize');
meanImg_PreReg = RegPara.meanImg_PreReg;
meanImg_PostReg = RegPara.meanImg_PostReg;
if isempty(findobj('type','figure','number',10))
    pos = round([10 20 scrsz(3)/3*1 scrsz(4)/2*1]);
else
    h1_handles = get(figure(10));
    pos = h1_handles.Position;
end        
h1 = figure(10);
clf('reset')
set(h1,'Name',['Registrartion results ' imagefilename],'Position',pos);
subplot(221), plot(RegPara.dsall), title('Motion')
subplot(222), plot(RegPara.CorrAll), title('Correlation')
subplot(223), imshow(meanImg_PreReg, []), title('Pre registration mean ')
subplot(224), imshow(meanImg_PostReg, []), title('Post registration mean ')
drawnow
