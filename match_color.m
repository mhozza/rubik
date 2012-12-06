% Function to determine which color of official rubiks cube is closest to given color

%constants: rgb | hsv

% Red: 196, 30, 58 |  0.9719, 0.8469, 196
% Green: 0, 158, 96 | 0.4346, 1, 158
% Blue: 0, 81, 186 |  0.5941, 1, 186
% Orange: 255, 88, 0 |  0.0575, 1, 255
% Yellow: 255, 213, 0 |  0.1392, 1, 255 
% White: 255, 255, 255 | 0, 0, 255

% http://www.perbang.dk/rgb/009E60/



function [matched_color] = match_color(color)
	RED = [196, 30, 58];
	GREEN = [0, 158, 96];
	BLUE = [0, 81, 186];
	ORANGE = [255, 88, 0];
	YELLOW = [255, 213, 0];
	WHITE = [255, 255, 255];

	function [dh ds dv] = diff(h,s,v,oh,os,ov)
		dh = 1.0 - abs(oh-h);
		ds = 1.0 - abs(os-s);
		dv = 1.0 - (abs(ov-v)/255);
	end

	function score = universal_score(dh, ds, dv, wh, ws, wv)
		score = dh*wh+ds*ws+dv*wv;
	end

	function score = score_red(h,s,v)
		[oh os ov] = rgb2hsv(RED);
		[dh ds dv] = diff(h, s, v, oh, os, ov);
		score = universal_score(dh, ds, dv, 3/12, 3/12, 6/12);
	end

	function score = score_green(h,s,v)
		[oh os ov] = rgb2hsv(GREEN);
		[dh ds dv] = 	diff(h, s, v, oh, os, ov);
		score = universal_score(dh, ds, dv, 7/12, 2/12,3/12);
	end

	function score = score_blue(h,s,v)
		[oh os ov] = rgb2hsv(BLUE);
		[dh ds dv] = diff(h, s, v, oh, os, ov);
		score = universal_score(dh, ds, dv, 7/12, 2/12,3/12);
	end

	function score = score_orange(h,s,v)
		[oh os ov] = rgb2hsv(ORANGE);
		[dh ds dv] = diff(h, s, v, oh, os, ov);
		score = universal_score(dh, ds, dv, 5/12, 3/12,4/12);
	end

	function score = score_yellow(h,s,v)
		[oh os ov] = rgb2hsv(YELLOW);
		[dh ds dv] = diff(h, s, v, oh, os, ov);
		score = universal_score(dh, ds, dv, 6/12, 3/12,3/12);
	end

	function score = score_white(h,s,v)
		[oh os ov] = rgb2hsv(WHITE);
		[dh ds dv] = diff(h, s, v, oh, os, ov);
		score = universal_score(dh, ds, dv, 0, 8/12, 4/12);
	end

	[h s v] = rgb2hsv(color);
	score = 0;
	matched_color = 0;

	scr = score_red(h,s,v);
	if scr>score
	 	score = scr;
	 	matched_color = RED;
	end

	scr = score_green(h,s,v);
	if scr>score
	 	score = scr;
	 	matched_color = GREEN;
	end

	scr = score_blue(h,s,v);
	if scr>score
	 	score = scr;
	 	matched_color = BLUE;
	end

	scr = score_orange(h,s,v);
	if scr>score
	 	score = scr;
	 	matched_color = ORANGE;
	end

	scr = score_yellow(h,s,v);
	if scr>score
	 	score = scr;
	 	matched_color = YELLOW;
	end

	scr = score_white(h,s,v);
    if scr>score
	 	matched_color = WHITE;
    end

end