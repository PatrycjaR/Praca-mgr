close all; clear all; clc;
%% wczytywanie filmu
%%dla szybkiego
fn = 'szybko6.mp4';

%%[FRAMES, countOfFrames]=ReadAndSave(fn);

reader = vision.VideoFileReader(fn, 'ImageColorSpace', 'Intensity');
%
% sprawdzenie iloï¿½ci ramek w filmie
countOfFrames = 0;
FRAMES = cell([1 1000]);
while ~isDone(reader)
    countOfFrames = countOfFrames + 1;
    FRAMES{countOfFrames} = imrotate(reader.step(),-90);
end
FRAMES = FRAMES(1:countOfFrames);
%
faceDetector = vision.CascadeObjectDetector();
%


% zapis ramek do m. pliku
%save('ramki.mat', 'FRAMES');
reader = vision.VideoFileReader(fn, 'ImageColorSpace', 'Intensity');
FRAMES = cell([1 countOfFrames]);
for i=1:countOfFrames
    f=reader.step();
    f1=step(reader);
    %f=imrotate(f1,-90);
    FRAMES{i} =f;
end

% poszukiwanie ciala i twarzy

mask = [];
%mask=FindFaceAndBody(FRAMES, countOfFrames)

% poszukiwanie twarzy na kazdej ramce- region najczï¿½stszych znalezionych
% twarzy
i=1;
while(i<countOfFrames)
    frame=FRAMES{1, i};
    if (isempty(mask))
        mask = zeros([size(frame, 1), size(frame, 2)]);
        maskC = zeros(size(mask));
    end
    
    bboxes=step(faceDetector,frame); % co mi zwraca tu??
    rois = [bboxes(:, 1) bboxes(:, 2) (bboxes(:, 1)+bboxes(:,3)) (bboxes(:, 2) + bboxes(:, 4))];
    for j = 1 : size(bboxes, 1)
        bb = bboxes(j, :);
        roi = rois(j, :);
        bbC = [max(1, (bb(1)-bb(3)))  bb(2)  ...
            (3*bb(3))  (9*bb(4))];
        if (bbC(3)+bbC(1) > size(mask, 2))
            bbC(3) = size(mask, 2) - bbC(1);
        end
        if (bbC(4)+bbC(2) > size(mask, 1))
            bbC(4) = size(mask, 1) - bbC(2);
        end
        
        indR = bb(2):(bb(2)+bb(4));
        indRC = bbC(2):(bbC(2)+bbC(4));
        indC = bb(1):(bb(1)+bb(3));
        indCC = bbC(1):(bbC(1)+bbC(3));
        mask(indR, indC) = mask(indR, indC) + 1;
        maskC(indRC, indCC) = maskC(indRC, indCC) + 1;
    end
    
    [L,n] = bwlabeln(mask);
    region=regionprops(L,'BoundingBox');
    
    ecc = cell2mat({region.BoundingBox});
    
    i = i + 1;
end

% poszukiwanie miejsca, gdzie najczesciej zostaï¿½a znaleziona twarz
prog=max(mask(:))/2;

mask = mask > prog;

% for w=1:size(mask,1)
%     for k=1:size(mask,2)
%         
%         if mask(w,k)>prog
%             mask(w,k)=1;
%         else mask(w,k)=0;
%         end
%         
%     end
% end
% etykietowanie znaleziska
[L,n] = bwlabeln(mask);
region=regionprops(L,'BoundingBox');
ecc = cell2mat({region.BoundingBox});

% rozciï¿½ganie 3x na boki i 9x na dï¿½ugoï¿½ï¿½
xBeginBody=ecc(1,1)-ecc(1,3);
yBeginBody=ecc(1,2)+9*ecc(1,4);
y=ecc(1,2);
maxWidth=9*ecc(1,4);

if maxWidth+xBeginBody>size(FRAMES{1,1},1)
    maxWidth=size(FRAMES{1,1},1)-xBeginBody-10;
end
if y+maxWidth>size(FRAMES{1,1},1)
    maxWidth=size(FRAMES{1,1},1)-y-10;
end

positionOfBody=[xBeginBody y 3*ecc(1,3) maxWidth-1];
sizeOfFrames=size(FRAMES{1,1},1);
%positionOfBody=PositionOfBody(mask, sizeOfFrames)

%wyciecie tylko poszczegolnych elementow w obrazie
%poszukiwanie punktow poruszajacych sie na obrazie
i=1;
%
tracker = vision.PointTracker;
points = detectMinEigenFeatures(FRAMES{1}, 'MinQuality', 0.4, 'ROI', positionOfBody);
tracker.initialize(points.Location, FRAMES{1});

oldpoints = points.Location;

player = vision.VideoPlayer('Position', [0 0 size(FRAMES{1}, 2), size(FRAMES{1}, 1)]);

counter=1;
isStart=false;
isEnd=false;
ending=0;

SUMA = zeros([1 countOfFrames]);
% SUMA = zeros([1 270]);

for i = 1:countOfFrames
    
    
    
    fprintf(1, '.');
    [np, v] = tracker.step(FRAMES{i});
    
    roznica = np - oldpoints;
    roznica(~v, :) = [];
    if (isempty(roznica))
        error('... error ...');
    end
    
    roznicaX = roznica(:, 1); %x-y
    [~, I] = sort(abs(roznicaX), 'descend');
    
   
    % 1 - najwiêkszy 
    SUMA(i) = sum(roznicaX(I(1:5)));
    
    
    f = FRAMES{i};
    nn = [oldpoints np];
    nn(~v, :) = [];
    
    f = insertShape(f, 'Line', nn);
    
    
%     player.step(f);

    %imshow(f)
    hold on
    plot(oldpoints(:,1),oldpoints(:,2),'*r')
    
    oldpoints = np;

    if (i>2 && abs(round(SUMA(i)))-abs(round(SUMA(i-2)))>0.5 && isStart==false && isEnd==false)
        counter=i;
        isStart=true;
    end
    % sprawdzic ponowne wykrywanie twarzy! !!!!!!!! TUTAJ ZMIENIÆ!!!! na
    % ostatni¹ wersjê z tym <0.25!!!!!!!!!!!!!!!!!!
    
    if(i>counter+60 && abs((abs((SUMA(i)))-abs((SUMA(i-2)))))<2 && isStart==true && isEnd==false)
       %if(i>counter+60 && abs(SUMA(i))<0.5 && isStart==true && isEnd==false) %norma
%      if(abs(SUMA(i))<2 && isStart==true) % wolne   
        isEnd=true;
        ending=i;
        
        howMuchFrame=ending-counter;
        timeOfRound=howMuchFrame/30;
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

%[timeOfRound, howMuchFrame1]=TurningTime(FRAMES, positionOfBody);
X=['Policzy³em do ', num2str(timeOfRound), ' sekund.']
        disp(X)
        
%         roznica pomiedzy howMuchFrame1, a 2 z drugiego obrotu bedzie
%         czasem pauzy wykonanej pomiedzy obrotami
%%

% t = timer('TimerFcn', 'stat=false; disp(''Timer!'')',... 
%                  'StartDelay',0);
%  stat=true;
%  timeBegin=false;
%  ile=0;
% tracker = vision.PointTracker;
% fr= imcrop(FRAMES{1,1},[positionOfBody(1,1) positionOfBody(1,2) positionOfBody(1,3) positionOfBody(1,4) ]);
% points = detectMinEigenFeatures(fr, 'MinQuality', 0.5); %, %, 'ROI', objectRegion);
% tracker.initialize(points.Location, fr );
% 
% oldpoints1 = points.Location;
% oldpoints = points.Location;
% rrr=zeros(countOfFrames,1);
% roznica=zeros(1,countOfFrames);
%%
% while(i<countOfFrames)
%     %
%     %     while ~isDone(videoFileReader)
%     %       frame = step(videoFileReader);
%     %       [points, validity] = step(tracker,frame);
%     %       out = insertMarker(frame,points(validity, :),'+');
%     %       step(videoPlayer,out);
%     % end
%     
%     
%     f=FRAMES{1,i};
%     fr= imcrop(f,[positionOfBody(1,1) positionOfBody(1,2) positionOfBody(1,3) positionOfBody(1,4) ]);
%     
%     %     points = detectMinEigenFeatures(fr, 'MinQuality', 0.5); %, %, 'ROI', objectRegion);
%     
%     
%     
%     %     tracker.initialize(points.Location, fr );
%     
%     %     oldpoints = points.Location;
%     [np, v] = tracker.step(fr);
%     
%     
%     roznica = oldpoints - np;
%     roznica(~v, :) = [];
%     if (isempty(roznica))
%         disp('koniec punktow');
%         
%     end
%     roznicaX = sum(roznica(:, 1));
%     
%     
%     imshow(fr);
%     hold on;
%     plot(oldpoints(:,1),oldpoints(:,2),'.r');
%     hold on;
%     plot(np(:,1), np(:,2), '.b');
%     hold off;
% %     pause();
%     if(size(oldpoints,1)~=size(np,1))
%         disp('Nieee...');
%     end
%     roznica = oldpoints - np; 
%     roznica2=oldpoints1-oldpoints;
%     suma2=abs(sum(roznica2(:,1)));
%     sumaRoznicy=abs(sum(roznica(:,1)));
%     fprintf('Rï¿½nica %d ...',sumaRoznicy);
%     fprintf('Rï¿½nica2 %d \n',suma2);
%     
%     if (suma2>98)
%         start(t)
%         timeBegin=true;
%     end
%     if (timeBegin==true)
%          ile=ile+1;
%             %pause(1)
%     end
%     rrr(i)=sumaRoznicy;
%     re = roznica(:, 1);
%     im = roznica(:, 2);
%     cale = re + 1j*im;
%     angle(cale);
%     roznica(~v, :) = [];
%     
%     oldpoints = np;
%     
%     
%     i=i+1;
%     
% end
% stat=false;
% ile=ile/30;
% 
%         X=['Policzyï¿½em do ', num2str(ile), ' sekund.']
%         disp(X)
% wycinanie tylko potrzebnego obszaru mozna zrobic
% r=imcrop(ramka,[positionOfBody(1,1) positionOfBody(1,2) positionOfBody(1,3) positionOfBody(1,4) ]);

% points = detectMinEigenFeatures(r, 'MinQuality', 0.5); %, %, 'ROI', objectRegion);
% % imshow(d, []); hold on; plot(points.Location(:, 1), points.Location(:, 2))
% r=imcrop(ramka,[positionOfBody(1,1) positionOfBody(1,2) positionOfBody(1,3) positionOfBody(1,4) ]);
%  plot(oldpoints(:,1), oldpoints(:, 2), '.r')
%
% tracker = vision.PointTracker;
% tracker.initialize(points.Location, r);
% oldpoints = points.Location;
% %
% while ~reader.isDone
%     frame = reader.step();
%     [np, v] = tracker.step(r);
%
%     roznica = oldpoints - np;
%
%     re = roznica(:, 1);
%     im = roznica(:, 2);
%     cale = re + 1j*im;
%     angle(cale);
%     roznica(~v, :) = [];
%
%     oldpoints = np;
% end


% notatki!! w poszczegolnych funkcjach zobacz co pisalas; kolejnym krokiem
% jest dokonanie podzialu, a mianowicie: po pierwszym obrocie program Ci
% sie wylaczy, bo uzna ze znalazl obrot i drugiego nie bedzie analizowal,
% dlatego trzeba znowu uruchomic w ODPOWIEDNIM momencie turningTime, ale z
% podanymi pozycjami dla twarzy, nie dla calego ciala; bedac w funkcji
% position of body tam ustalasz pozycje ciala, postaraj sie ustalic tez
% pozycjé samej twarzy, zeby w tym koeljnym kroku wiedzial, gdzie ma tylko
% szukac twarzy- ponowne znalezienie twarzy bedzie u nas drugim obrotem-
% jakos to musisz polaczyc- KONIECZNIE!!!
