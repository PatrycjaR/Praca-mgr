function [timeOfRound, howMuchFrame]=TurningSUM(SUMAfilter, IsFaceFilter, countOfFrames)

isStart=false;
isEnd=false;
counter=1;

    for i=1:countOfFrames
        
   % detekcja pocz¹tku obrotu

   
	if(30+i<countOfFrames && (SUMAfilter(i)+SUMAfilter(i+30)<0) &&  isStart==false && isEnd==false) %zobaczyc jak wyglada SUMA po filtracji, jak sie zmieniaja wzajemnie wartoœci, sprawdziæ wiêksze okno dla sumy
		counter=i-9;
		isStart=true;
	end


% koniec pierwszego obrotu

%koniec obrotu

	if(i+15<countOfFrames && 0<(abs(SUMAfilter(i+15))-abs(SUMAfilter(i)))&& (abs(SUMAfilter(i+15))-abs(SUMAfilter(i)))<0.01 && counter+150<i && isStart==true && isEnd==false )
        isEnd=true;
		ending=i+9;
		%howMuchFrame=((endignFirstTurn-counter)+(ending-secondTurn));
        %	timeOfRoundPaus=howMuchFrame/30;%round((howMuchFrame/30)+0.1,1);
        howMuchFrame=ending-counter;    
        timeOfRound=(ending-counter)/50;
	end    
        
    end
    
    if (~exist('timeOfRound','var'))
    [timeOfRound, howMuchFrame]=OneTurn(SUMAfilter, IsFaceFilter, countOfFrames);  
    end
end
%profile off
%disp('debug');
%plot(movmean(SUMA, 25))


%find(ISFACEpoFiltrowaniu==0, 'last') -> ostatnie znikniÄ™cie twarzy  itp.
% 
% SUMA(~ISFACE) = 0;