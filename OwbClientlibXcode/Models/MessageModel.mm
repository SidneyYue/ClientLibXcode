/*************************************************************************
     ** File Name: MessageModel.mm
    ** Author: tsgsz
    ** Mail: cdtsgsz@gmail.com
    ** Created Time: Tue Apr 16 20:02:28 2013
    **Copyright [2013] <Copyright tsgsz>  [legal/copyright]
 ************************************************************************/
#import "../ProtoBuffer/message.pb.h"
#import "MessageModel.h"
#import "../Tools/Drawer.h"

@implementation OwbClientOperationFactory

+ (OwbClientOperation*)CreateOperationFromOperation:(const Operation*) operation {
    switch (operation->data().data_type()) {
        case OwbOperationDataType_LINE:
            return [[DrawLine alloc]initFromOperation:operation];
        case OwbOperationDataType_ELLIPSE:
            return [[DrawEllipse alloc]initFromOperation:operation];
        case OwbOperationDataType_RECTANGE:
            return [[DrawRectange alloc]initFromOperation:operation];
        case OwbOperationDataType_POINT:
            return [[DrawPoint alloc]initFromOperation:operation];
        case OwbOperationDataType_ERASER:
            return [[Erase alloc]initFromOperation:operation];
        default:
            @throw [NSException exceptionWithName:@"未知操作類型" reason:@"未知操作類型" userInfo: nil];
            break;
    }
}

@end

@implementation OwbClientOperation

@synthesize serialNumber_ = _serialNumber_;
@synthesize operationType_ = _operationType_;
@synthesize thinkness_ = _thinkness_;
@synthesize drawer_ = _drawer_;

- (id)init {
    self = [super init];
    if(nil != self) {
        operation_ = new Operation();
        operation_->set_serial_number(0);
    }
    return self;
}

- (id)initFromOperation:(const Operation*) operation
{
    @throw [NSException exceptionWithName:@"無法初始化異常" reason:@"這是一個抽象類，無法初始化" userInfo: nil];
    return self;
}

- (OwbClientOperation*)duplicate{
    @throw [NSException exceptionWithName:@"無法初始化異常" reason:@"這是一個抽象類，無法複製" userInfo: nil];
    return nil;
}

- (void)dealloc {
    [super dealloc];
    /*if (nil != _drawer_) {
        [_drawer_ release];
    }*/
    if (NULL != operation_) {
        delete operation_;
    }
}

- (Operation) toOperation
{
    return *operation_;
}

- (int)serialNumber_
{
    return operation_->serial_number();
}

- (void)setSerialNumber_:(int)serialNumber
{
    operation_->set_serial_number(serialNumber);
}

- (enum OwbOperationDataType)operationType_
{
    return (enum OwbOperationDataType)operation_->data().data_type();
}

- (void)setOperationType_:(enum OwbOperationDataType)operationType
{
    operation_->mutable_data()->set_data_type(
        (enum Operation_OperationData_OperationDataType)operationType);
}

- (int)thinkness_
{
    return operation_->data().thinkness();
}

- (void)setThinkness_:(int)thinkness
{
    operation_->mutable_data()->set_thinkness(thinkness);
}

@end

@implementation DrawLine

@synthesize color_ = _color_;
@synthesize alpha_ = _alpha_;
@synthesize startPoint_ = _startPoint_;
@synthesize endPoint_ = _endPoint_;

- (id)init
{
    self = [super init];
    if (nil != self) {
        self.operationType_ = OwbOperationDataType_LINE;
        self.drawer_ = [LineDrawer sharedOwbClientDrawer];
    }
    return self;
}

- (id)initFromOperation:(const Operation *)operation
{
    self = [self init];
    if (nil != self) {
        *operation_ = *operation;
    }
    return self;
}

- (int)color_
{
    return operation_->data().color();
}

- (void)setColor_:(int)color
{
    operation_->mutable_data()->set_color(color);
}

- (float)alpha_
{
    return operation_->data().alpha();
}

- (void)setAlpha_:(float)alpha
{
    operation_->mutable_data()->set_alpha(alpha);
}

- (CGPoint)startPoint_
{
    return CGPointMake(operation_->data().start_point().x(), operation_->data().start_point().y());
}

- (void)setStartPoint_:(CGPoint)startPoint
{
    operation_->mutable_data()->mutable_start_point()->set_x(startPoint.x);
    operation_->mutable_data()->mutable_start_point()->set_y(startPoint.y);
}

- (CGPoint)endPoint_
{
    return CGPointMake(operation_->data().end_point().x(), operation_->data().end_point().y());
}

- (void)setEndPoint_:(CGPoint)endPoint
{
    operation_->mutable_data()->mutable_end_point()->set_x(endPoint.x);
    operation_->mutable_data()->mutable_end_point()->set_y(endPoint.y);
}

- (OwbClientOperation*)duplicate{
    return [[DrawLine alloc]initFromOperation:operation_];
}

@end

@implementation DrawEllipse

@synthesize color_ = _color_;
@synthesize alpha_ = _alpha_;
@synthesize center_ = _center_;
@synthesize a_ = _a_;
@synthesize b_ = _b_;

- (id)init
{
    self = [super init];
    if (nil != self) {
        self.operationType_ = OwbOperationDataType_ELLIPSE;
        self.drawer_ = [EllipseDrawer sharedOwbClientDrawer];
    }
    return self;
}

- (id)initFromOperation:(const Operation *)operation
{
    self = [self init];
    if (nil != self) {
        *operation_ = *operation;
    }
    return self;
}

- (int)color_
{
    return operation_->data().color();
}

- (void)setColor_:(int)color
{
    operation_->mutable_data()->set_color(color);
}

- (float)alpha_
{
    return operation_->data().alpha();
}

- (void)setAlpha_:(float)alpha
{
    operation_->mutable_data()->set_alpha(alpha);
}

- (bool)fill_
{
    return operation_->data().fill();
}

- (void)setFill_:(bool)fill
{
    operation_->mutable_data()->set_fill(fill);
}

- (CGPoint)center_
{
    return CGPointMake(operation_->data().center().x(), operation_->data().center().y());
}

- (void)setCenter_:(CGPoint)center
{
    operation_->mutable_data()->mutable_center()->set_x(center.x);
    operation_->mutable_data()->mutable_center()->set_y(center.y);
}

- (float)a_
{
    return operation_->data().a();
}

- (void)setA_:(float)a
{
    operation_->mutable_data()->set_a(a);
}

- (float)b_
{
    return operation_->data().b();
}

- (void)setB_:(float)b
{
    operation_->mutable_data()->set_b(b);
}

- (OwbClientOperation*)duplicate{
    return [[DrawEllipse alloc]initFromOperation:operation_];
}

@end

@implementation DrawRectange

@synthesize color_ = _color_;
@synthesize alpha_ = _alpha_;
@synthesize topLeftCorner_ = _topLeftCorner_;
@synthesize bottomRightCorner_ = _bottomRightCorner_;

- (id)init
{
    self = [super init];
    if (nil != self) {
        self.operationType_ = OwbOperationDataType_RECTANGE;
        self.drawer_ = [RectangeDrawer sharedOwbClientDrawer];
    }
    return self;
}

- (id)initFromOperation  :(const Operation *)operation
{
    self = [self init];
    if (nil != self) {
        *operation_ = *operation;
    }
    return self;
}

- (int)color_
{
    return operation_->data().color();
}

- (void)setColor_:(int)color
{
    operation_->mutable_data()->set_color(color);
}

- (float)alpha_
{
    return operation_->data().alpha();
}

- (void)setAlpha_:(float)alpha
{
    operation_->mutable_data()->set_alpha(alpha);
}

- (bool)fill_
{
    return operation_->data().fill();
}

- (void)setFill_:(bool)fill
{
    operation_->mutable_data()->set_fill(fill);
}

- (CGPoint)topLeftCorner_
{
    return CGPointMake(operation_->data().top_left_corner().x(), operation_->data().top_left_corner().y());
}

- (void)setTopLeftCorner_:(CGPoint)topLeftCorner
{
    operation_->mutable_data()->mutable_top_left_corner()->set_x(topLeftCorner.x);
    operation_->mutable_data()->mutable_top_left_corner()->set_y(topLeftCorner.y);
}

- (CGPoint)bottomRightCorner_
{
    return CGPointMake(operation_->data().bottom_right_corner().x(), operation_->data().bottom_right_corner().y());
}

- (void)setBottomRightCorner_:(CGPoint)bottomRightCorner
{
    operation_->mutable_data()->mutable_bottom_right_corner()->set_x(bottomRightCorner.x);
    operation_->mutable_data()->mutable_bottom_right_corner()->set_y(bottomRightCorner.y);
}

- (OwbClientOperation*)duplicate{
    return [[DrawRectange alloc]initFromOperation:operation_];
}

@end

@implementation DrawPoint

@synthesize color_ = _color_;
@synthesize alpha_ = _alpha_;
@synthesize position_ = _position_;
@synthesize isStart_ = _isStart_;

- (id)init
{
    self = [super init];
    if (nil != self) {
        self.operationType_ = OwbOperationDataType_POINT;
        self.drawer_ = [PointDrawer sharedOwbClientDrawer];
    }
    return self;
}

- (id)initFromOperation  :(const Operation *)operation
{
    self = [self init];
    if (nil != self) {
        *operation_ = *operation;
//        NSLog(@"op's thickness %d",self.thinkness_);
    }
    return self;
}

- (int)color_
{
    return operation_->data().color();
}

- (void)setColor_:(int)color
{
    operation_->mutable_data()->set_color(color);
}

- (float)alpha_
{
    return operation_->data().alpha();
}

- (void)setAlpha_:(float)alpha
{
    operation_->mutable_data()->set_alpha(alpha);
}

- (CGPoint)position_
{
    return CGPointMake(operation_->data().position().x(), operation_->data().position().y());
}

- (void)setPosition_:(CGPoint)position
{
    operation_->mutable_data()->mutable_position()->set_x(position.x);
    operation_->mutable_data()->mutable_position()->set_y(position.y);
}

- (bool)isStart_
{
    return operation_->data().is_start();
}

- (void)setIsStart_:(bool)isStart
{
    operation_->mutable_data()->set_is_start(isStart);
}

- (OwbClientOperation*)duplicate{
    return [[DrawPoint alloc]initFromOperation:operation_];
}

@end

@implementation Erase

@synthesize position_ = _position_;
@synthesize isStart_ = _isStart_;
- (id)init
{
    self = [super init];
    if (nil != self) {
        self.operationType_ = OwbOperationDataType_ERASER;
        self.drawer_ = [Eraser sharedOwbClientDrawer];
    }
    return self;
}

- (id)initFromOperation  :(const Operation *)operation
{
    self = [self init];
    if (nil != self) {
        *operation_ = *operation;
    }
    return self;
}

- (CGPoint)position_
{
    return CGPointMake(operation_->data().position().x(), operation_->data().position().y());
}

- (void)setPosition_:(CGPoint)position
{
    operation_->mutable_data()->mutable_position()->set_x(position.x);
    operation_->mutable_data()->mutable_position()->set_y(position.y);
}

- (bool)isStart_
{
    return operation_->data().is_start();
}

- (void)setIsStart_:(bool)isStart
{
    operation_->mutable_data()->set_is_start(isStart);
}

- (OwbClientOperation*)duplicate{
    return [[Erase alloc]initFromOperation:operation_];
}

@end

@implementation OwbClientDocument

@synthesize serialNumber_ = _serialNumber_;
@synthesize data_ = _data_;

- (id)init {
    self = [super init];
    if (nil != self) {
        document_ = new Document();
    }
    return self;
}

- (id)initFromDocument  :(const Document *)document
{
    self = [self init];
    if (nil != self) {
        *document_ = *document;
    }
    return self;
}

- (int)serialNumber_
{
    return document_->serial_number();
}

- (NSData*)data_
{
    return [NSData dataWithBytes:document_->data().c_str() length:document_->data().length()*sizeof(char)];
}

- (void)dealloc {
    [super dealloc];
    if (NULL != document_) {
        delete document_;
    }
}

@end

@implementation OwbClientUser

@synthesize userName_ = _userName_;
@synthesize passWord_ = _passWord_;
@synthesize identity_ = _identity_;

- (id)init {
    self = [super init];
    if (nil != self) {
        user_ = new User();
    }
    return self;
}

- (id)initFromUser  :(const User *)user
{
    self = [self init];
    if (nil != self) {
        *user_ = *user;
    }
    return self;
}

- (User)toUser
{
    return *user_;
}

- (NSString*)userName_
{
    return [NSString stringWithUTF8String:user_->user_name().c_str()];
}

- (void)setUserName_:(NSString *)userName
{
    user_->set_user_name([userName UTF8String]);
}

- (NSString*)passWord_
{
    return [NSString stringWithUTF8String:user_->password().c_str()];
}

- (void)setPassWord_:(NSString *)passWord
{
    user_->set_password([passWord UTF8String]);
}

- (enum OwbIdentity)identity_
{
    return (enum OwbIdentity)user_->identity();
}

- (void)setOwbIdentity_:(enum OwbIdentity)identity
{
    user_->set_identity((enum Identity)identity);
}

- (void)dealloc {
    [super dealloc];
    if (NULL != user_) {
        delete user_;
    }
}


@end

@implementation OwbClientHeartReturnPackage

@synthesize identity_ = _identity_;

- (id)init {
    self = [super init];
    if (nil != self) {
        package_ = new HeartReturnPackage();
    }
    return self;
}

- (id)initFromRPac  :(const HeartReturnPackage *)hb_package
{
    self = [self init];
    if (nil != self) {
        *package_ = *hb_package;
    }
    return self;
}

- (enum OwbIdentity)identity_
{
    return (OwbIdentity)package_->identity();
}

- (void)dealloc {
    [super dealloc];
    if (NULL != package_) {
        delete package_;
    }
}

@end

@implementation OwbClientHeartSendPackage

@synthesize userName_ = _userName_;
@synthesize meetingId_ = _meetingId_;

- (id)init {
    self = [super init];
    if (nil != self) {
        package_ = new HeartBeatSendPackage();
    }
    return self;
}

- (HeartBeatSendPackage)toSPac
{
    return *package_;
}

- (NSString*)userName_
{
    return [NSString stringWithUTF8String:package_->user_name().c_str()];
}

- (void)setUserName_:(NSString *)userName
{
    package_->set_user_name([userName UTF8String]);
}

- (NSString*)meetingId_
{
    return [NSString stringWithUTF8String:package_->meeting_id().c_str()];
}

- (void)setMeetingId_:(NSString *)meetingId
{
    package_->set_meeting_id([meetingId UTF8String]);
}

@end

@implementation OwbClientJoinMeetingReturn

@synthesize joinState_ = _joinState_;
@synthesize port_ = _port_;
@synthesize serverIp_ = _serverIp_;

- (id)init {
    self = [super init];
    if (nil != self) {
        package_ = new JoinMeetingReturn();
    }
    return self;
}

- (id)initFromJoinPac  :(const JoinMeetingReturn *)re_package
{
    self = [self init];
    if (nil != self) {
        *package_ = *re_package;
    }
    return self;
}

- (enum OwbJoinState)joinState_
{
    return (enum OwbJoinState)package_->join_state();
}

- (int)port_
{
    return package_->server_info().port();
}

- (NSString*)serverIp_
{
    return [NSString stringWithUTF8String:package_->server_info().server_ip().c_str()];
}

@end

@implementation OwbClientOperationList

@synthesize operationAvaliable_ = _operationAvaliable_;
@synthesize operationList_ = _operationList_;

- (id)initFromOperationList:(const Operations *)operations
{
    self = [self init];
    if (nil != self) {
        _operationList_ = [[NSMutableArray alloc]init];
        for (int i = 0; i < operations->operations_size(); ++i)
        {
//            NSLog(@"pboperation thickness : %d",operations->operations(i).data().thinkness());
            [(NSMutableArray*) _operationList_ addObject:[OwbClientOperationFactory CreateOperationFromOperation:&operations->operations(i)]];

        }
        _operationAvaliable_ = (enum OwbOperationAvaliable)operations->operation_avaliable();
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
    if(nil != _operationList_) {
        [_operationList_ release];
    }
}

@end

@implementation OwbClientDocumentList

@synthesize documentList_ = _documentList_;

- (id)initFromDocumentList:(const DocumentList *)documentList
{
    self = [self init];
    if (nil != self) {
        _documentList_ = [[NSMutableArray alloc]init];
        NSMutableArray* _docList_ = (NSMutableArray*) _documentList_;
        for (int i = 0; i < documentList->history_document_size(); ++i) {
            const Document* t_doc = &(documentList->history_document(i));
            OwbClientDocument* doc = [[OwbClientDocument alloc]initFromDocument:t_doc];
            [_docList_ addObject:doc];
            [doc release];
        }
  //      [_docList_ release];
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
    if(nil != _documentList_) {
        [_documentList_ release];
    }
}


@end

@implementation OwbClientUserList

@synthesize userList_ = _userList_;

- (id)initFromUserList:(const UserList *)userList
{
    self = [self init];
    if (nil != self) {
        _userList_ = [[NSMutableArray alloc]init];
        NSMutableArray* _uList_ = (NSMutableArray*) _userList_;
        for (int i = 0; i < userList->users_size(); ++i)
        {
            const User* t_user = &(userList->users(i));
            OwbClientUser* user = [[OwbClientUser alloc]initFromUser:t_user];
            [_uList_ addObject:user];
            [user release];
        }
//        [_uList_ release];
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
    if(nil != _userList_) {
        [_userList_ release];
    }
}


@end
