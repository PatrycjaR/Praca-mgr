function [mask, structure] = Fun_FindBody(FRAMES, structure)

countOfFrames = length(FRAMES);

% faceDetector = vision.CascadeObjectDetector('FrontalFaceLBP');

peopleDetector = vision.PeopleDetector('MergeDetections', false);
 peopleDetector = peopleDetectorACF('inria-100x41'); %'caltech-50x21');

mask = [];

% poszukiwanie twarzy na kazdej ramce- region najczestszych znalezionych
% twarzy
i = 0;
while(i<countOfFrames)
    
    i = i + 1;
    fprintf(1, 'ramka %d z %d\n', i, countOfFrames);
    frame=FRAMES{i};
    
    if (isempty(mask))
        mask = zeros([size(frame, 1), size(frame, 2)]);
        maskC = zeros(size(mask));
    end
    
    bboxes=step(peopleDetector,frame); % pierwsza wspï¿½rzï¿½dna to x, druga to y, 3 szerokoï¿½ï¿½, 4 dï¿½ugoï¿½ï¿½ (albo odwrotnie)
    structure.Body{i}=bboxes;
    
    %dodanie na FRAMES pozycji ciala
    
    
    if(isempty(bboxes))
        continue
    end
    
    structure.FrameWithMarker{i}=insertShape(frame, 'Rectangle', bboxes);
    
    % wykonanie równoleg³e
    faceDetector = parallel.pool.Constant(@() vision.CascadeObjectDetector); %,@fclose);
    peopleDetector = parallel.pool.Constant(@() peopleDetectorACF('inria-100x41'));
%   
    parfor i = 1 : countOfFrames
        fprintf(1, '%i\n', i);
        frame = FRAMES{i};
        BBOXESface{i} = faceDetector.Value.step(histeq(frame));
        BBOXESshape{i} = peopleDetector.Value.detect(frame);
    end
    
%     rois = [bboxes(:, 1) bboxes(:, 2) (bboxes(:, 1)+bboxes(:,3)) (bboxes(:, 2) + bboxes(:, 4))];
    for j = 1 : size(bboxes, 1)
        bb = bboxes(j, :);
%         roi = rois(j, :);
        bbC = [max(1, (bb(1)-bb(3)))  bb(2)  ...
            (bb(3))  (bb(4))];
        if (bbC(3)+bbC(1) > size(mask, 2))
            bbC(3) = size(mask, 2) - bbC(1);
        end
        if (bbC(4)+bbC(2) > size(mask, 1))
            bbC(4) = size(mask, 1) - bbC(2);
        end
        
        indR = bb(2):(bb(2)+bb(4))-1;
        indRC = bbC(2):(bbC(2)+bbC(4))-1;
        indC = bb(1):(bb(1)+bb(3))-1;
        indCC = bbC(1):(bbC(1)+bbC(3))-1;
        mask(indR, indC) = mask(indR, indC) + 1;
        maskC(indRC, indCC) = maskC(indRC, indCC) + 1;
    end
    
    L = bwlabeln(mask);
    region=regionprops(L,'BoundingBox');
    
    ecc = cell2mat({region.BoundingBox});
    
    
end

%jezeli wezme region.boudningbox to otrzymam x,y,wys i szerokoï¿½ï¿½ obszaru,
%gdzie najczesciej byla znajdowana twarz w analizwanych do tej pory
%klatkach. zeby sie do tego dostac musze zrobic a=region.boundingbox, wtedy
%wrzucaja mi sie te wartosci do tablicy i wtedy moge sie do nich odwolywac,
%np a(1,1) itd

end