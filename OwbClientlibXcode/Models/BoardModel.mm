/*************************************************************************
 ** File Name: BoardModel.mm
 ** Author: tsgsz
 ** Mail: cdtsgsz@gmail.com
 ** Created Time: Tue Apr 16 20:07:05 2013
 **Copyright [2013] <Copyright tsgsz>  [legal/copyright]
 ************************************************************************/
#import "./BoardModel.h"
#import "../Tools/OwbClientOperationQueue.h"
#import "../SupportFiles/common.h"
#import "../View/Canvas.h"
#import "./MessageModel.h"
#import "../Tools/ColorMaker.h"
#import "../Tools/Drawer.h"

#define OwbX(x) x
#define OwbY(y) (BOARD_HEIGHT*3 - y)
#define OwbScale(x) (x*scale)
#define BH(a) (BOARD_HEIGHT*a/2.0+BOARD_HEIGHT)
#define BW(a) (BOARD_WIDTH*a/2.0+BOARD_WIDTH)
#define SCALE(a) ((BH(a))/(BH(4)))

#define BOARDQUEUE "boardQueue_"

@interface BoardModel()
- (void)readOperationQueue;
- (void)drawSelf;
- (void)trigerDrawSelf;
- (OwbClientOperation*) reverseOp:(OwbClientOperation*) op;
- (OwbClientOperation*) resizeOperation:(OwbClientOperation*) op WithScale:(float) scale;
@end

static BoardModel* boardInstance = nil;

@implementation BoardModel

- (id) init
{
    self = [super init];
    if (nil != self) {
        boardOpQueue = dispatch_queue_create(BOARDQUEUE, NULL);
        context_ = new CGContextRef[BOARD_NUM];
        contextRid_ = new int*[BOARD_NUM];
        latestSnapshot_ = new CGImageRef[BOARD_NUM];
        for (int i=0; i<BOARD_NUM; i++) {
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            
            context_[i] = CGBitmapContextCreate(NULL, BW(i), BH(i), BOARD_BITS_PER_COMPONENT, BOARD_BYTES_PER_PER_ROW, colorSpace, kCGImageAlphaPremultipliedLast);
            contextRid_[i] = new int[5];
            contextRid_[i][OwbOperationDataType_POINT] = [[PointDrawer sharedOwbClientDrawer]registerDataSource];
            contextRid_[i][OwbOperationDataType_ERASER] = [[Eraser sharedOwbClientDrawer]registerDataSource];
            CFRelease(colorSpace);
            CGContextSetAlpha(context_[i], 1.0);
            CGContextBeginPath(context_[i]);
            CGContextSetFillColorWithColor(context_[i], Kingslanding::OnlineWhiteBoard::Client::Tools::CGEraserColor());
            CGContextClosePath(context_[i]);
            CGContextFillRect(context_[i], CGRectMake(0, 0, BW(i), BH(i)));
            latestSnapshot_[i] = CGBitmapContextCreateImage(context_[i]);
        }
        realOperationQueue_ = [[OwbClientOperationQueue alloc]init];
    }
    return self;
}

- (void) dealloc {
    [super dealloc];
    if (nil != displayer_) {
        [displayer_ release];
    }
    if (nil != operationQueue_) {
        [operationQueue_ release];
    }
    if (nil != realOperationQueue_) {
        [realOperationQueue_ release];
    }
    if (nil != boardOpQueue) {
        dispatch_release(boardOpQueue);
    }
}

+ (BoardModel *) SharedBoard
{
    if (nil == boardInstance) {
        boardInstance = [[BoardModel alloc]init];
    }
    return boardInstance;
}

- (void) attachCanvas:(Canvas *)canvas
{
    displayer_ = [canvas retain];
}

- (void) attachOpeartionQueue:(OwbClientOperationQueue *)operationQueue
{
    operationQueue_ = [operationQueue retain];
}

- (void) drawOperationBack:(OwbClientOperation *)operation
{
    for (int i = 0; i<BOARD_NUM; i++) {
       OwbClientOperation* op = [operation duplicate];
       float scale = SCALE(i);
       op = [self reverseOp:op];
       op = [self resizeOperation:op WithScale:scale];
       [[operation drawer_]draw:op InCanvas:context_[i] WithResourceId:contextRid_[i][op.operationType_]];
       [op release];
    }
    [self saveSnapshot];
}

- (void) drawOperation:(OwbClientOperation *)operation
{
    __block OwbClientOperation* op = [operation retain];
    dispatch_async(boardOpQueue, ^(void){
        [self drawOperationBack:op];
    });
    [op release];
}


- (void) loadDocumentAsync:(OwbClientDocument *)document
{
    dispatch_async(boardOpQueue, ^(void){
        __block CGImageRef image_ref = [UIImage imageWithData:document.data_].CGImage;
        for (int i = 0; i< BOARD_NUM; i++) {
            CGContextDrawImage(context_[i], CGRectMake(0, 0, BW(i), BH(i)), image_ref);
            CGContextFlush(context_[i]);
        }
        [realOperationQueue_ clear];
        [operationQueue_ clear];
        dispatch_async(dispatch_get_main_queue(), ^(void){[displayer_ display];});
    });
}

-(void) loadDocumentSync:(OwbClientDocument *)document
{
    dispatch_sync(boardOpQueue, ^(void){
        __block CGImageRef image_ref = [UIImage imageWithData:document.data_].CGImage;
        for (int i = 0; i< BOARD_NUM; i++) {
            CGContextDrawImage(context_[i], CGRectMake(0, 0, BW(i), BH(i)), image_ref);
            CGContextFlush(context_[i]);
        }
        [realOperationQueue_ clear];
        [operationQueue_ clear];
    });
    [displayer_ display];
}


- (void) saveSnapshot
{
    dispatch_async(boardOpQueue, ^(void){
        for (int i=0; i < BOARD_NUM; i++) {
            CGImageRelease(latestSnapshot_[i]);
            latestSnapshot_[i] = CGBitmapContextCreateImage(context_[i]);
        }
    });
}

- (CGImageRef) getData:(int) num
{
    return CGBitmapContextCreateImage(context_[num]);
}

- (CGImageRef) getLatestSnapshot:(int) num
{
    return  CGImageCreateCopy(latestSnapshot_[num]);
}

- (void)readOperationQueue
{
    while (true) {
        [operationQueue_ lock];
        if ([operationQueue_ isEmpty]) {
            [operationQueue_ unLock];
            return;
        }
        [operationQueue_ unLock];
        OwbClientOperation* op = [operationQueue_ dequeue];
        [op.drawer_ sliceOpertion:op IntoQueue:realOperationQueue_];
        [self trigerDrawSelf];
    }
}

- (void)trigerReadOperationQueue
{
    dispatch_async(dispatch_get_main_queue(), ^(void){[self readOperationQueue];});
}

- (void)drawSelf
{
    while (true) {
        [realOperationQueue_ lock];
        if ([realOperationQueue_ isEmpty]) {
            [realOperationQueue_ unLock];
            return;
        }
        [realOperationQueue_ unLock];
        __block OwbClientOperation* op = [realOperationQueue_ dequeue];
        [displayer_ drawOp:op];
        sleep(0.04);
    }
}

- (void)trigerDrawSelf
{
    dispatch_async(dispatch_get_main_queue(), ^(void){[self drawSelf];});
}

- (void)setInHostMode_:(bool)inHostMode
{
    displayer_.isDrawable_ = inHostMode;
    _inHostMode_ = inHostMode;
}

- (bool)inHostMode_
{
    return _inHostMode_;
}

- (OwbClientOperation*)reverseOp:(OwbClientOperation*) op {
    switch (op.operationType_) {
        case OwbOperationDataType_LINE: {
            DrawLine* top = (DrawLine*)op;
            [top setStartPoint_:CGPointMake(OwbX([top startPoint_].x),OwbY([top startPoint_].y))];
            [top setEndPoint_:CGPointMake(OwbX([top endPoint_].x), OwbY([top endPoint_].y))];
            return top;
        }
        case OwbOperationDataType_ELLIPSE: {
            DrawEllipse* top = (DrawEllipse*)op;
            [top setCenter_:CGPointMake(OwbX([top center_].x), OwbY([top center_].y))];
            return top;
        }
        case OwbOperationDataType_ERASER: {
            Erase* top = (Erase*)op;
            [top setPosition_:CGPointMake(OwbX([top position_].x), OwbY([top position_].y))];
            return top;
        }
        case OwbOperationDataType_POINT: {
            DrawPoint* top = (DrawPoint*) op;
            [top setPosition_:CGPointMake(OwbX([top position_].x), OwbY([top position_].y))];
            return top;
        }
        case OwbOperationDataType_RECTANGE: {
            DrawRectange* top = (DrawRectange*)op;
            [top setBottomRightCorner_:CGPointMake(OwbX([top bottomRightCorner_].x),OwbY([top bottomRightCorner_].y))];
            [top setTopLeftCorner_:CGPointMake(OwbX([top topLeftCorner_].x), OwbY([top topLeftCorner_].y))];
            return top;
        }
        default:
            return op;
    }
}

- (OwbClientOperation*) resizeOperation:(OwbClientOperation*) op WithScale:(float) scale {
    switch (op.operationType_) {
        case OwbOperationDataType_LINE: {
            DrawLine* top = (DrawLine*)op;
            [top setStartPoint_:CGPointMake(OwbScale([top startPoint_].x),OwbScale([top startPoint_].y))];
            [top setEndPoint_:CGPointMake(OwbScale([top endPoint_].x), OwbScale([top endPoint_].y))];
            [top setThinkness_:OwbScale([top thinkness_])];
            return top;
        }
        case OwbOperationDataType_ELLIPSE: {
            DrawEllipse* top = (DrawEllipse*)op;
            [top setCenter_:CGPointMake(OwbScale([top center_].x), OwbScale([top center_].y))];
            [top setA_:OwbScale([top a_])];
            [top setB_:OwbScale([top b_])];
            [top setThinkness_:OwbScale([top thinkness_])];
            return top;
        }
        case OwbOperationDataType_ERASER: {
            Erase* top = (Erase*)op;
            [top setPosition_:CGPointMake(OwbScale([top position_].x), OwbScale([top position_].y))];
            [top setThinkness_:OwbScale([top thinkness_])];
            return top;
        }
        case OwbOperationDataType_POINT: {
            DrawPoint* top = (DrawPoint*) op;
            [top setPosition_:CGPointMake(OwbScale([top position_].x), OwbScale([top position_].y))];
            [top setThinkness_:OwbScale([top thinkness_])];
            return top;
        }
        case OwbOperationDataType_RECTANGE: {
            DrawRectange* top = (DrawRectange*)op;
            [top setBottomRightCorner_:CGPointMake(OwbScale([top bottomRightCorner_].x),OwbScale([top bottomRightCorner_].y))];
            [top setTopLeftCorner_:CGPointMake(OwbScale([top topLeftCorner_].x), OwbScale([top topLeftCorner_].y))];
            [top setThinkness_:OwbScale([top thinkness_])];
            return top;
        }
        default:
            return op;
    }
}


@end
