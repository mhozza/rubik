function [centroidsSorted colorsSorted] = getLabelOrder(side, centroids, colors, XRaxis)

centroidsSorted = zeros(9,2);
colorsSorted = zeros(9,3);

if (side==1 || side==2)
    for col=1:3
        idx = 1:3;
        yx = zeros(3,2);
        for i=1:3
            [m idx(i)] = min(centroids(:,2));
            yx(i,:) = centroids(idx(i),:);
            centroids(idx(i),:) = [10^6 10^6];
        end
        if (side==1)
            [S idxS] = sort(yx,1);
        else
            [S idxS] = sort(yx,1);
        end
        centroidsSorted(col,:) = yx(idxS(1),:);
        colorsSorted(col,:) = colors(idx(idxS(1)),:);
        centroidsSorted(3+col,:) = yx(idxS(2),:);
        colorsSorted(3+col,:) = colors(idx(idxS(2)),:);
        centroidsSorted(6+col,:) = yx(idxS(3),:);
        colorsSorted(6+col,:) = colors(idx(idxS(3)),:);
    end
else
    for col=1:3
        idx = 1:3;
        yx = zeros(3,2);
        for i=1:3
            minScore = 10^6;
            minIdx = 0;
            for j=1:9
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

