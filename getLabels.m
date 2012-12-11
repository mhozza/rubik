%ziska casti obrazku zodpovedajuce stvorcekom na kocke
%vystup: zoznam vlastnosti pre kazdy najdeny label:
%pixelList - pixely labelu
%boundsList - pixely okraja
%centroids - necakane centroid labelu
%colors - priemerna farba labelu
function [pixelList boundsList centroids colors] = getLabels(Iorig, BW)

    FORBIDDEN_BORDER = .1;
    MIN_SOLIDITY_RATIO = .85;
    MIN_AXIS_RATIO = .15;
    MAX_SQUARE_SIZE = .03;
    MIN_SQUARE_PIXELS = 100;

    [xsz ysz ~] = size(BW);
    pxcnt = xsz*ysz;

    %najdeme komponenty a ich vlastnosti
    components = bwconncomp(BW);
    prop = regionprops(components,'PixelList','Solidity','MinorAxisLength','MajorAxisLength', 'BoundingBox','Extrema','ConvexArea','Centroid');
    
    pixelList = {};
    boundsList = {};
    centroids = [];
    colors = [];
    
    %prejdeme vsetky komponenty BW obrazku
    for i=1:length(prop)
        
        %pixely komponentu
        pixels = prop(i).PixelList;
        [n ~] = size(pixels);
        relativeSize = n/pxcnt;
        axisRatio = prop(i).MinorAxisLength/prop(i).MajorAxisLength;
        box = prop(i).BoundingBox;
        onBorder = box(2) < xsz*FORBIDDEN_BORDER || box(1) < ysz*FORBIDDEN_BORDER ||...
            box(2)+box(4) > xsz*(1-FORBIDDEN_BORDER) || box(1)+box(3) > ysz*(1-FORBIDDEN_BORDER);
        
        %komponent je dobry ak:
        %-nie je na okraji obrazku
        %-dobre vyplna svoj konvexny obal
        %-nie je prilis splosteny
        %-dostatocne vyplna svoj konvexny obal
        %-nie je prilis deravy
        %-nie je prilis velky
        %-nie je prilis maly
        if (~onBorder && axisRatio > MIN_AXIS_RATIO && prop(i).Solidity > MIN_SOLIDITY_RATIO &&...
                relativeSize < MAX_SQUARE_SIZE && n > MIN_SQUARE_PIXELS)
            
            centroids = [centroids; [prop(i).Centroid(2) prop(i).Centroid(1)]];
            pixelList{end+1} = [];
            for j=1:n
                pixelList{end}(end+1,:) = [pixels(j,2) pixels(j,1)];
            end
            
            %spocitame hodnoty jednotlivych zloziek
            rTot = 0.; gTot = 0.; bTot = 0.;
            for j=1:n
                 rTot = rTot + double(Iorig(pixels(j,2), pixels(j,1),1));
                 gTot = gTot + double(Iorig(pixels(j,2), pixels(j,1),2));
                 bTot = bTot + double(Iorig(pixels(j,2), pixels(j,1),3));
            end

            %najdeme okraje
            bounds = bwtraceboundary(BW,[round(prop(i).Extrema(1,2)) round(prop(i).Extrema(1,1))],'N');
            boundsList{end+1} = bounds;

            colors = [colors; [round(rTot/n) round(gTot/n) round(bTot/n)]];
            
        end

    end

end

