%drbnite parameter 'all' ak chcete prejst vsetky fotky, inak dajte nazov
%suboru (napr. 'fotka.JPG')
%parameter 'other' prejde subory v priecnku ./images/other
%parameter 'pair' prejde subory v priecnku ./images/pair
function run(which, labelsOnly)

if nargin==1
   labelsOnly = 0; 
end

%kvoli kompatibilite s matlabom 2011a - dufam ze to nebude robit problemy.
%vision.setCoordinateSystem('RC');

path = '';
if (strcmp(which,'all'))
    path = './images/';
end
if (strcmp(which,'other'))
    path = './images/other/';
end
if (strcmp(which,'pair'))
    path = './images/pair/';
end

if (~strcmp(path,''))
    files = dir(path);
    for i=1:length(files)
        [~, ~, ext] = fileparts(files(i).name);
        if (strcmp(ext,'.JPG') || strcmp(ext,'.jpg'))
            rubik(imread(strcat(path,files(i).name)), strcat(path,files(i).name), labelsOnly);
        end
    end
    
else
    rubik(imread(strcat('./images/',which)), strcat('./images/',which), labelsOnly);
end

end