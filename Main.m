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
   
end