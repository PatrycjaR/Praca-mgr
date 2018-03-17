clear all; clc; close all;

dirSmall = 'C:\Users\promaniszyn\Mgr\male\720';

dirNormal='C:\Users\promaniszyn\Mgr\filmy';

fileSmall = dir(dirSmall);
fileNormal=dir(dirNormal);

vr = '2';

for i = 1 : length(fileSmall)
   if (isempty(regexp(fileSmall(i).name, '.mp4$', 'once')) || isempty(regexp(fileNormal(i).name, '.mp4$', 'once')))
       continue;
   end
   
   if (regexp(fileSmall(i).name, '.mp4$', 'once') && regexp(fileNormal(i).name, '.mp4$', 'once' ))
       fnSmall = fileSmall(i).name;
       fnNormal=fileNormal(i).name;
     
       fun_test360(fnSmall, vr, dirSmall);
       disp('aaa');
   end
   
   %dla ka¿dego filmu muszê mieæ + 1. .mat z zapisanimi w strukturze +
   %informacjami; 2. filmik z na³o¿onymi markerami- wszystkimi jakie siê da +
   %fnMaly = [fn '780x980.mp4']; 
       
   
   %v{i} = przetwarzaj(fn, version, ...)
  
   % 1. ponanosic wszystko co sie da na kazda klatke, a pozniej zlozyc z tego +
   % filmik. wszystko zapisywac do danego katalogu, ze zmieniona nazwa. +
   % 2. do mata zapisac istotne rzeczy, w sensie klatki, polozenie twarzy na
   % danej klatce, polozenie ciala, polozenie markerów itp. +
   % 3. sprawdziæ kierunek ruchu, czy zawsze porusza sie poprawnie;
   % sprawdzac czy nie ma ruchow w inna strone niz jest, okreslic kierunek
   % ruchu na podstawie jakiegos kryterium np z pierwszych 15 ramek (wziac
   % np. kwantyl)- na filmiku patrzec jaki marker w ktora strone sie zaczal
   % ruch
   
   % najwazniejsze !! wizualizacja markerów! i zobaczyc czy na twarzy jest
   % ROI (czy sa markery, np oczy albo cos)
end