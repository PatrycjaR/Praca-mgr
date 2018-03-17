function [FRAMES, countOfFrames]=ReadAndSaveColor(path, dstpath)

reader = vision.VideoFileReader(path, 'ImageColorSpace', 'RGB');
%
% sprawdzenie iloï¿½ci ramek w filmie
countOfFrames = 0;
FRAMES = cell([1 1000]);
while ~isDone(reader)
    countOfFrames = countOfFrames + 1;
    %FRAMES{countOfFrames} = imrotate(reader.step(),-90);
    FRAMES{countOfFrames} = reader.step();%permute(reader.step(), [2 1 3]); 
end

FRAMES = FRAMES(1:countOfFrames);

if (~exist('dstpath', 'var'))
    dstpath = strrep(path, '.mp4', 'kolor.mat');
end

% zapis ramek do m. pliku
save(dstpath, 'FRAMES');

% reader = vision.VideoFileReader(path, 'ImageColorSpace', 'Intensity');
% FRAMES = cell([1 countOfFrames]);
% for i=1:countOfFrames
%     f=reader.step();
%     f1=step(reader);
%     %f=imrotate(f1,-90);
%     FRAMES{i} =f;
% end

disp('skoñczy³em zapis')
end