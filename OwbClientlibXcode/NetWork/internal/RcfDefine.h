/*************************************************************************
     ** File Name: RcfDefine.h
    ** Author: tsgsz
    ** Mail: cdtsgsz@gmail.com
    ** Created Time: Fri Apr 12 15:58:22 2013
    **Copyright [2013] <Copyright tsgsz>  [legal/copyright]
 ************************************************************************/
#ifndef KINGSLANDING_ONLINEWHITEBOARD_CLIENT_NETWORK_INTERNAL_RCFDEFINE_H_
#define KINGSLANDING_ONLINEWHITEBOARD_CLIENT_NETWORK_INTERNAL_RCFDEFINE_H_

#ifndef RCF_USE_PROTOBUF
#define RCF_USE_PROTOBUF
#endif

#include <RCF/RCF.hpp>
#include <string>
#include "../..//ProtoBuffer/message.pb.h"

RCF_BEGIN(Updater, "Updater")
    RCF_METHOD_R1(bool, WriteOperationToPool, const Operation&)
    RCF_METHOD_R1(bool, SetDocument, uint32_t)
RCF_END(Updater)

RCF_BEGIN(Monitor, "Monitor")
    RCF_METHOD_R1(bool, Login, const User&)
    RCF_METHOD_R1(std::string, CreateMeeting, const std::string&)
    RCF_METHOD_R2(JoinMeetingReturn, JoinMeeting, const std::string&, \
                  const std::string&)
    RCF_METHOD_R2(int32_t, TransferAuth, const std::string&, const std::string&)
    //0 for fail, 1 for success, 2 for there is some problem with the user
    RCF_METHOD_R2(bool, RequestAuth, const std::string&, const std::string&)
    RCF_METHOD_R1(UserList, GetCurrentUserList, const std::string&)
    RCF_METHOD_R1(HeartReturnPackage, HeartBeat, const HeartBeatSendPackage&)
    RCF_METHOD_R1(bool, ResumeUpdater, const std::string&)
RCF_END(Monitor)

RCF_BEGIN(Provider, "Provider")
    RCF_METHOD_R2(Operations, GetOperations, const std::string&, uint32_t)
    RCF_METHOD_R1(Document, GetLatestDocument, const std::string&)
    RCF_METHOD_R1(DocumentList, GetHistorySnapshots, const std::string&)
    RCF_METHOD_R2(Document, GetDocument, const std::string&, uint32_t)
RCF_END(Provider)

#endif  // KINGSLANDING_ONLINEWHITEBOARD_CLIENT_NETWORK_INTERNAL_RCFDEFINE_H_
