%TODO: ZISTIT CI JE NAJDENY KOMPONENT CCA STVOREC
%TODO: IDENTIFIKACIA NA ZAKLADE ROZMIESTNENIA (ZAHODIT OUTLIERS)
%TODO: IDENTIFIKACIA FARIEB
%YUV, HSV?

function rubik(img)

    figure, imshow(img);

    %BW obrazky z jednotlivych zloziek
    R = im2bw(img(:,:,1), .1);
    G = im2bw(img(:,:,2), .1);
    B = im2bw(img(:,:,3), .1);
    R = imerode(R, ones(3));
    G = imerode(G, ones(3));
    B = imerode(B, ones(3));
    %imshow(R); figure; imshow(G); figure; imshow(B);
    %prienik BW obrazkov
    I = max(R,max(G,B));
    
    %hrany z jednotlivych zloziek
    ER = imcomplement(edge(img(:,:,1)));
    EG = imcomplement(edge(img(:,:,2)));
    EB = imcomplement(edge(img(:,:,3)));
    ER = imerode(ER, ones(3));
    EG = imerode(EG, ones(3));
    EB = imerode(EB, ones(3));
    
    %imshow(ER); figure; imshow(EG); figure; imshow(EB);
    %zjednotenie s hranami
    I(ER==0) = 0;
    I(EG==0) = 0;
    I(EB==0) = 0;
    
    I = imerode(I, ones(3));
    %figure, imshow(I);
    
    [xsz ysz ~] = size(img);
    pxcnt = xsz*ysz;
    %najdeme komponenty a ich vlastnosti
    components = bwconncomp(I);
    prop = regionprops(components,'EulerNumber','PixelList','Solidity','MinorAxisLength','MajorAxisLength','BoundingBox','Centroid','Extrema');
    %obrazok s najdenymi labelami kocky
    Ilbl = ones(size(img));
    
    %prejdeme vsetky komponenty BW obrazku
    for i=1:length(prop)
        
        %pixely komponentu
        pixels = prop(i).PixelList;
        [n ~] = size(pixels);
        relativeSize = n/pxcnt;
        axisRatio = prop(i).MinorAxisLength/prop(i).MajorAxisLength;
        box = prop(i).BoundingBox;
        onBorder = box(2) < xsz/15 || box(1) < ysz/15 || box(2)+box(4) > 14*xsz/15 || box(1)+box(3) > 14*ysz/15;
        
        %komponent je dobry ak:
        %-nie je na okraji obrazku
        %-nie je prilis splosteny
        %-dostatocne vyplna svoj konvexny obal
        %-nie je prilis deravy
        %-nie je prilis velky
        %-nie je prilis maly
        if (~onBorder && axisRatio>.15 && prop(i).Solidity>.75 && prop(i).EulerNumber>=0 && relativeSize<.03 && n>100)
            %skopirujeme caasti kocky z povodneho obrazku
            for j=1:n
                 Ilbl(pixels(j,2),pixels(j,1),:) = img(pixels(j,2),pixels(j,1),:);
            end
            
            %najdeme okraje
            bounds = bwtraceboundary(I,[round(prop(i).Extrema(1,2)) round(prop(i).Extrema(1,1))],'N');
            for j=1:length(bounds)
                Ilbl(bounds(j,1),bounds(j,2),:) = 255;
            end
        end
        
    end

    figure, imshow(uint8(Ilbl));
    
end