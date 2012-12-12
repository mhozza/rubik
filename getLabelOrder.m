%vrati po riadkoch posortene centroidy stvorcekov a ich prisluchajuce farby
%side - strana ktorej patria stvorceky
%centroids, colors - centroidy a farby, musi ich byt 9!!!
%XRaxis - sklon riadkov pravej strany kocky
function [centroidsSorted colorsSorted] = getLabelOrder(side, centroids, colors, XRaxis)

centroidsSorted = zeros(9,2);
colorsSorted = zeros(9,3);

if (side==1 || side==2)
    %ideme po stlcoch zlava doprava, najdeme vzdy tri stvorceky s najmensim x
    for col=1:3
        idx = 1:3;
        yx = zeros(3,2);
        for i=1:3
            [m idx(i)] = min(centroids(:,2));
            yx(i,:) = centroids(idx(i),:);
            centroids(idx(i),:) = [10^6 10^6];
        end
        %stvorceky stlpca posortime podla y
        [S idxS] = sort(yx,1);
        %nahadzeme do stlpca zoradene stvorceky a farby
        centroidsSorted(col,:) = yx(idxS(1),:);
        colorsSorted(col,:) = colors(idx(idxS(1)),:);
        centroidsSorted(3+col,:) = yx(idxS(2),:);
        colorsSorted(3+col,:) = colors(idx(idxS(2)),:);
        centroidsSorted(6+col,:) = yx(idxS(3),:);
        colorsSorted(6+col,:) = colors(idx(idxS(3)),:);
    end
%horna stena    
else
    %opat po stlpoch, ale musime ich najst podla osi danej sklonom riadkov
    %pravej steny kocky
    for col=1:3
        idx = 1:3;
        yx = zeros(3,2);
        %hladame tri stvorceky s najlepsim skore podobne ako v getLabelSide
        %linesweepingom
        for i=1:3
            minScore = 10^6;
            minIdx = 0;
            %skusime kazdy stvorcek
            for j=1:9
                %pridame do uvahy sklon, aby sme nesli podla ciary pod 45
                %stupnvym uhlom, ale podla orientacie stlpcov/riadkov
                score = centroids(j,1)+centroids(j,2)*abs(XRaxis);
                if (score < minScore)
                   minScore = score;
                   minIdx = j;
                end
            end
            yx(i,:) = centroids(minIdx,:);
            centroids(minIdx,:) = [10^6 10^6];
            idx(i) = minIdx;
        end
        %ziskane 3 stvorceky uz staci posortit podla y
        [S idxS] = sort(yx,1,'descend');
        centroidsSorted(col*3-2,:) = yx(idxS(1),:);
        colorsSorted(col*3-2,:) = colors(idx(idxS(1)),:);
        centroidsSorted(col*3-1,:) = yx(idxS(2),:);
        colorsSorted(col*3-1,:) = colors(idx(idxS(2)),:);
        centroidsSorted(col*3,:) = yx(idxS(3),:);
        colorsSorted(col*3,:) = colors(idx(idxS(3)),:);
    end
    
end

end

