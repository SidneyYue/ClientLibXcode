/*************************************************************************
     ** File Name: Drawer.h
    ** Author: tsgsz
    ** Mail: cdtsgsz@gmail.com
    ** Created Time: Wed Apr 17 14:25:42 2013
    **Copyright [2013] <Copyright tsgsz>  [legal/copyright]
 ************************************************************************/
#ifndef KINGSLANDING_ONLINEWHITEBOARD_CLIENT_TOOLS_DRAWER_H_
#define KINGSLANDING_ONLINEWHITEBOARD_CLIENT_TOOLS_DRAWER_H_

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@class OwbClientOperation;
@class OwbClientOperationQueue;

@class PointResource;
@class EraserResource;

@protocol OwbClientDrawer <NSObject>
@required
- (void)draw:(OwbClientOperation *)operation InCanvas:(CGContextRef)canvas WithResourceId:(int) rid;
- (void)sliceOpertion:(OwbClientOperation *)operation IntoQueue:(OwbClientOperationQueue*) queue;
+ (id<OwbClientDrawer>) sharedOwbClientDrawer;

@optional
- (int)registerDataSource;
- (bool)unregisterDataSource:(int) rid;

@end

@interface LineDrawer : NSObject <OwbClientDrawer>
@end

@interface EllipseDrawer : NSObject <OwbClientDrawer>
@end

@interface RectangeDrawer : NSObject <OwbClientDrawer>
@end

@interface PointDrawer : NSObject <OwbClientDrawer>
{
    PointResource* resource;
}
@end

@interface Eraser : NSObject <OwbClientDrawer>
{
    EraserResource* resource;
}
@end

#endif  // KINGSLANDING_ONLINEWHITEBOARD_CLIENT_TOOLS_DRAWER_H_
