function writepdf(figurehandle,epsfilename);
set(figurehandle,'Position',[ 210   153   950   827]);
% if exist([matpath '..\figure\'],'dir');
% else
%     mkdir([matpath '..\figure\']);
% end
set(figurehandle, 'PaperPositionMode', 'auto')
print('-dpdf',epsfilename);