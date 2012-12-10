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
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % pokus s farbami
    
    LAB_DIST = 15;
    
    %drbneme farby do 1 x n x 3 pola, lebo to tak rgb2lab funkcia chce
    tmp = zeros(1,n,3);
    for i=1:n
        tmp(1,i,:) = colors(i,:);
    end
    lab = RGB2Lab(tmp);
    %zoznam podobnych labelov ku kazdemu labelu
    similar = {};
    
    for i=1:n
        similar{end+1} = [];
        for j=1:n
            if (i~=j)
                dist = sqrt( (lab(1,i,1)-lab(1,j,1))^2 + (lab(1,i,2)-lab(1,j,2))^2 + (lab(1,i,3)-lab(1,j,3))^2);
                if (dist<LAB_DIST)
                   similar{i}(end+1) = j;
                end
                strcat({'LAB distance '},num2str(i),{'-'},num2str(j),{': '},num2str(dist))
                %strcat({'RGB  '},num2str(tmp(1,i,1)),{' '},num2str(tmp(1,i,2)),{' '},num2str(tmp(1,i,3)),{' '},...
                %    num2str(tmp(1,j,1)),{' '},num2str(tmp(1,j,2)),{' '},num2str(tmp(1,j,3)),{' '})
                
            end
        end
    end
    
    for i=1:n
        i
       similar{i}
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
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
    
    sides = getLabelSide(boundsList);
    
    
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
            
            text = 'U';
            if (sides(i)==1)
                text = 'L';
            end
            if (sides(i)==2)
                text = 'R';
            end
            
            txtInserter = vision.TextInserter(strcat(num2str(i),text),'Color',[0 0 0],'Location',[centroids(i,1)-10, centroids(i,2)-10]);
            img = step(txtInserter,img);
            img(boundsList{i}(1,1),boundsList{i}(1,2),:) = [255 0 0];

        end
    end
    
    
    figure, imshow(img);
    
    
    
    
end