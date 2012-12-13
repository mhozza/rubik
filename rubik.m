function rubik(I, fileName, labelsOnly)

show_matched_colors = true;

if nargin==2
    labelsOnly = 0;
end

%algoritmus outline:
%-najdeme BW obrazok s uzavretymi oblastami
%-zistime, ktore oblasti su dobre
%-dodatocne vyhodime zle oblasti na zaklade ich vzajomnych vztahov
%-mame uz priradene stvorceky k stranam, opravime ak su zle priradenia
%-najdeme osi stran kocky
%-natiahneme osi cez centroidy stvorcekov a ziskame mriezku, ktora bude
%prechadzat aj chybajucimi stvorcekami
%-prejdeme najdene priesecniky osi a byberieme z nich tie, ktore su daleko
%od najdenych stvorcekov
%-z takychto priesecnikov vytrieskame pomocou k-means centroidy chybajucich
%stvorcekov
%-zistime, v akom poradi maju stvorecky v ramci strany kocky ist

figure, imshow(I);

BW = getBWimage(I);
figure, imshow(BW);

[pixelList boundsList centroids colors] = getLabels(I, BW);

%tazky hack, matlabu drbe a ked len spravim zeros(size(I)), mysli si ze
%to je nejaky iny color model (ktory ani neexistuje)
img = I;
img(:,:,:) = 0;

%pocet labelov
n = length(pixelList);

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

imgCorners = img;

for i=1:n
    
    %berieme len nieco vhodne velke a vhodne blizko k ostatnym
    if (sizes(i) > medSize/3 && sizes(i) < medSize*3 &&...
            closestDist(i) < 3*medDist && closestDist(i) > medDist/3)
        
        for j=1:length(pixelList{i})
            img(pixelList{i}(j,1),pixelList{i}(j,2),:) = colors(i,:);
            imgCorners(pixelList{i}(j,1),pixelList{i}(j,2),:) = colors(i,:);
        end
        for j=1:length(boundsList{i})
            img(boundsList{i}(j,1),boundsList{i}(j,2),:) = [255 255 255];
            imgCorners(boundsList{i}(j,1),boundsList{i}(j,2),:) = [255 255 255];
        end
        
        [side ul dl ur dr] = getLabelSide(boundsList{i}, sqrt(length(pixelList{i})));
        imgCorners = krizik(imgCorners, ul(1),ul(2),[255 0 0],1);
        imgCorners = krizik(imgCorners, dl(1),dl(2),[0 255 0],1);
        imgCorners = krizik(imgCorners, ur(1),ur(2),[255 255 0],1);
        imgCorners = krizik(imgCorners, dr(1),dr(2),[255 255 255],1);
        
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

figure, imshow(img);

if labelsOnly
    return;
end

figure, imshow(imgCorners);

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
    txtInserter = vision.TextInserter(strcat(text),'Color',[0 0 0],...
        'Location',[centroids(i,1)-7, centroids(i,2)-7],'FontSize',14);
    img = step(txtInserter,img);
end

figure, imshow(img);

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

%priblizny "uhol" osi L a R strany
medAngleXR = median(angleXR);
medAngleXL = median(angleXL);
medAngleYR = median(angleYR);
medAngleYL = median(angleYL);

AXE_LEN = 180;
%modifikator pre hornu stenu, kompenzuje perspektivu
AXE_U_PERSP_MODIF = 0.78;

%kreslenie osi
figure, imshow(img), hold on;
for i=1:n
    line([medXL-200 medXL+200], [medYL-200*medAngleXL medYL+200*medAngleXL],...
        'Color','Red', 'LineWidth',2);
    line([medXL-200*medAngleYL medXL+200*medAngleYL], [medYL-200 medYL+200],...
        'Color','Red', 'LineWidth',2);
    line([medXR-200 medXR+200], [medYR-200*medAngleXR medYR+200*medAngleXR],...
        'Color','Yellow', 'LineWidth',2);
    line([medXR-200*medAngleYR medXR+200*medAngleYR], [medYR-200 medYR+200],...
        'Color','Yellow', 'LineWidth',2);
end

%kreslenie mriezky
figure, imshow(img), hold on;
for i=1:n
    if (sides(i)==1)
        line([centroids(i,2)-AXE_LEN centroids(i,2)+AXE_LEN], [centroids(i,1)-AXE_LEN*medAngleXL centroids(i,1)+AXE_LEN*medAngleXL], 'Color', 'Red');
        line([centroids(i,2)-AXE_LEN*medAngleYL centroids(i,2)+AXE_LEN*medAngleYL], [centroids(i,1)-AXE_LEN centroids(i,1)+AXE_LEN], 'Color', 'Red');
    end
    if (sides(i)==2)
        line([centroids(i,2)-AXE_LEN centroids(i,2)+AXE_LEN], [centroids(i,1)-AXE_LEN*medAngleXR centroids(i,1)+AXE_LEN*medAngleXR], 'Color', 'Yellow');
        line([centroids(i,2)-AXE_LEN*medAngleYR centroids(i,2)+AXE_LEN*medAngleYR], [centroids(i,1)-AXE_LEN centroids(i,1)+AXE_LEN], 'Color', 'Yellow');
    end
    if (sides(i)==3)
        line([centroids(i,2)-AXE_LEN centroids(i,2)+AXE_LEN],...
            [centroids(i,1)-AXE_LEN*medAngleXR*AXE_U_PERSP_MODIF centroids(i,1)+AXE_LEN*medAngleXR*AXE_U_PERSP_MODIF], 'Color', 'Blue');
        line([centroids(i,2)-AXE_LEN centroids(i,2)+AXE_LEN],...
            [centroids(i,1)-AXE_LEN*medAngleXL*AXE_U_PERSP_MODIF centroids(i,1)+AXE_LEN*medAngleXL*AXE_U_PERSP_MODIF], 'Color', 'Blue');
    end
end


%najdene chybajuce labely
foundL = [];
foundR = [];
foundU = [];

AXE_LEN = 1000;

%prejdeme vsetky pary labelov na stene a najdeme priesecnik osi, ktore cez
%ne prechadzaju. tym najdeme vsetky labely, tie co mame aj tie co chybaju
for i=1:n
    if (sides(i)==1)
        for j=1:n
            if (i~=j && sides(j)==1)
                [x y] = polyxpoly([centroids(i,2)-AXE_LEN centroids(i,2)+AXE_LEN], [centroids(i,1)-AXE_LEN*medAngleXL centroids(i,1)+AXE_LEN*medAngleXL],...
                    [centroids(j,2)-AXE_LEN*medAngleYL centroids(j,2)+AXE_LEN*medAngleYL], [centroids(j,1)-AXE_LEN centroids(j,1)+AXE_LEN]);
                foundL(end+1,:) = [y x];
            end
        end
    end
    if (sides(i)==2)
        for j=1:n
            if (i~=j && sides(j)==2)
                [x y] = polyxpoly([centroids(i,2)-AXE_LEN centroids(i,2)+AXE_LEN], [centroids(i,1)-AXE_LEN*medAngleXR centroids(i,1)+AXE_LEN*medAngleXR],...
                    [centroids(j,2)-AXE_LEN*medAngleYR centroids(j,2)+AXE_LEN*medAngleYR], [centroids(j,1)-AXE_LEN centroids(j,1)+AXE_LEN]);
                foundR(end+1,:) = [y x];
            end
        end
    end
    if (sides(i)==3)
        for j=1:n
            if (i~=j && sides(j)==3)
                [x y] = polyxpoly([centroids(i,2)-AXE_LEN centroids(i,2)+AXE_LEN],...
                    [centroids(i,1)-AXE_LEN*medAngleXR*AXE_U_PERSP_MODIF centroids(i,1)+AXE_LEN*medAngleXR*AXE_U_PERSP_MODIF],...
                    [centroids(j,2)-AXE_LEN centroids(j,2)+AXE_LEN],...
                    [centroids(j,1)-AXE_LEN*medAngleXL*AXE_U_PERSP_MODIF centroids(j,1)+AXE_LEN*medAngleXL*AXE_U_PERSP_MODIF]);
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

EDGE_SIZE_MODIF = .7;

foundLfiltered = [];
foundRfiltered = [];
foundUfiltered = [];

%prejdeme vsetky najdene priesecniky osi a vyberieme tie, co su dost daleko
%od ostatnych znamych labelov
for i=1:size(foundL,1)
    d = 10^6;
    for j=1:n
        if (sides(j)==1)
            d = min(d,dist(foundL(i,:),centroids(j,:)));
        end
    end
    if (d>edgeL*EDGE_SIZE_MODIF)
        foundLfiltered(end+1,:) = foundL(i,:);
    end
end

for i=1:size(foundR,1)
    d = 10^6;
    for j=1:n
        if (sides(j)==2)
            d = min(d,dist(foundR(i,:),centroids(j,:)));
        end
    end
    if (d>edgeR*EDGE_SIZE_MODIF)
        foundRfiltered(end+1,:) = foundR(i,:);
    end
end

for i=1:size(foundU,1)
    d = 10^6;
    for j=1:n
        if (sides(j)==3)
            d = min(d,dist(foundU(i,:),centroids(j,:)));
        end
    end
    if (d>edgeU*EDGE_SIZE_MODIF)
        foundUfiltered(end+1,:) = foundU(i,:);
    end
end

%vysledne centroidy a farby stvorcekov
centroidsL = [];
centroidsR = [];
centroidsU = [];
colorsL = [];
colorsR = [];
colorsU = [];

%pridame zname
for i=1:n
   if (sides(i)==1)
       centroidsL(end+1,:) = centroids(i,:);
       colorsL(end+1,:) = colors(i,:);
   end
   if (sides(i)==2)
       centroidsR(end+1,:) = centroids(i,:);
       colorsR(end+1,:) = colors(i,:);
   end
   if (sides(i)==3)
       centroidsU(end+1,:) = centroids(i,:);
       colorsU(end+1,:) = colors(i,:);
   end
end

%pomocou k-means pozhlukujeme a ziskame chybajuce
if (cntL < 9 && size(foundLfiltered,1) >= 9-cntL)
    [IDX C] = kmeans(foundLfiltered, 9-cntL,'replicates',10);
    for i=1:size(C,1)
        centroidsL(end+1,:) = C(i,:);
        img = krizik(img, C(i,1), C(i,2), I(round(C(i,1)),round(C(i,2)),:),1);
        colorsL(end+1,:) = I(round(C(i,1)),round(C(i,2)),:);
    end
end
if (cntR < 9 && size(foundRfiltered,1) >= 9-cntR)
    [IDX C] = kmeans(foundRfiltered, 9-cntR,'replicates',10);
    for i=1:size(C,1)
        centroidsR(end+1,:) = C(i,:);
        img = krizik(img, C(i,1), C(i,2), I(round(C(i,1)),round(C(i,2)),:),1);
        colorsR(end+1,:) = I(round(C(i,1)),round(C(i,2)),:);
    end
end
% img2 = img;
% for i=1:size(foundUfiltered)
%     img2 = krizik(img2, foundUfiltered(i,1), foundUfiltered(i,2), [255 255 255]);
% end
% figure, imshow(img2);
if (cntU < 9 &&  size(foundUfiltered,1) >= 9-cntU)
    [IDX C] = kmeans(foundUfiltered, 9-cntU,'replicates',10);
    for i=1:size(C,1)
        centroidsU(end+1,:) = C(i,:);
        img = krizik(img, C(i,1), C(i,2), I(round(C(i,1)),round(C(i,2)),:),1);
        colorsU(end+1,:) = I(round(C(i,1)),round(C(i,2)),:);
    end
end

figure, imshow(img);
hold off;


%vykreslenie vsetkych centroidov pre kontrolu
% imgC = img;
% imgC(:,:,:) = 0;
% for i=1:size(centroidsL,1)
%     imgC = krizik(imgC, centroidsL(i,1), centroidsL(i,2), colorsL(i,:));
% end
% for i=1:size(centroidsR,1)
%     imgC = krizik(imgC, centroidsR(i,1), centroidsR(i,2), colorsR(i,:));
% end
% for i=1:size(centroidsU,1)
%     imgC = krizik(imgC, centroidsU(i,1), centroidsU(i,2), colorsU(i,:));
% end
% figure, imshow(imgC);

if (size(centroidsL,1)~=9 || size(centroidsR,1)~=9 || size(centroidsU,1)~=9)
    return;
end

%posortime stvorceky pre kazdu stenu
[centroidsLsorted, colorsLsorted] = getLabelOrder(1, centroidsL, colorsL, 0);
[centroidsRsorted, colorsRsorted] = getLabelOrder(2, centroidsR, colorsR, 0);
[centroidsUsorted, colorsUsorted] = getLabelOrder(3, centroidsU, colorsU, medAngleXR*AXE_U_PERSP_MODIF);

imgC = img;
imgC(:,:,:) = 0;

if(show_matched_colors)
    imgC2 = img;
    imgC2(:,:,:) = 0;
end

for i=1:9
    txtInserter = vision.TextInserter(strcat('L',num2str(i)),'Color',colorsLsorted(i,:),...
        'Location',[centroidsLsorted(i,1)-7, centroidsLsorted(i,2)-7], 'FontSize',14);
    imgC = step(txtInserter,imgC);
    if(show_matched_colors)
        txtInserter2 = vision.TextInserter(strcat('L',num2str(i)),'Color',match_color(colorsLsorted(i,:)),...
            'Location',[centroidsLsorted(i,1)-7, centroidsLsorted(i,2)-7], 'FontSize',14);
        imgC2 = step(txtInserter2,imgC2);
    end
end
for i=1:9
    txtInserter = vision.TextInserter(strcat('R',num2str(i)),'Color',colorsRsorted(i,:),...
        'Location',[centroidsRsorted(i,1)-7, centroidsRsorted(i,2)-7], 'FontSize',14);
    imgC = step(txtInserter,imgC);
    if(show_matched_colors)
        txtInserter2 = vision.TextInserter(strcat('R',num2str(i)),'Color',match_color(colorsRsorted(i,:)),...
            'Location',[centroidsRsorted(i,1)-7, centroidsRsorted(i,2)-7], 'FontSize',14);
        imgC2 = step(txtInserter2,imgC2);
    end
end
for i=1:9
    txtInserter = vision.TextInserter(strcat('U',num2str(i)),'Color',colorsUsorted(i,:),...
        'Location',[centroidsUsorted(i,1)-7, centroidsUsorted(i,2)-7], 'FontSize',14);
    imgC = step(txtInserter,imgC);
    if(show_matched_colors)
        txtInserter2 = vision.TextInserter(strcat('U',num2str(i)),'Color',match_color(colorsUsorted(i,:)),...
            'Location',[centroidsUsorted(i,1)-7, centroidsUsorted(i,2)-7], 'FontSize',14);
        imgC2 = step(txtInserter2,imgC2);
    end
end
figure, imshow(imgC);
if(show_matched_colors)
    figure, imshow(imgC2);
end
hold off;


%ulozenie farieb na subor
dlmwrite(strcat(fileName,'.txt'),...
[[colorsLsorted(1,:) colorsLsorted(2,:) colorsLsorted(3,:); colorsLsorted(4,:) colorsLsorted(5,:) colorsLsorted(6,:); colorsLsorted(7,:) colorsLsorted(8,:) colorsLsorted(9,:)];
[colorsRsorted(1,:) colorsRsorted(2,:) colorsRsorted(3,:); colorsRsorted(4,:) colorsRsorted(5,:) colorsRsorted(6,:); colorsRsorted(7,:) colorsRsorted(8,:) colorsRsorted(9,:)];
[colorsUsorted(3,:) colorsUsorted(6,:) colorsUsorted(9,:); colorsUsorted(2,:) colorsUsorted(5,:) colorsUsorted(8,:); colorsUsorted(1,:) colorsUsorted(4,:) colorsUsorted(7,:)]]...
,' ');

end





function [I] = krizik(Iorig, x, y, col, thick)
if thick
    for k=-1:1:1
        for i=-5:5
            Iorig(round(x)+i,round(y)+k,:) = col;
            Iorig(round(x)+k,round(y)+i,:) = col;
        end
    end
else
    for i=-5:5
        Iorig(round(x)+i,round(y),:) = col;
        Iorig(round(x),round(y)+i,:) = col;
    end
end
I = Iorig;
end



function [d] = dist(a, b)
d = sqrt ((a(1)-b(1))^2 + (a(2)-b(2))^2);
end



function [d] = distLinePoint(line, point)
d = abs(cross(line(2)-line(1),point-line(1)))/abs(line(2)-line(1));
end
