function [timeOfRound, howMuchFrame]=OneTurn(SUMAfilter,IsFaceFilter, countOfFrames)

isStart=false;
isEnd=false;
FirstTurn=false;
begin=false;

for i = 1 : countOfFrames

   % detekcja pocz¹tku obrotu

   if(IsFaceFilter(i)==1 && isStart==false)
       begin=true;
   end
   
	if(IsFaceFilter(i)~=1 && begin==true && isStart==false && isEnd==false && FirstTurn==false ) %zobaczyc jak wyglada SUMA po filtracji, jak sie zmieniaja wzajemnie wartoœci, sprawdziæ wiêksze okno dla sumy
		counter=i-9;
		isStart=true;
	end
    

    
%koniec obrotu

	if(IsFaceFilter(i)==1 && isEnd==false && isStart==true)
        isEnd=true;
		ending=i+9;
		%howMuchFrame=((endignFirstTurn-counter)+(ending-secondTurn));
        %	timeOfRoundPaus=howMuchFrame/30;%round((howMuchFrame/30)+0.1,1);
        howMuchFrame=ending-counter;    
        timeOfRound=(ending-counter)/50;
	end    

end

if (~exist('timeOfRound','var'))
    timeOfRound=0;
    howMuchFrame=0;
end
end