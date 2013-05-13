/*************************************************************************
     ** File Name: BoardModel.h
    ** Author: tsgsz
    ** Mail: cdtsgsz@gmail.com
    ** Created Time: Tue Apr 16 20:07:05 2013
    **Copyright [2013] <Copyright tsgsz>  [legal/copyright]
 ************************************************************************/
#ifndef KINGSLANDING_ONLINEWHITEBOARD_CLIENT_MODELS_BOARDMODEL_H_
#define KINGSLANDING_ONLINEWHITEBOARD_CLIENT_MODELS_BOARDMODEL_H_

#import <CoreGraphics/CoreGraphics.h>

@class Canvas;
@class OwbClientDocument;
@class OwbClientOperation;
@class OwbClientOperationQueue;
@protocol DisplayerDataSource <NSObject>

- (CGImageRef)getData:(int) num;
- (CGImageRef)getLatestSnapshot:(int) num;
- (void)saveSnapshot;

@end

@interface BoardModel : NSObject <DisplayerDataSource> {
@private
    __block CGContextRef* context_;
    __block CGImageRef* latestSnapshot_;
    __block Canvas* displayer_;
    __block OwbClientOperationQueue* operationQueue_;
    __block OwbClientOperationQueue* realOperationQueue_;
    __block bool _inHostMode_;
    __block int** contextRid_;
    dispatch_queue_t boardOpQueue;
}
+ (BoardModel *) SharedBoard;
- (void) attachCanvas:(Canvas* ) canvas;
- (void) attachOpeartionQueue:(OwbClientOperationQueue *) operationQueue;
- (void) loadDocumentAsync:(OwbClientDocument *) document;
- (void) loadDocumentSync:(OwbClientDocument *)document;
- (void) trigerReadOperationQueue;
- (void) drawOperation:(OwbClientOperation *)operation;
@property (assign) bool inHostMode_;
@end

#endif  // KINGSLANDING_ONLINEWHITEBOARD_CLIENT_MODELS_BOARDMODEL_H_
