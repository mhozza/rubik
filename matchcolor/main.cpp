#include "match_color.h"
#include "rgbhsv.h"

#include <iostream>

using namespace std;

int main()
{
    rgbcolor col(196, 0, 0);
    rgbcolor c = match_color(col);
    cout << c.r << " " <<  c.g << " " << c.b << " " << endl;
}
