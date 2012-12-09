function rubik(I)

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
    
    %velkosti labelov (poc. pixelov) a najblizsia vzdialenost labelu k
    %inemu
    sizes = 1:n;
    closestDist = 1:n;
    for i=1:n
        sizes(i) = length(pixelList{i});
        closestDist(i) = 10^9;
        for j=1:n
            if (i~=j)
                closestDist(i) = min(closestDist(i),...
                    sqrt( (centroids(i,1) - centroids(j,1))^2 + (centroids(i,2) - centroids(j,2))^2));
            end
        end
    end
    medSize = median(sizes);
    medDist = median(closestDist);
    
    
    for i=1:n
        
        %berieme len nieco vhodne velke a vhodne blizko k ostatnym
        if (sizes(i) > medSize/3 && sizes(i)< medSize*3 && closestDist(i)<3*medDist &&...
                closestDist(i)>medDist/3)
            for j=1:length(pixelList{i})
                img(pixelList{i}(j,1),pixelList{i}(j,2),:) = colors(i,:);
            end
            
            for j=1:length(boundsList{i})
                img(boundsList{i}(j,1),boundsList{i}(j,2),:) = [255 255 255];
            end

        end
    end
    
figure, imshow(img);
    
    
end