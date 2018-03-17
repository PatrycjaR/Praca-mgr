function [positionOfBody]=Fun_PositionOfBody(mask)

prog=max(mask(:))/2;

mask2 = mask > prog;

L = bwlabeln(mask2);


gdzieMax = unique(L(mask == max(mask(:))));
if (length(gdzieMax) > 1)
    error('za duzo regionow');
end
L = L == gdzieMax;

region=regionprops(L, 'BoundingBox');

ecc = cell2mat({region.BoundingBox});

% rozci�ganie 3x na boki i 9x na d�ugo��
ecc(1) = ecc(1) - ecc(3);
ecc(3) = 3*ecc(3);
ecc(2) = ecc(2) - ecc(4);
ecc(4) = ecc(4) * 9;

ColRow = nan([1 4]);
ColRow(1:2) = ceil(ecc(1:2));
ColRow(3:4) = (ecc(3:4) + ecc(1:2)) - 1;

ColRow(1:2) = max(ColRow(1:2), [1 1]);
ColRow(3:4) = min([size(mask, 2), size(mask, 1)], ColRow(3:4));

positionOfBody = ColRow;
positionOfBody(3:4) = ColRow(3:4)-ColRow(1:2)+1;


