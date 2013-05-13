/*************************************************************************
    ** File Name: ColorMaker.mm
    ** Author: tsgsz
    ** Mail: cdtsgsz@gmail.com
    ** Created Time: Mon Apr 22 21:40:52 2013
    **Copyright [2013] <Copyright tsgsz>  [legal/copyright]
 ************************************************************************/

#import "./ColorMaker.h"
#import "../SupportFiles/common.h"

#define KINGSLANDING_ONLINEWHITEBOARD_CLIENT_TOOLS_COLORMAKER_ERASER_COLOR 5

namespace Kingslanding {
namespace OnlineWhiteBoard {
namespace Client {
namespace Tools {
CGFloat color_table[COLOR_NUM][4] = {
    {0.0,0.0,0.0,1.0},
    {1.0,0.0,0.0,1.0},
    {0.0,0.0,1.0,1.0},
    {1.0,1.0,0.0,1.0},
    {0.0,1.0,0.0,1.0},
    {1.0,1.0,1.0,1.0}
};


CGColorRef CGColorMake(int color_id, float alpha)
{
    color_table[color_id][3] = alpha;
    return CGColorCreate(CGColorSpaceCreateDeviceRGB(), color_table[color_id]);
}

CGColorRef CGEraserColor()
{
    return CGColorCreate(CGColorSpaceCreateDeviceRGB(), color_table[KINGSLANDING_ONLINEWHITEBOARD_CLIENT_TOOLS_COLORMAKER_ERASER_COLOR]);
}
}  // Kingslaidng
}  // OnlineWhiteBoard
}  // Client
}  // Tools
