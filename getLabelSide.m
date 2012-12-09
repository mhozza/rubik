%priradi kazdej oblasti stranu na kocke, kam patri
%vstup: pixely obrysu kocky
%vystup: cislo 1,2,3 ku kazdemu obrysu (1-vlavo, 2-vpravo, 3-hore)
function [sides] = getLabelSide(labelBounds)

%dlzka vektora prilepeneho k obrysu
VECTOR_LEN = 6;

%vychylka od vertikaly
%predpocitame tangens a staci uz len porovnat pomer y a x zlozky vektora,
%nemusime pocitat uhol, akoze optimalizacia
LIM = tan(degtorad(80));

%pomer poctu jednych vektorov k druhym, ktory ked prekrocime, tak zaradime
%stvorcek do majorantnej strany
LR_QUOTIENT = 4;

n = length(labelBounds);
sides = 1:n;

for i=1:n
    m = length(labelBounds{i});
    %pocet vektorov ktore pravdepodobne patria lavej/pravej strane
    left = 0;
    right = 0;
    
    for j=1:m
        %y a x zlozka vektora
        dy = labelBounds{i}(j,1) - labelBounds{i}(1+mod(j-1+VECTOR_LEN,m),1);
        dx = -labelBounds{i}(j,2) + labelBounds{i}(1+mod(j-1+VECTOR_LEN,m),2);
        %vertikala, ignorujeme
        if (dx == 0)
            continue;
        end
        
        %ak ma vychylku od vertikaly vacsiu ako 10 stupnov
        if (abs(dy/dx) < LIM)
            %uhol v prvom alebo tretom kvadrante
            if (dx*dy>0 || (dy==0 && dx==-1))
                right = right + 1;
            %uhol v druhom alebo stvrtok kvadrante
            else
                left = left + 1;
            end
        end
        
    end
    
    sides(i) = 3;
    %ak jedna zlozka vyrazne prevazuje druhu
    if (left > right && right*LR_QUOTIENT < left)
        sides(i) = 1;
    end
    if (right > left && left*LR_QUOTIENT<right)
        sides(i) = 2;
    end
    
end

end