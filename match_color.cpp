// Function to determine which color of official rubiks cube is closest to given color

// constants: rgb | hsv

// Red: 196, 30, 58 |  0.9719, 0.8469, 196
// Green: 0, 158, 96 | 0.4346, 1, 158
// Blue: 0, 81, 186 |  0.5941, 1, 186
// Orange: 255, 88, 0 |  0.0575, 1, 255
// Yellow: 255, 213, 0 |  0.1392, 1, 255 
// White: 255, 255, 255 | 0, 0, 255

// http://www.perbang.dk/rgb/009E60/
typedef struct {
    int h, s, v;
} dhsv;

dhsv diff(hsv c,hsv o)
{
    dhsv d;
    d.h = 1.0 - abs(o.h-c.h);
    d.s = 1.0 - abs(o.s-c.s);
    d.v = 1.0 - (abs(o.v-c.v)/255);
}

double universal_score(dhsv d, wh, ws, wv)
{
    score = sqrt((d.h^2*wh)+d.s^2*ws+d.v^2*wv);
}

double score_red(hsv c)
{
    hsv o = rgb2hsv(RED);
    dhsv d = diff(c, o);
    return universal_score(d, 4/12, 3/12, 5/12);
}

double score_green(hsv c)
{
    hsv o = rgb2hsv(GREEN);
    dhsv d = diff(c, o);
    return universal_score(d, 7/12, 2/12,3/12);
}

double score_blue(hsv c)
{
    hsv o = rgb2hsv(BLUE);
    dhsv d = diff(c, o);
    return universal_score(d, 7/12, 2/12,3/12);
}

double score_orange(hsv c)
{
    hsv o = rgb2hsv(ORANGE);
    dhsv d = diff(c, o);
    return universal_score(d, 4/12, 3/12,5/12);
}

double score_yellow(hsv c)
{
    hsv o = rgb2hsv(YELLOW);
    dhsv d = diff(c, o);
    return universal_score(d, 6/12, 3/12,3/12);
}

double score_white(hsv c)
{
    hsv o = rgb2hsv(WHITE);
    dhsv d = diff(c, o);
    return universal_score(d, 0, 8/12, 4/12);
}

rgb match_color(rgb color)
{
    rgb RED = rgb({196, 30, 58});
    rgb GREEN = rgb({0, 158, 96});
    rgb BLUE = rgb({0, 81, 186});
    rgb ORANGE = rgb({255, 88, 0});
    rgb YELLOW = rgb({255, 213, 0});
    rgb WHITE = rgb({255, 255, 255});
 
    hsv c = rgb2hsv(color);
    double score = 0, scr = 0;
    rgb matched_color = 0;

    scr = score_red(c);
    if (scr>score)
    {
        score = scr;
        matched_color = RED;
    }

    scr = score_green(c);
    if (scr>score)
    {
        score = scr;
        matched_color = GREEN;
    }

    scr = score_blue(c);
    if (scr>score)
    {
        score = scr;
        matched_color = BLUE;
    }

    scr = score_orange(c);
    if (scr>score)
    {
        score = scr;
        matched_color = ORANGE;
    }

    scr = score_yellow(c);
    if (scr>score)
    {
        score = scr;
        matched_color = YELLOW;
    }

    scr = score_white(c);
    if (scr>score)
    {
         matched_color = WHITE;            
    }

}