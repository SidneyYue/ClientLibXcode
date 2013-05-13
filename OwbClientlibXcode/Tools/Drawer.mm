/*************************************************************************
     ** File Name: Drawer.mm
    ** Author: tsgsz
    ** Mail: cdtsgsz@gmail.com
    ** Created Time: Mon Apr 22 16:02:52 2013
    **Copyright [2013] <Copyright tsgsz>  [legal/copyright]
 ************************************************************************/

#import "./Drawer.h"
#import "../Models/MessageModel.h"
#import "./ColorMaker.h"
#import "../SupportFiles/common.h"
#import "./OwbClientOperationQueue.h"

#define DRAWER_CHECK_TYPE(type, Op_type)            \
if (Op_type != OwbOperationDataType_##type)   \
    @throw [NSException exceptionWithName:@"錯誤的類型" reason:@"..." userInfo:nil]

#define Y(y) y
#define midPoint(a, b) CGPointMake((a.x+b.x)/2,(a.y+b.y)/2)


#pragma mark - LineDrawer

int findTheFirst1InNum(int32_t num) {
    for (int i = 1; i <= 32; i ++) {
        if (0 != ((num>>(i-1)) & 1)) {
            return i;
        }
    }
    return -1;
}

static LineDrawer* line_draw_ = nil;
@implementation LineDrawer

+ (id<OwbClientDrawer>) sharedOwbClientDrawer {
    if (nil == line_draw_) {
        line_draw_ = [[LineDrawer alloc]init];
    }
    return line_draw_;
}

- (void)draw:(OwbClientOperation *)operation InCanvas:(CGContextRef)canvas WithResourceId:(int)rid
{
    DRAWER_CHECK_TYPE(LINE, [operation operationType_]);
    DrawLine* op = (DrawLine *) operation;
    // 設置畫線的屬性

    CGColorRef tmpColorRef = Kingslanding::OnlineWhiteBoard::Client::Tools::CGColorMake([op color_], [op alpha_]);
    CGContextSetStrokeColorWithColor(canvas, tmpColorRef);
    CGContextSetLineCap(canvas, kCGLineCapRound);
    CGContextSetLineWidth(canvas, [op thinkness_]);
    CGContextSetAlpha(canvas, [op alpha_]);
    
    // 將線條畫在畫布上
    CGContextMoveToPoint(canvas, [op startPoint_].x, Y([op startPoint_].y));
    CGContextAddLineToPoint(canvas, [op endPoint_].x, Y([op endPoint_].y));
    CGContextStrokePath(canvas);

    CGColorRelease(tmpColorRef);
}

- (void)sliceOpertion:(OwbClientOperation *)operation IntoQueue:(OwbClientOperationQueue*) queue
{
    DRAWER_CHECK_TYPE(LINE, operation.operationType_);
    [queue enqueue:operation];
}
@end

#pragma mark - EllipseDrawer

static EllipseDrawer* ellipse_draw_ = nil;

@implementation EllipseDrawer

+ (id<OwbClientDrawer>) sharedOwbClientDrawer {
    if (nil == ellipse_draw_) {
        ellipse_draw_ = [[EllipseDrawer alloc]init];
    }
    return ellipse_draw_;
}

- (void)draw:(OwbClientOperation *)operation InCanvas:(CGContextRef)canvas WithResourceId:(int)rid
{
    DRAWER_CHECK_TYPE(ELLIPSE, operation.operationType_);
    DrawEllipse* op = (DrawEllipse*) operation;
    CGContextSetAlpha(canvas, op.alpha_);
    CGRect ellipse_rect = CGRectMake([op center_].x-op.a_, Y([op center_].y)-[op b_], [op a_]*2, [op b_]*2);
    CGColorRef tmpColorRef = Kingslanding::OnlineWhiteBoard::Client::Tools::CGColorMake([op color_], [op alpha_]);
    if (op.fill_) {
        CGContextSetFillColorWithColor(canvas, tmpColorRef);
        CGContextFillEllipseInRect(canvas, ellipse_rect);
    } else {
        CGContextSetStrokeColorWithColor(canvas, tmpColorRef);
        CGContextSetLineWidth(canvas, [op thinkness_]);
        CGContextStrokeEllipseInRect(canvas, ellipse_rect);
    }
    CGColorRelease(tmpColorRef);
}

- (void)sliceOpertion:(OwbClientOperation *)operation IntoQueue:(OwbClientOperationQueue*) queue
{
    DRAWER_CHECK_TYPE(ELLIPSE, [operation operationType_]);
    [queue enqueue:operation];
}

@end

#pragma mark - RectangeDrawer
static RectangeDrawer* rect_draw_ = nil;

@implementation RectangeDrawer

+ (id<OwbClientDrawer>) sharedOwbClientDrawer {
    if (nil == rect_draw_) {
        rect_draw_ = [[RectangeDrawer alloc]init];
    }
    return rect_draw_;
}

- (void)draw:(OwbClientOperation *)operation InCanvas:(CGContextRef)canvas WithResourceId:(int)rid
{
    DRAWER_CHECK_TYPE(RECTANGE, operation.operationType_);
    DrawRectange* op = (DrawRectange*) operation;
    CGContextSetAlpha(canvas, [op alpha_]);
    CGRect rect = CGRectMake([op bottomRightCorner_].x, Y([op bottomRightCorner_].y), ([op topLeftCorner_].x - [op bottomRightCorner_].x), (Y([op topLeftCorner_].y) - Y([op bottomRightCorner_].y)));
    CGColorRef tmpColorRef = Kingslanding::OnlineWhiteBoard::Client::Tools::CGColorMake([op color_], [op alpha_]);

    if ([op fill_]) {
        CGContextSetFillColorWithColor(canvas, tmpColorRef);
        CGContextFillRect(canvas, rect);
    } else {
        CGContextSetStrokeColorWithColor(canvas, tmpColorRef);
        CGContextSetLineWidth(canvas, [op thinkness_]);
        CGContextStrokeRect(canvas, rect);
    }
    CGColorRelease(tmpColorRef);
}

- (void)sliceOpertion:(OwbClientOperation *)operation IntoQueue:(OwbClientOperationQueue*) queue
{
    DRAWER_CHECK_TYPE(RECTANGE, [operation operationType_]);
    [queue enqueue:operation];
}

@end

@interface PointResource : NSObject {
    CGPoint* startPoint_;
    CGPoint* point1_;
    CGPoint* point2_;
    int32_t using_mask;
    NSRecursiveLock* locker;
    int register_time;
}
- (CGPoint) startPoint:(int) rid;
- (void) setStartPoint:(CGPoint) p Rid:(int)rid;
- (CGPoint) point1:(int) rid;
- (void) setPoint1:(CGPoint) p Rid:(int) rid;
- (CGPoint) point2:(int) rid;
- (void) setPoint2:(CGPoint) p Rid:(int) rid;
- (int) registerResource;
- (bool) checkRid:(int) rid;
- (bool) unRegisterResouce:(int) rid;
@end

@implementation PointResource

- (id) init{
    self = [super init];
    if (nil != self) {
        point1_ = new CGPoint[MAX_RESOURCE_NUM];
        point2_ = new CGPoint[MAX_RESOURCE_NUM];
        startPoint_ = new CGPoint[MAX_RESOURCE_NUM];
        using_mask = 0xFF;
        locker = [[NSRecursiveLock alloc]init];
        register_time = 0;
    }
    return self;
}

- (int) registerResource{
    [locker lock];
    int rid = findTheFirst1InNum(using_mask);
    register_time ++;
    if (rid != -1) {
        using_mask &= (0XFF<<rid);
    }
    [locker unlock];
    return rid;
}

- (bool) checkRid:(int)rid {
    if (rid == -1) {
        return false;
    }
    return 0==(using_mask & (1<<(rid-1)));
}

- (bool) unRegisterResouce:(int)rid {
    [locker lock];
    if (![self checkRid:rid]) {
        [locker unlock];
        return false;
    }
    using_mask &= (0XFF ^ (1<<(rid-1)));
    [locker unlock];
    return true;
}

- (CGPoint) startPoint:(int) rid {
    return startPoint_[rid];
}
- (void) setStartPoint:(CGPoint) p Rid:(int)rid {
    startPoint_[rid] = p;
}
- (CGPoint) point1:(int) rid {
    return point1_[rid];
}
- (void) setPoint1:(CGPoint) p Rid:(int)rid {
    point1_[rid] = p;
}
- (CGPoint) point2:(int) rid {
    return point2_[rid];
}
- (void) setPoint2:(CGPoint) p Rid:(int)rid {
    point2_[rid] = p;
}
- (void) dealloc{
    [super dealloc];
    if (NULL != point1_) {
        delete point1_;
    }
    if (NULL != point2_) {
        delete point2_;
    }
    if (NULL != startPoint_) {
        delete startPoint_;
    }
    if (nil != locker) {
        [locker release];
    }
}

@end

#pragma mark - PointDrawer
static PointDrawer* point_draw_ = nil;
@implementation PointDrawer

+ (id<OwbClientDrawer>) sharedOwbClientDrawer {
    if (nil == point_draw_) {
        point_draw_ = [[PointDrawer alloc]init];
    }
    return point_draw_;
}

- (id)init {
    self = [super init];
    if (nil != self) {
        resource = [[PointResource alloc]init];
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
    if (nil != resource) {
        [resource release];
    }
}

- (void)draw:(OwbClientOperation *)operation InCanvas:(CGContextRef)canvas WithResourceId:(int)rid
{
    DRAWER_CHECK_TYPE(POINT, [operation operationType_]);
    if (![resource checkRid:rid]) {
        @throw [NSException exceptionWithName:@"rid unavaible" reason:@"rid not register" userInfo:nil];
    }
    DrawPoint* op = (DrawPoint *) operation;
    if ([op isStart_]) {
        [resource setPoint1:[op position_] Rid:rid];
        [resource setPoint2:[op position_] Rid:rid];
        [resource setStartPoint:[op position_] Rid:rid];
    }
    CGColorRef tmpColorRef = Kingslanding::OnlineWhiteBoard::Client::Tools::CGColorMake([op color_], [op alpha_]);
    CGContextSetStrokeColorWithColor(canvas, tmpColorRef);
    CGContextSetLineCap(canvas, kCGLineCapRound);
    CGContextSetLineWidth(canvas, [op thinkness_]);
    CGContextSetAlpha(canvas, [op alpha_]);
    CGContextMoveToPoint(canvas, [resource startPoint:rid].x, [resource startPoint:rid].y);
    CGContextAddQuadCurveToPoint(canvas, [resource point2:rid].x, [resource point2:rid].y, ([resource point2:rid].x+[op position_].x)/2, ([resource point2:rid].y+[op position_].y)/2);
    [resource setPoint1:[resource point2:rid] Rid:rid];
    [resource setPoint2:op.position_ Rid:rid];
    [resource setStartPoint:midPoint([resource point1:rid], [resource point2:rid]) Rid:rid];
    CGContextStrokePath(canvas);
    CGColorRelease(tmpColorRef);
}

- (int) registerDataSource{
    return [resource registerResource];
}

- (bool) unregisterDataSource:(int)rid {
    return [resource unRegisterResouce:rid];
}

- (void)sliceOpertion:(OwbClientOperation *)operation IntoQueue:(OwbClientOperationQueue*) queue
{
    DRAWER_CHECK_TYPE(POINT, [operation operationType_]);
    [queue enqueue:operation];
}
@end

@interface EraserResource : NSObject {
    CGPoint* startPoint_;
    CGPoint* point1_;
    CGPoint* point2_;
    int32_t using_mask;
    NSRecursiveLock* locker;
    int register_time;
}
- (CGPoint) startPoint:(int) rid;
- (void) setStartPoint:(CGPoint) p Rid:(int)rid;
- (CGPoint) point1:(int) rid;
- (void) setPoint1:(CGPoint) p Rid:(int) rid;
- (CGPoint) point2:(int) rid;
- (void) setPoint2:(CGPoint) p Rid:(int) rid;
- (int) registerResource;
- (bool) checkRid:(int) rid;
- (bool) unRegisterResouce:(int) rid;
@end

@implementation EraserResource

- (id) init{
    self = [super init];
    if (nil != self) {
        point1_ = new CGPoint[MAX_RESOURCE_NUM];
        point2_ = new CGPoint[MAX_RESOURCE_NUM];
        startPoint_ = new CGPoint[MAX_RESOURCE_NUM];
        using_mask = 0xFF;
        locker = [[NSRecursiveLock alloc]init];
        register_time = 0;
    }
    return self;
}

- (int) registerResource{
    [locker lock];
    int rid = findTheFirst1InNum(using_mask);
    register_time ++;
    if (rid != -1) {
        using_mask &= (0XFF<<rid);
    }
    [locker unlock];
    return rid;
}

- (bool) checkRid:(int)rid {
    if (rid == -1) {
        return false;
    }
    return 0==(using_mask & (1<<(rid-1)));
}

- (bool) unRegisterResouce:(int)rid {
    [locker lock];
    if (![self checkRid:rid]) {
        [locker unlock];
        return false;
    }
    using_mask &= (0XFF ^ (1<<(rid-1)));
    [locker unlock];
    return true;
}

- (CGPoint) startPoint:(int) rid {
    return startPoint_[rid];
}
- (void) setStartPoint:(CGPoint) p Rid:(int)rid {
    startPoint_[rid] = p;
}
- (CGPoint) point1:(int) rid {
    return point1_[rid];
}
- (void) setPoint1:(CGPoint) p Rid:(int)rid {
    point1_[rid] = p;
}
- (CGPoint) point2:(int) rid {
    return point2_[rid];
}
- (void) setPoint2:(CGPoint) p Rid:(int)rid {
    point2_[rid] = p;
}
- (void) dealloc{
    [super dealloc];
    if (NULL != point1_) {
        delete point1_;
    }
    if (NULL != point2_) {
        delete point2_;
    }
    if (NULL != startPoint_) {
        delete startPoint_;
    }
    if (nil != locker) {
        [locker release];
    }
}

@end


#pragma mark - Eraser
static Eraser* eraser_ = nil;
@implementation Eraser
+ (id<OwbClientDrawer>) sharedOwbClientDrawer {
    if (nil == eraser_) {
        eraser_ = [[Eraser alloc]init];
    }
    return eraser_;
}

- (id)init {
    self = [super init];
    if (nil != self) {
        resource = [[EraserResource alloc]init];
    }
    return self;
}

- (void)draw:(OwbClientOperation *)operation InCanvas:(CGContextRef)canvas WithResourceId:(int)rid
{
    DRAWER_CHECK_TYPE(ERASER, operation.operationType_);
    if (![resource checkRid:rid]) {
        @throw [NSException exceptionWithName:@"rid unavaible" reason:@"rid not register" userInfo:nil];
    }
    Erase* op = (Erase *) operation;
    if ([op isStart_]) {
        [resource setPoint1:[op position_] Rid:rid];
        [resource setPoint2:[op position_] Rid:rid];
        [resource setStartPoint:[op position_] Rid:rid];
    }
    CGContextSetStrokeColorWithColor(canvas, Kingslanding::OnlineWhiteBoard::Client::Tools::CGEraserColor());
    CGContextSetLineCap(canvas, kCGLineCapRound);
    CGContextSetLineWidth(canvas, [op thinkness_]);
    CGContextMoveToPoint(canvas, [resource point2:rid].x, [resource point2:rid].y);
    CGContextAddLineToPoint(canvas, [op position_].x, [op position_].y);
    [resource setPoint1:[resource point2:rid] Rid:rid];
    [resource setPoint2:op.position_ Rid:rid];
    [resource setStartPoint:midPoint([resource point1:rid], [resource point2:rid]) Rid:rid];

    CGContextStrokePath(canvas);
}

- (int) registerDataSource{
    return [resource registerResource];
}

- (bool) unregisterDataSource:(int)rid {
    return [resource unRegisterResouce:rid];
}


- (void)sliceOpertion:(OwbClientOperation *)operation IntoQueue:(OwbClientOperationQueue*) queue
{
    DRAWER_CHECK_TYPE(ERASER, [operation operationType_]);
    [queue enqueue:operation];
}

@end
