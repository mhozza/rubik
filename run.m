%drbnite parameter 'all' ak chcete prejst vsetky fotky, inak dajte nazov
%suboru (napr. 'fotka.JPG'
function run(which)

if (strcmp(which,'all'))
    files = dir('./images');
    for i=1:length(files)
        [~, ~, ext] = fileparts(files(i).name);
        if (strcmp(ext,'.JPG') || strcmp(ext,'.jpg'))
            rubik(imread(strcat('./images/',files(i).name)));
        end
    end
    
else
    rubik(imread(strcat('./images/',which)));
end

end