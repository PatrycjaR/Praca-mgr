function [timeOfRound, howMuchFrame, structure]=Fun_TurningTimeTogether(FRAMES, positionOfBody, structure)
profile on
%%
%i=1;
tracker = vision.PointTracker;
points = detectMinEigenFeatures(FRAMES{1}, 'MinQuality', 0.1, 'ROI', positionOfBody);
tracker.initialize(points.Location, FRAMES{1}); % -> powtarzac co np. 50 ramek
%%
oldpoints = points.Location;

% player = vision.VideoPlayer('Position', [0 0 size(FRAMES{1}, 2), size(FRAMES{1}, 1)]);

counter=1;
isStart=false;
isEnd=false;
endignFirstTurn=0;
ending=0;

beginSecondTurn=false;
FirstTurn=false;
countOfFrames=size(FRAMES,2);

SUMA = zeros([1 countOfFrames]);
ISFACE = zeros(size(SUMA));

faceDetector = vision.CascadeObjectDetector('UseROI', true); % TUTAJ UZYC ROI

for i = 1: countOfFrames % tutaj zmieni�am 1:countOfFrames
    
    fprintf(1, '.');
    
    % tutaj doda� nowego if elseif !!!!
%     oldpointPrime to doko�czy�
% znale�� najepsze punkty (najbardziej zmieniaj�ce si�). zrobi� pochodn�
% czyli pr�dko�� zeby usuna� pr�dko�� gigantycznych skok�w. 
% zmiana po�o�e� w czasie = pr�dko��. 
    if(rem(i + 1, 50) == 0)
        Prime = detectMinEigenFeatures(FRAMES{1}, 'MinQuality', 0.1, 'ROI', positionOfBody);
        newPointsPrime=Prime.Location;
        trackerPrime = vision.PointTracker;
        trackerPrime.initialize(newPointsPrime, FRAMES{i}); 
    elseif (rem(i, 50) == 0)
        tracker = trackerPrime;
        oldpoints=newPointsPrime;
    end
    
    [np, v] = tracker.step(FRAMES{i});
    
    structure.Markers{i}=np;
    
    roznica = np - oldpoints;
    roznica(~v, :) = [];
    if (isempty(roznica))
        roznica=zeros(size(roznicaX,1),2)
        %         error('... error ...');
    end
    
    
    
    roznicaX = roznica(:, 1); %x-y
    [~, I] = sort(abs(roznicaX), 'descend');
    
    % 1 - najwi�kszy
    SUMA(i) = sum(roznicaX(I(1:min(5, length(roznicaX))))); % i nie zawsze ma wymiar minimum 5!!!!!!
    
    f = FRAMES{i};
    nn = [oldpoints np];
    nn(~v, :) = [];
    
    %     f = insertShape(f, 'Line', nn);
    fWm=structure.FrameWithMarker{i};
    structure.FrameWithMarker{i}= insertShape(fWm, 'Line', nn);
  
    fWm=structure.FrameWithMarker{i};
    f2 = insertMarker(fWm, [oldpoints(:,1),oldpoints(:,2)], 'o');
    structure.FrameWithMarker{i}=f2;
    
    %plot(oldpoints(:,1),oldpoints(:,2),'*r')
   % player.step(f2);
    
    oldpoints = np;
    
    
    bboxes=step(faceDetector, FRAMES{i}, positionOfBody); % <-- TUTAJ RO
    
    if (isempty(bboxes))
        ISFACE(i) = false;
    else
        ISFACE(i) = true;
    end
    
    
    
    SUMAfilter=movmean(SUMA,60);% mrugniecie trwa okolo 0.3 sekundy, iphone ma 30fps, kamera 50, wiec 20 klatek
    IsFaceFilter=movmean(ISFACE,50)>0.8;
    
    structure.Sum=SUMAfilter;
    structure.IsFace=IsFaceFilter;
    
end

structure.SumDec=Fun_DecGradMean(SUMAfilter);


% movmean -> filter([1 1 1 1 ], 1, ...) -> na SUMIE
%
% ISFACE -> moveman z okienkiem 4 lub 5 i progowanie na >=0 (lub podobnie >1/4)
% plot
%*******************************
begin=false; % tutaj zapisz SUMAfilter i IsFaceFilter!!!!!!

for i = 1 : countOfFrames
    
    %     if (i>2 &&  isempty(bboxes) &&  isStart==false && isEnd==false && FirstTurn==false && abs((SUMA(i)))-abs((SUMA(i-1)))>10)%&& isStart==false && isEnd==false && FirstTurn==false)
    %         counter=i;% wyzej byly wersje >40, z i-1, dobrze byloby gdyby pomin�� wykrywanie oczu w wykrywaniu twarzy
    %         isStart=true;
    %     end
    % detekcja pocz�tku obrotu
    
    if(IsFaceFilter(i)==1 && isStart==false)
        begin=true;
    end
    if(IsFaceFilter(i)~=1 && begin==true && isStart==false && isEnd==false && FirstTurn==false ) %zobaczyc jak wyglada SUMA po filtracji, jak sie zmieniaja wzajemnie warto�ci, sprawdzi� wi�ksze okno dla sumy
        counter=i-9;
        isStart=true;
    end
    
    %     if(i>counter+100 && isStart==true && (~isempty(bboxes)) && isStart==true && isEnd==false && FirstTurn==false) %&& abs((abs((SUMA(i)))-abs((SUMA(i-10)))))<2 && isStart==true && isEnd==false && FirstTurn==false)
    %
    %         FirstTurn=true;
    %         endignFirstTurn=i;
    %         beginPause=i;
    %         isStart=false;
    %         %howMuchFrame=ending-counter;
    %         %timeOfRound=howMuchFrame/30;%round((howMuchFrame/30)+0.1,1);
    %     end
    
    % koniec pierwszego obrotu
    
    if(IsFaceFilter(i)==1 && isStart==true && isEnd==false && FirstTurn==false)
        FirstTurn=true;
        endignFirstTurn=i;
        beginPause=i;
        isStart=false;
    end
    
    %     if (i>10 && isempty(bboxes) && isStart==true && isEnd==false && FirstTurn==false && abs((SUMA(i)))-abs((SUMA(i-1)))>40) %abs((SUMA(i)))-abs((SUMA(i-1)))>40&& isStart==false && isEnd==false && FirstTurn==true)
    %         endPause=i;
    %         isStart=true;
    %         beginSecondTurn=true;
    %         secondTurn=i;
    %     end
    
    % pocz�tek kolejnego obrotu
    
    if(IsFaceFilter(i)~=1 && isStart==false && FirstTurn==true && isEnd==false)
        isStart=true;
        secondTurn=i;
        beginSecondTurn=true;
    end
    
    %     if(i>counter+150 && (~isempty(bboxes)) && isStart==true && isEnd==false && beginSecondTurn==true) %abs((abs((SUMA(i)))-abs((SUMA(i-10)))))<2 && isStart==true && isEnd==false && beginSecondTurn==true)
    %        %if(i>counter+60 && abs(SUMA(i))<0.5 && isStart==true && isEnd==false) %norma
    %      %if(abs(SUMA(i))<2 && isStart==true) % wolne
    %         FirstTurn=true;
    %         ending=i;
    % %         endignFirstTurn=i;
    % %         beginPause=i;
    %         isEnd=true;
    %         howMuchFrame=ending-counter;
    %         timeOfRound=howMuchFrame/30;%round((howMuchFrame/30)+0.1,1);
    %     end
    
    %koniec obrotu
    
    if(IsFaceFilter(i)==1 && isEnd==false && beginSecondTurn==true)
        isEnd=true;
        ending=i+9;
        %howMuchFrame=((endignFirstTurn-counter)+(ending-secondTurn));
        %	timeOfRoundPaus=howMuchFrame/30;%round((howMuchFrame/30)+0.1,1);
        howMuchFrame=ending-counter;
        timeOfRound=(ending-counter)/50;
    end
    
    % kiedy nie ma drugiego obrotu lub cos jest nie tak
    
    % 	if (IsFaceFilter(i)==1 && isStart==false && FirstTurn==true && beginSecondTurn==false)
    % 		error('co� posz�o nie tak!');
    % 	end
    %plot(movmean(SUMA, 50))
    %plot(movmean(ISFACE, 60)>0.5)
end

if (~exist('timeOfRound','var'))
    [timeOfRound, howMuchFrame]=TurningSUM(SUMAfilter, IsFaceFilter, countOfFrames)
end

%profile off
%disp('debug');
%plot(movmean(SUMA, 25))
end

%find(ISFACEpoFiltrowaniu==0, 'last') -> ostatnie zniknięcie twarzy  itp.
%
% SUMA(~ISFACE) = 0;