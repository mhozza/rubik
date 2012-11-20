%pokus a iny sposob hladania komponentov, vhodny pre niektore obrazky s
%mensou a menej detailnou kockou.
%tu sa da este nieco vylepsit
function [BW] = getBWimage2(I)

    BW_TRESHOLD = .1;
    ERODE_SIZE = 3;
    
    %BW = imerode(im2bw(I, BW_TRESHOLD), ones(ERODE_SIZE));
    %figure, imshow(BW);
    BW =  imerode(imcomplement(edge(rgb2gray(I))), ones(ERODE_SIZE));
    %E =  imerode(imcomplement(edge(rgb2gray(I))), ones(ERODE_SIZE));
    %figure, imshow(E);
    %BW = imerode(min(BW,E), ones(ERODE_SIZE));
    
end