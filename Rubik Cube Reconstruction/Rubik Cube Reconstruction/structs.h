#ifndef STRUCTS_H
#define STRUCTS_H

struct rgb{
    double r;       // percent
    double g;       // percent
    double b;       // percent
};

struct hsv{
    double h;       // angle in degrees
    double s;       // percent
    double v;       // percent
};

struct rgbcolor
{
    int r,g,b;
    rgbcolor():r(0),g(0),b(0) {}
    rgbcolor(int r, int g, int b):r(r),g(g),b(b) {}
};


#endif // STRUCTS_H
