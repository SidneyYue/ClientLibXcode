/*************************************************************************
     ** File Name: OwbClientServerDelegate.mm
    ** Author: tsgsz
    ** Mail: cdtsgsz@gmail.com
    ** Created Time: Sat Apr 27 21:41:12 2013
    **Copyright [2013] <Copyright tsgsz>  [legal/copyright]
 ************************************************************************/
#import "./OwbClientServerDelegate.h"
#import "../NetWork/ServerDelegate.h"
#import "../Models/MessageModel.h"
#import "../ProtoBuffer/message.pb.h"
#ifdef SERVER
#undef SERVER
#endif
#define SERVER Server::GetInstance()

typedef Kingslanding::OnlineWhiteBoard::Client::NetWork::ServerDelegate Server;

static OwbClientServerDelegate* serverDelegateInstance = nil;

@implementation OwbClientServerDelegate;

- (BOOL)sendOperation:(OwbClientOperation*) operation {
    Operation op = [operation toOperation];
    return SERVER->WriteOperationToPool(op);
}

- (BOOL)setDocument:(int)docNumber {
    return SERVER->SetDocument(docNumber);
}

- (BOOL)login:(OwbClientUser *)user {
    User u = [user toUser];
    return SERVER->Login(u);
}

- (NSString*)createMeeting:(NSString *)userName {
    std::string un = std::string([userName UTF8String]);
    std::string mi = SERVER->CreateMeeting(un);
    return [NSString stringWithUTF8String:mi.c_str()];
}

- (OwbClientJoinMeetingReturn *)joinMeeting:(NSString *)userName
                                WithMeetingId:(NSString *)meetingId {
    std::string un = std::string([userName UTF8String]);
    std::string mi = std::string([meetingId UTF8String]);
    JoinMeetingReturn _re = SERVER->JoinMeeting(un, mi);
    return [[OwbClientJoinMeetingReturn alloc]initFromJoinPac:&_re];
}


- (int)transferAuth:(NSString *)userName WithMeetingId:(NSString *)meetingId {
    std::string un = std::string([userName UTF8String]);
    std::string mi = std::string([meetingId UTF8String]);
    return SERVER->TransferAuth(un, mi);
}

- (BOOL)requestAuth:(NSString *)userName WithMeetingId:(NSString *)meetingId {
    std::string un = std::string([userName UTF8String]);
    std::string mi = std::string([meetingId UTF8String]);
    return SERVER->RequestAuth(un, mi);
}

- (OwbClientUserList *)getCurrentUserList:(NSString *)meetingId {
    std::string mi = std::string([meetingId UTF8String]);
    UserList ul = SERVER->GetCurrentUserList(mi);
    return [[OwbClientUserList alloc]initFromUserList:&ul];
}

- (OwbClientHeartReturnPackage *)heartBeat:(OwbClientHeartSendPackage *)package
{
    HeartReturnPackage re = SERVER->HeartBeat([package toSPac]);
    return [[OwbClientHeartReturnPackage alloc]initFromRPac:&re];
}

- (BOOL)resumeUpdater:(NSString *)meetingId
{
    std::string mi = std::string([meetingId UTF8String]);
    return SERVER->ResumeUpdater(mi);
}

- (OwbClientOperationList *)getOperationList:(NSString *)meetingId
                            LatestSerialNumber:(int) serialNumber {
    std::string mi = std::string([meetingId UTF8String]);
    Operations ol = SERVER->GetOperations(mi, serialNumber);
    return [[OwbClientOperationList alloc]initFromOperationList:&ol];
}

- (OwbClientDocument *)getDocument:(NSString *)meetingId
                       WithSerialNumber:(int) serialNumber {
    std::string mi = std::string([meetingId UTF8String]);
    Document doc = SERVER->GetDocument(mi, serialNumber);
    return [[OwbClientDocument alloc]initFromDocument:&doc];
}

- (OwbClientDocument *)getLatestDocument:(NSString *) meetingId {
    std::string mi = std::string([meetingId UTF8String]);
    Document doc = SERVER->GetLatestDocument(mi);
    return [[OwbClientDocument alloc]initFromDocument:&doc];
}

- (OwbClientDocumentList *)getHistorySnapshots:(NSString *) meetingId {
    std::string mi = std::string([meetingId UTF8String]);
    DocumentList dl = SERVER->GetHistorySnapshots(mi);
    return [[OwbClientDocumentList alloc]initFromDocumentList:&dl];
}


- (void)bindUpdaterIp:(NSString *) ipAddress AndPort:(int) port {
    std::string ip = std::string([ipAddress UTF8String]);
    SERVER->BindUpdaterIpAndPort(ip, port);
}

- (void)bindProviderIp:(NSString *) ipAddress AndPort:(int) port {
    std::string ip = std::string([ipAddress UTF8String]);
    SERVER->BindProviderIpAndPort(ip, port);
}

- (void)bindMonitorIp:(NSString *) ipAddress AndPort:(int) port {
    std::string ip = std::string([ipAddress UTF8String]);
    SERVER->BindMonitorIpAndPort(ip, port);
}

+ (OwbClientServerDelegate*) sharedServerDelegate {
    if (nil == serverDelegateInstance) {
        serverDelegateInstance = [[OwbClientServerDelegate alloc]init];
    }
    return serverDelegateInstance;
}

@end
