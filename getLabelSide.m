%najde rohy stvorceka na kocke a zisti, na ktoru jej stenu patri (lava=1,
%prava=2, horna=3)
%UL,UD,UR,DR = pozicie rohov (Up,Left,Right,Down)
%labelBounds - cellArray so suradnicami okraja stvorceka
%edgeLen - priblizna dlzka hrany stvorceka
function [side UL DL UR DR] = getLabelSide(labelBounds, edgeLen)

%algoritmus: sweepujeme sikmou ciarou smerom z okraja obrazku obraz, kym
%nenarazime na jeden z rohov.
%pravdaze netreba sweep simulovat, len spocitame skore pre kazdy bod z
%okraja stvorceka.

%vaha y-osi, tj. sweeping line bude naklonena viac vertikalne ak vaha>1
YW = 1.1;

%pozicie rohov, najlepsie najdene skore, x-pozicia
%ak je skore rovnake, vyberame to s x poziciou viac na okraj stvorceka
UL = [];
ULscore = 10^6;
ULscoreX = 10^6;
DL = [];
DLscore = -10^6;
DLscoreX = 10^6;
UR = [];
URscore = 10^6;
URscoreX = -10^6;
DR = [];
DRscore = -10^6;
DRscoreX = -10^6;

for i=1:size(labelBounds,1)
    
     x = labelBounds(i,1);
     y = labelBounds(i,2);
     
     if (x+y*YW<ULscore || (x+y*YW==ULscore && x<ULscoreX))
         ULscore = x+y*YW;
         ULscoreX = x;
         UL = [x y];
     end

     if (x-y*YW>DLscore || (x-y*YW==DLscore && x<DLscoreX))
         DLscore = x-y*YW;
         DLscoreX = x;
         DL = [x y];
     end
     
     if (x-y*YW<URscore || (x-y*YW==URscore && x>URscoreX))
         URscore = x-y*YW;
         URscoreX = x;
         UR = [x y];
     end

     if (x+y*YW>DRscore || (x+y*YW==DRscore && x>DRscoreX))
         DRscore = x+y*YW;
         DRscoreX = x;
         DR = [x y];
     end
end

side = 3;

%ak su lave/prave rohy zbehnute k sebe, je to horna strana
if (dist(UL,DL)*3 < edgeLen && dist(UR,DR)*3 < edgeLen)
   side = 3;
   return;
end

dy1 = abs((UL(1)-DL(1)) / (UL(2)-DL(2)));
dy2 = abs((UR(1)-DR(1)) / (UR(2)-DR(2)));

%ak ma dostatocne vertikalne hrany, bude lava alebo prava
if (dy1 > 2.5 || dy2 > 2.5)
    %vyberieme stranu podla smerovania sklonu
    if (UR(1) > UL(1) && DR(1) > DL(1))
        side = 1;
        return;
    end
    if (UR(1) < UL(1) && DR(1) < DL(1))
        side = 2;
        return;
    end
end

end




function [d] = dist(a, b)
d = sqrt ((a(1)-b(1))^2 + (a(2)-b(2))^2);
end

