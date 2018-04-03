function [structure] = Fun_FindEyeNoseMouth(FRAMES,structure, positionOfBody)

mouthDetector=vision.CascadeObjectDetector('Mouth','MergeThreshold',16,'UseROI',true);
eyeDetector=vision.CascadeObjectDetector('EyePairSmall','UseROI',true);
noseDetector=vision.CascadeObjectDetector('Nose','UseROI',true);

count=size(structure.Frames,2);

for i=1:count

     frame=FRAMES{i};
    
    bboxesMouth=step(mouthDetector,frame,positionOfBody);
    structure.FrameWithMarker{i}=insertShape(frame,'Rectangle',bboxesMouth);
    
    bboxesEye=step(eyeDetector,frame, positionOfBody);
    structure.FrameWithMarker{i}=insertShape(frame,'Rectangle',bboxesEye);
    
    bboxesNose=step(noseDetector,frame, positionOfBody);
    structure.FrameWithMarker{i}=insertShape(frame,'Rectangle',bboxesNose);
end
end