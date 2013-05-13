/*************************************************************************
 ** File Name: Canvas.mm
 ** Author: tsgsz
 ** Mail: cdtsgsz@gmail.com
 ** Created Time: Mon Apr 22 21:40:05 2013
 **Copyright [2013] <Copyright tsgsz>  [legal/copyright]
 ************************************************************************/

#import "Canvas.h"
#import "../Tools/OwbClientOperationQueue.h"
#import "../Models/MessageModel.h"
#import "../Models/BoardModel.h"

@implementation Canvas
@synthesize dataSource_ = _dataSource_;
@synthesize displayerDelegate_ = _displayerDelegate_;
@synthesize drawerDelegate_ = _drawerDelegate_;
@synthesize isDrawable_ = _isDrawable_;

- (void) display
{
    [_displayerDelegate_ displayerWillRefresh:_dataSource_];
}

- (void) drawOp:(OwbClientOperation*)op {
}

- (void)dealloc {
    [super dealloc];
    if(nil != _dataSource_) {
        [_dataSource_ release];
    }
    if(nil != _displayerDelegate_) {
        [_displayerDelegate_ release];
    }
    if(nil != _drawerDelegate_) {
        [_drawerDelegate_ release];
    }
}

@end
