%TODO: IDENTIFIKACIA NA ZAKLADE ROZMIESTNENIA (ZAHODIT OUTLIERY)
%TODO: IDENTIFIKACIA FARIEB
%YUV, HSV?

function rubik(I)

    figure, imshow(I);
    
    BW = getBWimage(I);
    %figure, imshow(BW);
    
    Ilbl = getLabels(I, BW);
    figure, imshow(Ilbl);
    
end