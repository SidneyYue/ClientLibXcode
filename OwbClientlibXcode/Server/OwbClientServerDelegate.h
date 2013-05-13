/*************************************************************************
     ** File Name: OwbClientServerDelegate.h
    ** Author: tsgsz
    ** Mail: cdtsgsz@gmail.com
    ** Created Time: Sat Apr 27 21:41:06 2013
    **Copyright [2013] <Copyright tsgsz>  [legal/copyright]
 ************************************************************************/
#ifndef KINGSLAINDG_ONLINEWHITEBOARD_CLIENT_SERVER_OWBCLIENTSERVERDELEGATE_H_
#define KINGSLAINDG_ONLINEWHITEBOARD_CLIENT_SERVER_OWBCLIENTSERVERDELEGATE_H_

@class OwbClientDocument;
@class OwbClientDocumentList;
@class OwbClientHeartReturnPackage;
@class OwbClientHeartSendPackage;
@class OwbClientJoinMeetingReturn;
@class OwbClientOperation;
@class OwbClientUser;
@class OwbClientOperationList;
@class OwbClientUserList;

@interface OwbClientServerDelegate : NSObject
//  for data_updater_server
- (BOOL)sendOperation:(OwbClientOperation*) operation;
- (BOOL)setDocument:(int) docNumber;
//  for monitor_server
- (BOOL)login:(OwbClientUser *)user;
- (NSString *)createMeeting:(NSString *)userName;
- (OwbClientJoinMeetingReturn *)joinMeeting:(NSString *)userName 
                               WithMeetingId:(NSString *)meetingId;
- (int)transferAuth:(NSString *)userName WithMeetingId:(NSString *)meetingId;
- (BOOL)requestAuth:(NSString *)userName WithMeetingId:(NSString *)meetingId;
- (OwbClientUserList *)getCurrentUserList:(NSString *)meetingId;
- (OwbClientHeartReturnPackage *)heartBeat:(OwbClientHeartSendPackage *)package;
- (BOOL)resumeUpdater:(NSString *)meetingId;
//  for data_provider_server
- (OwbClientOperationList *)getOperationList:(NSString *)meetingId 
                            LatestSerialNumber:(int) serialNumber;
- (OwbClientDocument *)getDocument:(NSString *)meetingId 
                       WithSerialNumber:(int) serialNumber;
- (OwbClientDocument *)getLatestDocument:(NSString *) meetingId;
- (OwbClientDocumentList *)getHistorySnapshots:(NSString *) meetingId;
//  pref for updater_server
- (void)bindUpdaterIp:(NSString *) ipAddress AndPort:(int) port;
//  pref for monitor_server
- (void)bindMonitorIp:(NSString *) ipAddress AndPort:(int) port;
//  pref for provider_server
- (void)bindProviderIp:(NSString *) ipAddress AndPort:(int) port;
+ (OwbClientServerDelegate*) sharedServerDelegate;
@end

#endif  // KINGSLAINDG_ONLINEWHITEBOARD_CLIENT_SERVER_OWBCLIENTSERVERDELEGATE_H_
