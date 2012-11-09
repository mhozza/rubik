function rubik(img)
	I = rgb2gray(img);
	h = fspecial('average',3);
	I = imfilter(I, h);
	h = fspecial('unsharp');
	I = medfilt2(I,[10,10],'symmetric');
	figure;
	imshow(I);
	I = edge(I,'canny',4);		
	I = dilate(I,ones(5,5));	
	figure;
	
	imshow(I);
#	[H,T,R] = hough
end