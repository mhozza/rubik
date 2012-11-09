function rubik(img)
	I = rgb2gray(img);
	I = edge(I);	
	imshow(I);
end