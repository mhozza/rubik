#include "match_color.h"
#include "rgbhsv.h"

#include <iostream>
#include <sstream>
#include <map>
#include <vector>

using namespace std;

int main()
{
   rgbcolor col(100, 100, 100);
   rgbcolor c = match_color(col);
   cout << c.r << " " <<  c.g << " " << c.b << " " << endl;


    // vector<vector<rgbcolor> > colors(6);
    // map<string,int> color_index;
    // color_index["red"] = 0;
    // color_index["green"] = 1;
    // color_index["blue"] = 2;
    // color_index["orange"] = 3;
    // color_index["yellow"] = 4;
    // color_index["white"] = 5;

    // string s;
    // int state = 0, ind = 0;

    // while(getline(cin,s))
    // {
    //     if(s=="")
    //     {
    //         state = 0;
    //         continue;
    //     }

    //     if(state == 0)
    //     {
    //         ind = color_index[s];
    //         state = 1;
    //         continue;
    //     }

    //     if(state == 1)
    //     {
    //         int r,g,b;
    //         stringstream ss(s);
    //         ss >> r >> g >> b;
    //         rgbcolor c(r,g,b);
    //         colors[ind].push_back(c);
    //         continue;            
    //     }

    // }

    // for(int i=0;i<colors.size();i++)
    // {
    //     int ar=0,ag=0,ab=0;
    //     for(int j=0;j<colors[i].size();j++)    
    //     {
    //         // cout << colors[i][j].r << " " << colors[i][j].g << " " << colors[i][j].b << " " << endl;
    //         ar+=colors[i][j].r;
    //         ag+=colors[i][j].g;
    //         ab+=colors[i][j].b;            
    //     }
    //     cout << "Avg:" << (double)ar/colors[i].size() << " " << (double)ag/colors[i].size() << " " << (double)ab/colors[i].size() << " " << endl;
    //     cout << endl;
    // }
}
