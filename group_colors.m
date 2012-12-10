function color_groups=group_colors(colors)
    function similar=is_similar(color1, color2)        
        similar=false;
    end

    color_groups = zeros(0,1,3);
    for i=1:length(colors)
        nenasiel = true;
        % for j=1:length(color_groups)
        %     if is_similar(colors(i,:),color_groups(j,1,:))
        %         color_groups(:,:,j) = [color_groups(:,:,j); colors(:,i)];
        %         nasiel = false;
        %     end
        % end

        if nenasiel      
            color_groups = [color_groups; colors(i,:)];            
            % color_groups(length(color_groups)+1,1) = colors(i);

            % color_groups(length(color_groups)+1,1,1) = colors(i,1);
            % color_groups(length(color_groups)+1,1,2) = colors(i,2);
            % color_groups(length(color_groups)+1,1,3) = colors(i,3);
        end
    end

end