/*************************************************************************
    ** File Name: ServerDelegate.cc
    ** Author: tsgsz
    ** Mail: cdtsgsz@gmail.com
    ** Created Time: Fri Apr 12 15:24:18 2013
    **Copyright [2013] <Copyright tsgsz>  [legal/copyright]
 ************************************************************************/
#include "./ServerDelegate.h"
#include "./internal/RcfDefine.h"
#include "../SupportFiles/common.h"

namespace Kingslanding {
namespace OnlineWhiteBoard {
namespace Client {
namespace NetWork {

typedef std::string str;
typedef HeartBeatSendPackage HbPack;


ServerDelegate* ServerDelegate::server_delegate_instance_ = NULL;

ServerDelegate::ServerDelegate() {
}

ServerDelegate* ServerDelegate::GetInstance() {
    if (NULL == server_delegate_instance_) {
        server_delegate_instance_ = new ServerDelegate();
    }
    return server_delegate_instance_;
}

void ServerDelegate::BindUpdaterIpAndPort(const str& ip_address, int port) {
    updater_ip_address_ = ip_address;
    updater_port_ = port;
}

void ServerDelegate::BindMonitorIpAndPort(const str& ip_address, int port) {
    monitor_ip_address_ = ip_address;
    monitor_port_ = port;
}

void ServerDelegate::BindProviderIpAndPort(const str& ip_address, int port) {
    provider_ip_address_ = ip_address;
    provider_port_ = port;
}

bool ServerDelegate::WriteOperationToPool(const Operation& operation) {
    RCF::RcfInitDeinit rcfInit;
    RcfClient<Updater> client(RCF::TcpEndpoint(updater_ip_address_,
                                                updater_port_));
    try {
      /*  if(operation.data().data_type() == Operation_OperationData_OperationDataType_POINT) {
            printf("op is_start : %d\n", operation.data().is_start());
        }*/
        return client.WriteOperationToPool(operation);
    } catch (RCF::Exception e) {
        printf("exception what :%s, context:%s",e.what(),e.getContext().c_str());
        return false;
    }
}

bool ServerDelegate::SetDocument(int docNumber) {
    RCF::RcfInitDeinit rcfInit;
    RcfClient<Updater> client(RCF::TcpEndpoint(updater_ip_address_,
                                               updater_port_));
    try {
        return client.SetDocument(docNumber);
    } catch (RCF::Exception e) {
        return false;
    }
}

bool ServerDelegate::Login(const User& user) {
    RCF::RcfInitDeinit rcfInit;
    RcfClient<Monitor> client(RCF::TcpEndpoint(monitor_ip_address_,
                                               monitor_port_));
    return client.Login(user);
}

str ServerDelegate::CreateMeeting(const str& user_name) {
    RCF::RcfInitDeinit rcfInit;
    RcfClient<Monitor> client(RCF::TcpEndpoint(monitor_ip_address_,
                                               monitor_port_));
    return client.CreateMeeting(user_name);
}

JoinMeetingReturn ServerDelegate::JoinMeeting(const str& user_name,
                                              const str& meeting_id) {
    RCF::RcfInitDeinit rcfInit;
    RcfClient<Monitor> client(RCF::TcpEndpoint(monitor_ip_address_,
                                               monitor_port_));
    return client.JoinMeeting(user_name, meeting_id);
}

int32_t ServerDelegate::TransferAuth(const str& user_name,
                                  const str& meeting_id) {
    RCF::RcfInitDeinit rcfInit;
    RcfClient<Monitor> client(RCF::TcpEndpoint(monitor_ip_address_,
                                               monitor_port_));
    return client.TransferAuth(user_name, meeting_id);
}

bool ServerDelegate::RequestAuth(const str& user_name,
                                 const str& meeting_id) {
    RCF::RcfInitDeinit rcfInit;
    RcfClient<Monitor> client(RCF::TcpEndpoint(monitor_ip_address_,
                                               monitor_port_));
    return client.RequestAuth(user_name, meeting_id);
}

UserList ServerDelegate::GetCurrentUserList(const str& meeting_id) {
    RCF::RcfInitDeinit rcfInit;
    RcfClient<Monitor> client(RCF::TcpEndpoint(monitor_ip_address_,
                                               monitor_port_));
    return client.GetCurrentUserList(meeting_id);
}

HeartReturnPackage ServerDelegate::HeartBeat(const HbPack& package) {
    RCF::RcfInitDeinit rcfInit;
    RcfClient<Monitor> client(RCF::TcpEndpoint(monitor_ip_address_,
                                               monitor_port_));
    return client.HeartBeat(package);
}

bool ServerDelegate::ResumeUpdater(const str& meeting_id) {
    RCF::RcfInitDeinit rcfInit;
    RcfClient<Monitor> client(RCF::TcpEndpoint(monitor_ip_address_,
                                               monitor_port_));
//    printf("resume meetingId %s\n", meeting_id.c_str());
    return client.ResumeUpdater(meeting_id);
}

Operations ServerDelegate::GetOperations(const str& meeting_id,
                                         int32_t latest_serial_number) {
    RCF::RcfInitDeinit rcfInit;
    RcfClient<Provider> client(RCF::TcpEndpoint(provider_ip_address_,                                               provider_port_));
    try {
        return client.GetOperations(meeting_id, latest_serial_number);
    } catch (RCF::Exception e) {
        printf("getop fialed %s\n", e.what());
        throw e;
    }
    
}

Document ServerDelegate::GetLatestDocument(const str& meeting_id) {
    RCF::RcfInitDeinit rcfInit;
    RcfClient<Provider> client(RCF::TcpEndpoint(provider_ip_address_,
                                               provider_port_));
    return client.GetLatestDocument(meeting_id);
}

DocumentList ServerDelegate::GetHistorySnapshots(const str& meeting_id) {
    RCF::RcfInitDeinit rcfInit;
    RcfClient<Provider> client(RCF::TcpEndpoint(provider_ip_address_,
                                               provider_port_));
    return client.GetHistorySnapshots(meeting_id);
}

Document ServerDelegate::GetDocument(const str& meeting_id,
                                     int32_t serial_number) {
    RCF::RcfInitDeinit rcfInit;
    RcfClient<Provider> client(RCF::TcpEndpoint(provider_ip_address_,
                                               provider_port_));
    return client.GetDocument(meeting_id, serial_number);
}
}  // NetWork
}  // Client
}  // OnlineWhiteBoard
}  // Kingslanding
