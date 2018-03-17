function [mask, structure] = Fun_FindFaceAndBody(FRAMES, structure)

countOfFrames = length(FRAMES);

faceDetector = vision.CascadeObjectDetector('FrontalFaceLBP');
mouthDetector=vision.CascadeObjectDetector('Mouth','MergeThreshold',16);
eyeDetector=vision.CascadeObjectDetector('EyePairSmall');
noseDetector=vision.CascadeObjectDetector('Nose');
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
    
    bboxes=step(faceDetector,frame); % pierwsza wsp�rz�dna to x, druga to y, 3 szeroko��, 4 d�ugo�� (albo odwrotnie)
    structure.Face{i}=bboxes;
    structure.FrameWithMarker{i}=insertShape(frame,'Rectangle',bboxes);

    bboxesMouth=step(mouthDetector,frame);
    structure.FrameWithMarker{i}=insertShape(frame,'Rectangle',bboxesMouth);
    
    bboxesEye=step(eyeDetector,frame);
    structure.FrameWithMarker{i}=insertShape(frame,'Rectangle',bboxesEye);
    
    bboxesNose=step(noseDetector,frame);
    structure.FrameWithMarker{i}=insertShape(frame,'Rectangle',bboxesNose);
    
    if(isempty(bboxes))
       continue
    end
%     
    %zeby znalezc gdzie do danej chwili najczesciej zostala wykryta twarz
    %moge uzyc takze aaa=mask>=max(max(mask())) i tutaj mam obraz logiczny,
    %gdzie wartosc 1 wystepuje mi tylko tam, gdzie mam te max  (sugestia:
    %moge zrobic max-10, bede miala wiekszy obszar); w nastepnym kroku
    %powinnam miec [rowsOfMaxes colsOfMaxes] = find(aaa == 1)- wtedy mam
    % dokladne indeksy tego; a pozniej jak chce ograniczyc ten obszar to
    % daje tylko plot(rowsOfMaxes(1),colsOfMaxes(1),'r*')  i tam -3*srednia
    % ilosc pikseli w znalezionym obszarze itp.
    
%     rois = [bboxes(:, 1) bboxes(:, 2) (bboxes(:, 1)+bboxes(:,3)) (bboxes(:, 2) + bboxes(:, 4))];
    for j = 1 : size(bboxes, 1)
        bb = bboxes(j, :);
%         roi = rois(j, :);
        bbC = [max(1, (bb(1)-bb(3)))  bb(2)  ...
            (3*bb(3))  (9*bb(4))];
        if (bbC(3)+bbC(1) > size(mask, 2))
            bbC(3) = size(mask, 2) - bbC(1);
        end
        if (bbC(4)+bbC(2) > size(mask, 1))
            bbC(4) = size(mask, 1) - bbC(2);
        end
        % do structure biore bboxes i bbc!
        indR = bb(2):(bb(2)+bb(4));
        indRC = bbC(2):(bbC(2)+bbC(4));
        indC = bb(1):(bb(1)+bb(3));
        indCC = bbC(1):(bbC(1)+bbC(3));
        mask(indR, indC) = mask(indR, indC) + 1;
        maskC(indRC, indCC) = maskC(indRC, indCC) + 1;
    end
    structure.Body{i}=bbC;
    fWm=structure.FrameWithMarker{i};
    structure.FrameWithMarker{i}=insertShape(structure.FrameWithMarker{i},'Rectangle',bbC);
%     L = bwlabeln(mask);
%     region=regionprops(L,'BoundingBox');
%     
%     ecc = cell2mat({region.BoundingBox});
    
    
end

%jezeli wezme region.boudningbox to otrzymam x,y,wys i szeroko�� obszaru,
%gdzie najczesciej byla znajdowana twarz w analizwanych do tej pory
%klatkach. zeby sie do tego dostac musze zrobic a=region.boundingbox, wtedy
%wrzucaja mi sie te wartosci do tablicy i wtedy moge sie do nich odwolywac,
%np a(1,1) itd

end