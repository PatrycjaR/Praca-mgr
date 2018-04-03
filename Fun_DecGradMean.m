function [SumDec]=Fun_DecGradMean(SUM)

grad=gradient(SUM);
dec=decimate(grad,10);
SumDec=movmean(dec,3);

end