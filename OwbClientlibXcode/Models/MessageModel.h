/*************************************************************************
     ** File Name: Models.h
    ** Author: tsgsz
    ** Mail: cdtsgsz@gmail.com
    ** Created Time: Tue Apr 16 14:29:39 2013
    **Copyright [2013] <Copyright tsgsz>  [legal/copyright]
 ************************************************************************/

#ifndef KINGSLANDING_ONLINEWHITEBOARD_CLIENT_MODELS_MESSAGEMODEL_H_
#define KINGSLANDING_ONLINEWHITEBOARD_CLIENT_MODELS_MESSAGEMODEL_H_

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>


enum OwbOperationDataType {
  OwbOperationDataType_LINE = 0,
  OwbOperationDataType_ELLIPSE = 1,
  OwbOperationDataType_RECTANGE = 2,
  OwbOperationDataType_POINT = 3,
  OwbOperationDataType_ERASER = 4
};

enum OwbIdentity {
  OwbHOST = 1,
  OwbCANDIDATE = 2,
  OwbPARTICIPANTS = 3
};
enum OwbJoinState {
  OwbSUCCESS = 1,
  OwbFAIL = 2,
  OwbNOTAVAILABLE = 3,
  OwbDEAD = 4
};

enum OwbOperationAvaliable {
    OwbNOT_AVALIABLE = 1,
    OwbLOAD_DOCUMENT = 2,
    OwbAVALIBLE = 3,
    OwbNOT_UPDATE = 4
};

class Document;
class User;
class Operation;
class HeartReturnPackage;
class HeartBeatSendPackage;
class JoinMeetingReturn;
class Operations;
class UserList;
class DocumentList;

@class OwbClientOperation;
@class OwbClientOperationQueue;

@protocol OwbClientDrawer;


# pragma mark - DocumentModel
@interface OwbClientDocument : NSObject {
    Document* document_;
    int _serialNumber_;
    NSData* _data_;
}
- (id)initFromDocument:(const Document*) document;
@property (nonatomic, readonly, assign) int serialNumber_;
@property (nonatomic, readonly, retain) NSData* data_; 
@end

# pragma mark - UserModel
@interface OwbClientUser : NSObject {
    User* user_;
    NSString* _userName_;
    NSString* _passWord_;
    enum OwbIdentity _identity_;
}
- (id)initFromUser:(const User *)user;
- (User)toUser;
@property (nonatomic, copy) NSString* userName_;
@property (nonatomic, copy) NSString* passWord_;
@property (nonatomic, assign) enum OwbIdentity identity_;
@end

# pragma mark - HeartBeatModel
@interface OwbClientHeartReturnPackage : NSObject {
    HeartReturnPackage* package_;
    enum OwbIdentity _identity_;
}
- (id)initFromRPac:(const HeartReturnPackage *)hb_package;
@property (nonatomic, readonly, assign) enum OwbIdentity identity_;
@end

@interface OwbClientHeartSendPackage : NSObject {
    HeartBeatSendPackage* package_;
    NSString* _userName_;
    NSString* _meetingId_;
}
- (HeartBeatSendPackage) toSPac;
@property (nonatomic, copy) NSString* userName_;
@property (nonatomic, copy) NSString* meetingId_;
@end

# pragma mark - JoinMeetingReturnModel
@interface OwbClientJoinMeetingReturn : NSObject {
    JoinMeetingReturn* package_;
    enum OwbJoinState _joinState_;
    int _port_;
    NSString* _serverIp_;
}
- (id)initFromJoinPac:(const JoinMeetingReturn *)re_package;
@property (nonatomic, readonly, assign) enum OwbJoinState joinState_;
@property (nonatomic, readonly, assign) int port_;
@property (nonatomic, readonly, copy) NSString* serverIp_;
@end

# pragma mark - OperationListModel
@interface OwbClientOperationList : NSObject {
    enum OwbOperationAvaliable _operationAvaliable_;
    NSArray* _operationList_;
}
- (id)initFromOperationList:(const Operations *)operations;
@property (nonatomic, readonly, assign)  enum OwbOperationAvaliable operationAvaliable_;
@property (nonatomic, readonly, retain) NSArray* operationList_;
@end

@interface OwbClientDocumentList : NSObject {
    NSArray* _documentList_;
}
- (id)initFromDocumentList:(const DocumentList *)documentList;
@property (nonatomic, readonly, retain) NSArray* documentList_;
@end

@interface OwbClientUserList : NSObject {
    NSArray* _userList_;
}
- (id)initFromUserList:(const UserList*) userList;
@property (nonatomic, readonly, retain) NSArray* userList_;
@end


# pragma mark - OperationModelFactory

@interface OwbClientOperationFactory : NSObject

+ (OwbClientOperation*)CreateOperationFromOperation:(const Operation *)operation;

@end

# pragma mark - OperationModel

@interface OwbClientOperation : NSObject {
    Operation* operation_;
    int _serialNumber_;
    enum OwbOperationDataType _operationType_;
    int _thinkness_;
    id<OwbClientDrawer> _drawer_;
}
- (id)initFromOperation:(const Operation *)operation;
- (Operation)toOperation;
- (OwbClientOperation*)duplicate;

@property (nonatomic, assign) int serialNumber_;
@property (nonatomic, assign) enum OwbOperationDataType operationType_;
@property (nonatomic, assign) int thinkness_;
@property (nonatomic, retain) id<OwbClientDrawer> drawer_;
@end

@interface DrawLine : OwbClientOperation {
    int _color_;
    float _alpha_;
    CGPoint _startPoint_;
    CGPoint _endPoint_;
}
@property (nonatomic, assign) int color_;
@property (nonatomic, assign) float alpha_;
@property (nonatomic, assign) CGPoint startPoint_;
@property (nonatomic, assign) CGPoint endPoint_;
@end

@interface DrawEllipse : OwbClientOperation {
    int _color_;
    float _alpha_;
    bool _fill_;
    CGPoint _center_;
    float _a_;
    float _b_;
}
@property (nonatomic, assign) int color_;
@property (nonatomic, assign) float alpha_;
@property (nonatomic, assign) bool fill_;
@property (nonatomic, assign) CGPoint center_;
@property (nonatomic, assign) float a_;
@property (nonatomic, assign) float b_;
@end

@interface DrawRectange : OwbClientOperation {
    int _color_;
    float _alpha_;
    bool _fill_;
    CGPoint _topLeftCorner_;
    CGPoint _bottomRightCorner_;
}
@property (nonatomic, assign) int color_;
@property (nonatomic, assign) float alpha_;
@property (nonatomic, assign) bool fill_;
@property (nonatomic, assign) CGPoint topLeftCorner_;
@property (nonatomic, assign) CGPoint bottomRightCorner_;
@end

@interface DrawPoint : OwbClientOperation {
    int _color_;
    float _alpha_;
    CGPoint _position_;
    bool _isStart_;
}
@property (nonatomic, assign) int color_;
@property (nonatomic, assign) float alpha_;
@property (nonatomic, assign) CGPoint position_;
@property (nonatomic, assign) bool isStart_;
@end

@interface Erase : OwbClientOperation {
    CGPoint _position_;
    bool _isStart_;
}
@property (nonatomic, assign) CGPoint position_;
@property (nonatomic, assign) bool isStart_;

@end

#endif  // KINGSLANDING_ONLINEWHITEBOARD_CLIENT_MODELS_MESSAGEMODEL_H_
