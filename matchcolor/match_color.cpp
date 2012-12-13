// Function to determine which color of official rubiks cube is closest to given color

// constants: rgb | hsv

// Red: 196, 30, 58 |  0.9719, 0.8469, 196
// Green: 0, 158, 96 | 0.4346, 1, 158
// Blue: 0, 81, 186 |  0.5941, 1, 186
// Orange: 255, 88, 0 |  0.0575, 1, 255
// Yellow: 255, 213, 0 |  0.1392, 1, 255 
// White: 255, 255, 255 | 0, 0, 255

// http://www.perbang.dk/rgb/009E60/

#include "match_color.h"
#include <iostream>

rgbcolor RED(196, 30, 58);
rgbcolor RED_FAKE(131, 15, 35);
rgbcolor GREEN(0, 158, 96);
rgbcolor GREEN_FAKE(19, 89, 64);
rgbcolor BLUE(0, 81, 186);
rgbcolor BLUE_FAKE(18, 61, 106);
rgbcolor ORANGE(255, 88, 0);
rgbcolor ORANGE_FAKE(221, 56, 61);
rgbcolor YELLOW(255, 213, 0);
rgbcolor YELLOW_FAKE(219, 170, 16);
rgbcolor WHITE(255, 255, 255);
rgbcolor WHITE_FAKE(210, 200, 192);

hsv diff(hsv c,hsv o)
{
    hsv d;
    d.h = 1.0 - abs(o.h/360.0-c.h/360.0);
    d.s = 1.0 - abs(o.s-c.s);
    d.v = 1.0 - abs(o.v-c.v);
    return d;
}

double universal_score(hsv d, double wh, double ws, double wv)
{
    double res = (d.h * wh) + (d.s * ws) + (d.v * wv);    
    return res;
}

double score_red(hsv c)
{
    hsv o = rgb2hsv(RED_FAKE);
    hsv d = diff(c, o);
    return universal_score(d, 4/12.0, 4/12.0, 4/12.0);
}

double score_orange(hsv c)
{
    hsv o = rgb2hsv(ORANGE_FAKE);
    hsv d = diff(c, o);
    return universal_score(d, 4/12.0, 4/12.0, 4/12.0);
}

double score_green(hsv c)
{
    hsv o = rgb2hsv(GREEN_FAKE);
    hsv d = diff(c, o);
    return universal_score(d, 7/12.0, 2/12.0,3/12.0);
}

double score_blue(hsv c)
{
    hsv o = rgb2hsv(BLUE_FAKE);
    hsv d = diff(c, o);
    return universal_score(d, 7/12.0, 2/12.0,3/12.0);
}

double score_yellow(hsv c)
{
    hsv o = rgb2hsv(YELLOW_FAKE);
    hsv d = diff(c, o);
    return universal_score(d, 6/12.0, 3/12.0,3/12.0);
}

double score_white(hsv c)
{
    hsv o = rgb2hsv(WHITE_FAKE);
    hsv d = diff(c, o);
    return universal_score(d, 0, 8/12.0, 4/12.0);
}

rgbcolor match_color(rgbcolor color)
{
    hsv c = rgb2hsv(color);
    double score = 0, scr = 0;
    rgbcolor matched_color;

    scr = score_red(c);    
    cerr << scr << endl;
    if (scr>score)
    {
        score = scr;
        matched_color = RED;
    }

    scr = score_orange(c);
    cerr << scr << endl;
    if (scr>score)
    {
        score = scr;
        matched_color = ORANGE;
    }

    scr = score_green(c);
    cerr << scr << endl;
    if (scr>score)
    {
        score = scr;
        matched_color = GREEN;
    }

    scr = score_blue(c);
    cerr << scr << endl;
    if (scr>score)
    {
        score = scr;
        matched_color = BLUE;
    }

    scr = score_yellow(c);
    cerr << scr << endl;
    if (scr>score)
    {
        score = scr;
        matched_color = YELLOW;
    }

    scr = score_white(c);
    cerr << scr << endl;
    if (scr>score)
    {
         matched_color = WHITE;            
    }

    return matched_color;
}
