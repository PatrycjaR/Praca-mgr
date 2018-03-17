function []=fun_test360(fn, vr, dir) %zmien version, bo pokazuje wersje matlaba!!
%przetwarzaj(fn, version, ...)
% wczytywanie filmu
%dla szybkiego
% fn = '1 (53).mp4';
structure.Face=[]; % +
structure.Body=[]; % +
structure.Markers=[]; % +
structure.IsFace=[]; %+
structure.Sum=[];  %+
structure.Frames=[]; % +
structure.Mask=[]; % +
structure.TimeOfRound=[]; % +
structure.FrameWithMarker=[];
%czytanie filmu i ewentualny zapis .mat

[FRAMES, countOfFrames, structure, fps]=Fun_ReadAndSave(fn, structure, dir);

% FrameWithMarker=cell(size(FRAMES));
%% pomniejszanie ramek
FRAMES2 = cell(size(FRAMES));
for i = 1 : length(FRAMES)
    FRAMES2{i} = histeq(FRAMES{i});
 fprintf(1, 'ramka %d z %d\n', i, countOfFrames);
end
disp('skonczylem')

FRAMES3 = cell(size(FRAMES));
for i = 1 : length(FRAMES)
     fprintf(1, 'ramka %d z %d\n', i, countOfFrames);
    FRAMES3{i} = FRAMES{i}(1:10:end, 1:10:end);
    structure.Frames{i}=FRAMES{i};
     %FRAMES3{i} = FRAMES2{i}(1:10:end, 1:10:end);
end
disp('skonczylem')




%% poszukiwanie ciala i twarzy

%mask = [];
 [mask, structure]=Fun_FindFaceAndBody(FRAMES, structure);
% [mask, structure]=Fun_FindBody(FRAMES, structure); %, FrameWithMarker);

structure.Mask=mask;

%% poszukiwanie miejsca, gdzie najczesciej zostaï¿½a znaleziona twarz

sizeOfFrames=size(FRAMES{1,1},1);
positionOfBody=Fun_PositionOfBody(mask);

% wyciecie tylko poszczegolnych elementow w obrazie
% poszukiwanie punktow poruszajacych sie na obrazie
i=1;

[timeOfRound, howMuchFrame1, structure]=Fun_TurningTimeTogether(FRAMES, positionOfBody, structure);

structure.TimeOfRound=timeOfRound;

fn=strrep(fn,'.mp4','');
structureName=strcat(fn,'_structure','_vr_',num2str(vr));

if(~exist('Struktury', 'dir'))
    workingDirStr = 'Struktury';
    mkdir(workingDirStr);
else
    workingDirStr = 'Struktury';
end


% zapis ramek do m. pliku

%     dstpath = strrep(structureName, '.mp4', '.mat');
    structureName=strcat(structureName,'.mat');
    save(fullfile(workingDirStr, structureName ), 'structure','-v7.3');




Fun_CreateVideo(structure, structureName,fps)

X=['Policzy³em do ', num2str(timeOfRound), ' sekund.']
        disp(X);
        
        %roznica pomiedzy howMuchFrame1, a 2 z drugiego obrotu bedzie
        %czasem pauzy wykonanej pomiedzy obrotami
% notatki!! w poszczegolnych funkcjach zobacz co pisalas; kolejnym krokiem
% jest dokonanie podzialu, a mianowicie: po pierwszym obrocie program Ci
% sie wylaczy, bo uzna ze znalazl obrot i drugiego nie bedzie analizowal,
% dlatego trzeba znowu uruchomic w ODPOWIEDNIM momencie turningTime, ale z
% podanymi pozycjami dla twarzy, nie dla calego ciala; bedac w funkcji
% position of body tam ustalasz pozycje ciala, postaraj sie ustalic tez
% pozycjé samej twarzy, zeby w tym koeljnym kroku wiedzial, gdzie ma tylko
% szukac twarzy- ponowne znalezienie twarzy bedzie u nas drugim obrotem-
% jakos to musisz polaczyc- KONIECZNIE!!!
