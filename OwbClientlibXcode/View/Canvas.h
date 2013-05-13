/*************************************************************************
 ** File Name: Canvas.h
 ** Author: tsgsz
 ** Mail: cdtsgsz@gmail.com
 ** Created Time: Mon Apr 22 21:40:05 2013
 **Copyright [2013] <Copyright tsgsz>  [legal/copyright]
 ************************************************************************/

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

@class OwbClientOperationQueue;
@class OwbClientOperation;
@protocol DisplayerDataSource;

@protocol DisplayerDelegate <NSObject>

- (void)displayerWillRefresh:(id<DisplayerDataSource>) dataSouce_;
- (void)scaleDisplayer:(float)scale;
- (void)moveDisplayerX:(int) x withY:(int)y;

@end

@protocol DrawerDelegate <NSObject>

- (void)attachQueue:(OwbClientOperationQueue *)queue;
@end

@interface Canvas : UIView{
@private
    id<DisplayerDataSource> _dataSource_;
    id<DisplayerDelegate> _displayerDelegate_;
    id<DrawerDelegate> _drawerDelegate_;
    BOOL _isDrawable_;
}
- (void)display;
- (void)drawOp:(OwbClientOperation*) op;
@property (nonatomic, retain) id<DisplayerDataSource> dataSource_;
@property (nonatomic, retain) id<DisplayerDelegate> displayerDelegate_;
@property (nonatomic, retain) id<DrawerDelegate> drawerDelegate_;
@property (assign) BOOL isDrawable_;
@end
