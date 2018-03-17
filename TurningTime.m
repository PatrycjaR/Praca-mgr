function [timeOfRound, howMuchFrame]=TurningTime(FRAMES, positionOfBody)
%  ZMIANA!!!  trzeba zmienic, zeby przyjmowal tez howMuchFrame- zrobic go
%  uniwersalnego dla obu obrotów

% wyciecie tylko poszczegolnych elementow w obrazie
% poszukiwanie punktow poruszajacych sie na obrazie
i=1;
tracker = vision.PointTracker;
points = detectMinEigenFeatures(FRAMES{1}, 'MinQuality', 0.7, 'ROI', positionOfBody);
tracker.initialize(points.Location, FRAMES{1});

oldpoints = points.Location;

player = vision.VideoPlayer('Position', [0 0 size(FRAMES{1}, 2), size(FRAMES{1}, 1)]);

counter=1;
isStart=false;
isEnd=false;
ending=0;

countOfFrames=size(FRAMES,2);
SUMA = zeros([1 countOfFrames]);
%SUMA = zeros([1 270]);

for i = 1: countOfFrames % tutaj zmieni³am 1:countOfFrames
    
    
    
    fprintf(1, '.');
    [np, v] = tracker.step(FRAMES{i});
    
    roznica = np - oldpoints;
    roznica(~v, :) = [];
    if (isempty(roznica))
        error('... error ...');
    end
    
    roznicaX = roznica(:, 1); %x-y
    [~, I] = sort(abs(roznicaX), 'descend');
    
%    if (size(I,1)<5)
%       for k=(size(I,1)+1):1:5
%           I(k,1)=k;
%           roznicaX(k,1)=0;
%       end
%    end
    % 1 - najwiêkszy 
    SUMA(i) = sum(roznicaX(I(1:5))); % i nie zawsze ma wymiar minimum 5!!!!!!
    
    
    f = FRAMES{i};
    nn = [oldpoints np];
    nn(~v, :) = [];
    
    f = insertShape(f, 'Line', nn);
    
    
  %  player.step(f);
% 
%     imshow(f)
%     hold on
%     plot(oldpoints(:,1),oldpoints(:,2),'*r')
%     
    oldpoints = np;

    if (i>2 && abs(round(SUMA(i)))-abs(round(SUMA(i-2)))>0.5 && isStart==false && isEnd==false)
        counter=i;
        isStart=true;
    end
    % sprawdzic ponowne wykrywanie twarzy! !!!!!!!! TUTAJ ZMIENIÆ!!!! na
    % ostatni¹ wersjê z tym <0.25!!!!!!!!!!!!!!!!!!
    
    if(i>counter+60 && abs((abs((SUMA(i)))-abs((SUMA(i-2)))))<2 && isStart==true && isEnd==false)
       %if(i>counter+60 && abs(SUMA(i))<0.5 && isStart==true && isEnd==false) %norma
     %if(abs(SUMA(i))<2 && isStart==true) % wolne   
        isEnd=true;
        ending=i;
        
        howMuchFrame=ending-counter;
        timeOfRound=howMuchFrame/30;%round((howMuchFrame/30)+0.1,1);
    end
    
%     counter=counter+1;
%     if (rem(i, 50)==0)
%         points = detectMinEigenFeatures(FRAMES{i}, 'MinQuality', 0.4, 'ROI', positionOfBody);
%         tracker.release();
%         tracker.initialize(points.Location, FRAMES{i});
%         oldpoints = points.Location;
%     end
%     
end
end