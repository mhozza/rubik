%TODO: IDENTIFIKACIA NA ZAKLADE ROZMIESTNENIA (ZAHODIT OUTLIERY)
%TODO: IDENTIFIKACIA FARIEB
%YUV, HSV?

function rubik(I)

    figure, imshow(I);
    
    BW = getBWimage(I);
    %figure, imshow(BW);
    
    [Ilbl colors] = getLabels(I, BW);
    figure, imshow(Ilbl);

    colors
    G=group_colors(colors);
    for i=1:length(G)
        G{i}
    end
end