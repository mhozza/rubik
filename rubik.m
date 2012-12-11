function rubik(I)

%algoritmus outline
%-najdeme BW obrazok s uzavretymi oblastami
%-zistime, ktore oblasti su dobre
%-dodatocne vyhodime zle oblasti na zaklade ich vzajomnych vztahov
%-mame uz priradene stvorceky k stranam, opravime ak su zle priradenia
%-najdeme osi stran kocky
%-natiahneme osi cez centroidy stvorcekov a ziskame mriezku, ktora bude
%prechadzat aj chybajucimi stvorcekami
%-prejdeme najdene priesecniky osi a ziskame chybajuce stvorceky
%-zistime, v akom poradi maju ist

figure, imshow(I);

BW = getBWimage(I);
%figure, imshow(BW);

[pixelList boundsList centroids colors] = getLabels(I, BW);

%tazky hack, matlabu drbe a ked len spravim zeros(size(I)), mysli si ze
%to je nejaky iny color model (ktory ani neexistuje)
img = I;
img(:,:,:) = 0;

%pocet labelov
n = length(pixelList);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     % pokus s farbami
%
%     LAB_DIST = 15;
%
%     %drbneme farby do 1 x n x 3 pola, lebo to tak rgb2lab funkcia chce
%     tmp = zeros(1,n,3);
%     for i=1:n
%         tmp(1,i,:) = colors(i,:);
%     end
%     lab = RGB2Lab(tmp);
%     %zoznam podobnych labelov ku kazdemu labelu
%     similar = {};
%
%     for i=1:n
%         similar{end+1} = [];
%         for j=1:n
%             if (i~=j)
%                 dist = sqrt( (lab(1,i,1)-lab(1,j,1))^2 + (lab(1,i,2)-lab(1,j,2))^2 + (lab(1,i,3)-lab(1,j,3))^2);
%                 if (dist<LAB_DIST)
%                    similar{i}(end+1) = j;
%                 end
%                 strcat({'LAB distance '},num2str(i),{'-'},num2str(j),{': '},num2str(dist))
%                 %strcat({'RGB  '},num2str(tmp(1,i,1)),{' '},num2str(tmp(1,i,2)),{' '},num2str(tmp(1,i,3)),{' '},...
%                 %    num2str(tmp(1,j,1)),{' '},num2str(tmp(1,j,2)),{' '},num2str(tmp(1,j,3)),{' '})
%
%             end
%         end
%     end
%
%     for i=1:n
%         i
%        similar{i}
%     end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%velkosti labelov (poc. pixelov) a najblizsia vzdialenost labelu k inemu
sizes = 1:n;
closestDist = 1:n;
for i=1:n
    sizes(i) = length(pixelList{i});
    closestDist(i) = 10^9;
    for j=1:n
        if (i~=j)
            closestDist(i) = min(closestDist(i), dist(centroids(i,:), centroids(j,:)));
        end
    end
end
medSize = median(sizes);
medDist = median(closestDist);

%na ktoru stranu kocku label patri
sides = [];
%rohy labelov
UL = []; DL = []; UR = []; DR = [];
%zoznamy na labely ktore akceptujeme
pixelListTmp = {};
boundsListTmp = {};
centroidsTmp = [];
colorsTmp = [];


for i=1:n
    
    %berieme len nieco vhodne velke a vhodne blizko k ostatnym
    if (sizes(i) > medSize/3 && sizes(i) < medSize*3 &&...
            closestDist(i) < 3*medDist && closestDist(i) > medDist/3)
        
        for j=1:length(pixelList{i})
            img(pixelList{i}(j,1),pixelList{i}(j,2),:) = colors(i,:);
        end
        for j=1:length(boundsList{i})
            img(boundsList{i}(j,1),boundsList{i}(j,2),:) = [255 255 255];
        end
        
        [side ul dl ur dr] = getLabelSide(boundsList{i}, sqrt(length(pixelList{i})));
%         img = krizik(img, ul(1),ul(2),[255 0 0]);
%         img = krizik(img, dl(1),dl(2),[0 255 0]);
%         img = krizik(img, ur(1),ur(2),[0 0 255]);
%         img = krizik(img, dr(1),dr(2),[255 255 255]);
        
        UL(end+1,:) = ul;
        DL(end+1,:) = dl;
        UR(end+1,:) = ur;
        DR(end+1,:) = dr;
        sides(end+1) = side;
        
        pixelListTmp{end+1} = pixelList{i};
        boundsListTmp{end+1} = boundsList{i};
        centroidsTmp(end+1,:) = centroids(i,:);
        colorsTmp(end+1,:) = colors(i,:);
        
    end
end


n = length(sides);
colors = colorsTmp;
centroids = centroidsTmp;
boundsList = boundsListTmp;
pixelList = pixelListTmp;

%vsetky centroidy pre lavu a pravu stenu
YL = [];
YR = [];
XL = [];
XR = [];

for i=1:n
    if (sides(i)==1)
        YL(end+1) = centroids(i,1);
        XL(end+1) = centroids(i,2);
    end
    if (sides(i)==2)
        YR(end+1) = centroids(i,1);
        XR(end+1) = centroids(i,2);
    end
end

%priblizny stred L a R steny
medYL = median(YL);
medXL = median(XL);
medYR = median(YR);
medXR = median(XR);

%pocty labelov na stranach
cntL = 0;
cntR = 0;
cntU = 0;

%ked je prilis daleko od svojej steny, priradime mu spravnu
for i=1:n
    if (centroids(i,1) > medYL && centroids(i,2) < medYL)
        sides(i) = 1;
    end
    if (centroids(i,1) > medYR && centroids(i,2) > medXR)
        sides(i) = 2;
    end
    %nakreslime na obrazok pismenka k labelom
    text = 'X';
    if (sides(i)==1)
        cntL = cntL + 1;
        text = 'L';
    end
    if (sides(i)==2)
        text = 'R';
        cntR = cntR + 1;
    end
    if (sides(i)==3)
        text = 'U';
        cntU = cntU + 1;
    end
    txtInserter = vision.TextInserter(strcat(text),'Color',[0 0 0],'Location',[centroids(i,1)-10, centroids(i,2)-10]);
    img = step(txtInserter,img);
end


%vsetky sklony hran stvorcekov
angleXL = [];
angleXR = [];
angleYL = [];
angleYR = [];

for i=1:n
    if (sides(i)==1)
        angleXL(end+1) = (DR(i,1)-DL(i,1)) / (DR(i,2)-DL(i,2));
        angleXL(end+1) = (UR(i,1)-UL(i,1)) / (UR(i,2)-UL(i,2));
        angleYL(end+1) = (UR(i,2)-DR(i,2)) / (UR(i,1)-DR(i,1));
        angleYL(end+1) = (UL(i,2)-DL(i,2)) / (UL(i,1)-DL(i,1));
    end
    if (sides(i)==2)
        angleXR(end+1) = (DR(i,1)-DL(i,1)) / (DR(i,2)-DL(i,2));
        angleXR(end+1) = (UR(i,1)-UL(i,1)) / (UR(i,2)-UL(i,2));
        angleYR(end+1) = (DR(i,2)-UR(i,2)) / (DR(i,1)-UR(i,1));
        angleYR(end+1) = (DL(i,2)-UL(i,2)) / (DL(i,1)-UL(i,1));
    end
end

%priblizny uhol osi L a R strany
medAngleXR = median(angleXR);
medAngleXL = median(angleXL);
medAngleYR = median(angleYR);
medAngleYL = median(angleYL);

%kreslenie osi
% for i=1:n
%     if (sides(i)==1)
%         line([centroids(i,2)-200 centroids(i,2)+200], [centroids(i,1)-200*medAngleXL centroids(i,1)+200*medAngleXL]);
%         line([centroids(i,2)-200*medAngleYL centroids(i,2)+200*medAngleYL], [centroids(i,1)-200 centroids(i,1)+200]);
%     end
%     if (sides(i)==2)
%         line([centroids(i,2)-200 centroids(i,2)+200], [centroids(i,1)-200*medAngleXR centroids(i,1)+200*medAngleXR]);
%         line([centroids(i,2)-200*medAngleYR centroids(i,2)+200*medAngleYR], [centroids(i,1)-200 centroids(i,1)+200]);
%     end
%     if (sides(i)==3)
%         line([centroids(i,2)-200 centroids(i,2)+200], [centroids(i,1)-200*medAngleXR centroids(i,1)+200*medAngleXR]);
%         line([centroids(i,2)-200 centroids(i,2)+200], [centroids(i,1)-200*medAngleXL centroids(i,1)+200*medAngleXL]);
%     end
%     line([medXL-200 medXL+200], [medYL-200*medAngleXL medYL+200*medAngleXL]);
%     line([medXL-200*medAngleYL medXL+200*medAngleYL], [medYL-200 medYL+200]);
%     line([medXR-200 medXR+200], [medYR-200*medAngleXR medYR+200*medAngleXR]);
%     line([medXR-200*medAngleYR medXR+200*medAngleYR], [medYR-200 medYR+200]);
% end


%najdene chybajuce labely
foundL = [];
foundR = [];
foundU = [];

%prejdeme vsetky pary labelov na stene a najdeme priesecnik osi, ktore cez
%ne prechadzaju. tym najdeme vsetky labely, tie co mame aj tie co chybaju
for i=1:n
    if (sides(i)==1)
        for j=1:n
            if (i~=j && sides(j)==1)
                [x y] = polyxpoly([centroids(i,2)-200 centroids(i,2)+200], [centroids(i,1)-200*medAngleXL centroids(i,1)+200*medAngleXL],...
                    [centroids(j,2)-200*medAngleYL centroids(j,2)+200*medAngleYL], [centroids(j,1)-200 centroids(j,1)+200]);
%                 img = krizik(img, y, x, [0 0 255]);
                foundL(end+1,:) = [y x];
            end
        end
    end
    if (sides(i)==2)
        for j=1:n
            if (i~=j && sides(j)==2)
                [x y] = polyxpoly([centroids(i,2)-200 centroids(i,2)+200], [centroids(i,1)-200*medAngleXR centroids(i,1)+200*medAngleXR],...
                    [centroids(j,2)-200*medAngleYR centroids(j,2)+200*medAngleYR], [centroids(j,1)-200 centroids(j,1)+200]);
%                img = krizik(img, y, x, [0 0 255]);
                foundR(end+1,:) = [y x];
            end
        end
    end
    if (sides(i)==3)
        for j=1:n
            if (i~=j && sides(j)==3)
                [x y] = polyxpoly([centroids(i,2)-200 centroids(i,2)+200], [centroids(i,1)-200*medAngleXR centroids(i,1)+200*medAngleXR],...
                    [centroids(j,2)-200 centroids(j,2)+200], [centroids(j,1)-200*medAngleXL centroids(j,1)+200*medAngleXL]);
%                img = krizik(img, y, x, [0 0 255]);
                foundU(end+1,:) = [y x];
            end
        end
    end
end

%zoznam obsahov labelov
areaL = [];
areaR = [];

for i=1:n
    if (sides(i)==1)
        areaL(end+1) = length(pixelList{i});
    end
    if (sides(i)==2)
        areaR(end+1) = length(pixelList{i});
    end
end

%(velmi) priblizna dlzka strany stvorceka
edgeL = sqrt(median(areaL));
edgeR = sqrt(median(areaR));
edgeU = (edgeL+edgeR) / 2;

%centroidy chybajucich stvorcekov
centroidsL = [];
centroidsR = [];
centroidsU = [];

%prejdem vsetky najdene priesecniky osi a vyberieme tie, co su dost daleko
%od ostatnych znamych labelov
for i=1:size(foundL)
    if (cntL >= 9)
        break;
    end
    d = 10^6;
    for j=1:n
        if (sides(j)==1)
            d = min(d,dist(foundL(i,:),centroids(j,:)));
        end
    end
    for j=1:size(centroidsL)
        d = min(d,dist(foundL(i,:),centroidsL(j,:)));
    end
    if (d>edgeL*.6)
        cntL = cntL + 1;
        centroidsL(end+1,:) = foundL(i,:);
        img = krizik(img, centroidsL(end,1), centroidsL(end,2),...
            I(round(centroidsL(end,1)),round(centroidsL(end,2)),:));
    end
end

for i=1:size(foundR)
    if (cntR >= 9)
        break;
    end
    d = 10^6;
    for j=1:n
        if (sides(j)==2)
            d = min(d,dist(foundR(i,:),centroids(j,:)));
        end
    end
    for j=1:size(centroidsR)
        d = min(d,dist(foundR(i,:),centroidsR(j,:)));
    end
    if (d>edgeR*.6)
        cntR = cntR + 1;
        centroidsR(end+1,:) = foundR(i,:);
        img = krizik(img, centroidsR(end,1), centroidsR(end,2),...
            I(round(centroidsR(end,1)),round(centroidsR(end,2)),:));
    end
end

for i=1:size(foundU)
    if (cntU >= 9)
        break;
    end
    d = 10^6;
    for j=1:n
        if (sides(j)==3)
            d = min(d,dist(foundU(i,:),centroids(j,:)));
        end
    end
    for j=1:size(centroidsU)
        d = min(d,dist(foundU(i,:),centroidsU(j,:)));
    end
    if (d>edgeU*.6)
        cntU = cntU + 1;
        centroidsU(end+1,:) = foundU(i,:);
        img = krizik(img, centroidsU(end,1), centroidsU(end,2),...
            I(round(centroidsU(end,1)),round(centroidsU(end,2)),:));
    end
end


%TODO: ocislovanie po riadkoch

figure, imshow(img);
hold off;

end





function [I] = krizik(Iorig, x, y, col)
for i=-5:5
    Iorig(round(x)+i,round(y),:) = col;
    Iorig(round(x),round(y)+i,:) = col;
end
I = Iorig;
end




function [d] = dist(a, b)
d = sqrt ((a(1)-b(1))^2 + (a(2)-b(2))^2);
end







