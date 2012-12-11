function color_groups=group_colors(colors)    

    function similar=is_similar(color1, color2)        
        LAB_DIST = 15;
        dist = sqrt(  (color1(2)-color2(2))^2 + (color1(3)-color2(3))^2);
        if (dist<LAB_DIST)
           similar = true;        
        else
           similar=false;
        end
    end

    function color=lab1(rgb)
        %drbneme farby do 1 x 1 x 3 pola, lebo to tak RGB2Lab funkcia chce
        tmp = zeros(1,1,3);        
        tmp(1,1,:) = rgb;
        color = RGB2Lab(tmp);    
    end    

    color_groups = {};
    for i=1:length(colors)
        nenasiel = true;        
        for j=1:length(color_groups)            
            if is_similar(lab1(colors(i,:)), lab1(color_groups{j}(1,:)))
                color_groups{j} = [color_groups{j}; colors(i,:)];
                nenasiel = false;
                break;
            end
        end

        if nenasiel                        
            color_groups{end+1} = colors(i,:);
        end
    end

end