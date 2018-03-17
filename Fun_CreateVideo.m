function [a b]=Fun_CreateVideo(structure, structureName,fps)

fn=strrep(structureName,'.mat','');
structureName=strcat(fn, '_Markery','.avi');


if(~exist('Naniesione punkty', 'dir'))
    workingDir = 'Naniesione punkty';
    mkdir(workingDir);
else 
    workingDir = 'Naniesione punkty';
end

outputVideo = VideoWriter(fullfile(workingDir, structureName ));
outputVideo.FrameRate = fps; %frame per second
open(outputVideo);

for ii = 1:size(structure.Frames,2)
  
    writeVideo(outputVideo,structure.FrameWithMarker{ii})

end

close(outputVideo)

end
