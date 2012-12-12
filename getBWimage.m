%vrati BW obrazok s odseparovanymi, uzavretymi oblastami predstavujucimi
%stvorceky na kocke.
function [BW] = getBWimage(I)

    BW_TRESHOLD = .1;
    ERODE_SIZE = 3;
    
    [xsz ysz ~] = size(I);

    %BW = prienik BW verzii jednotlivych farebnych zloziek R,G,B;
    %E = zjednotenie hran jednotlivych zloziek;
    %vysledok je zjednotenie BW a E
    BW = zeros(xsz,ysz);
    E = ones(xsz,ysz);
    
    %jednotlive farebne zlozky obrazku
    for i=1:3
        %erodovana BW zlozka
        tmp = im2bw(I(:,:,i), BW_TRESHOLD);
        tmp = imerode(tmp, ones(ERODE_SIZE));
        %figure, imshow(tmp);
        %prienik ciernych casti zloziek
        BW = max(BW,tmp);
        %erodovane hrany zlozky
        tmp = edge(I(:,:,i));
        tmp = imerode(imcomplement(tmp), ones(ERODE_SIZE));
        %figure, imshow(tmp);
        %zjednotenie hran
        E = min(E,tmp);
    end
    
    %figure, imshow(BW);
    %figure, imshow(E);
    
    %zjednotenie a erozia hran a BW zloziek
    BW = min(BW,E);
    BW = imerode(BW, ones(ERODE_SIZE));
    
end