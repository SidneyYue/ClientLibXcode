/*************************************************************************
     ** File Name: ColorMaker.h
    ** Author: tsgsz
    ** Mail: cdtsgsz@gmail.com
    ** Created Time: Mon Apr 22 21:40:05 2013
    **Copyright [2013] <Copyright tsgsz>  [legal/copyright]
 ************************************************************************/
#ifndef KINGSLANDING_ONLINEWHITEBOARD_CLIENT_TOOLS_COLORMAKER_H_
#define KINGSLANDING_ONLINEWHITEBOARD_CLIENT_TOOLS_COLORMAKER_H_

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>


namespace Kingslanding {
namespace OnlineWhiteBoard {
namespace Client {
namespace Tools {

extern CGColorRef CGColorMake(int color, float alpha);

extern CGColorRef CGEraserColor();

}  // Kingslaidng
}  // OnlineWhiteBoard
}  // Client
}  // Tools

#endif // KINGSLANDING_ONLINEWHITEBOARD_CLIENT_TOOLS_COLORMAKER_H_
