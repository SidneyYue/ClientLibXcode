/*************************************************************************
     ** File Name: ServerDelegate.h
    ** Author: tsgsz
    ** Mail: cdtsgsz@gmail.com
    ** Created Time: Wed Apr 10 16:46:51 2013
    **Copyright [2013] <Copyright tsgsz>  [legal/copyright]
 ************************************************************************/

#ifndef KINGSLANDING_ONLINEWHITEBOARD_CLIENT_NETWORK_SERVERDELEGATE_H_
#define KINGSLANDING_ONLINEWHITEBOARD_CLIENT_NETWORK_SERVERDELEGATE_H_

#include <string>
#include "../ProtoBuffer/message.pb.h"

namespace Kingslanding {
namespace OnlineWhiteBoard {
namespace Client {
namespace NetWork {

class ServerDelegate {
public:
    static ServerDelegate* GetInstance();

    // for data_updater_server
    bool WriteOperationToPool(const Operation& operation);
    bool SetDocument(int docNumber);

    // for monitor_server
    bool Login(const User& user);
    std::string CreateMeeting(const std::string& user_name);
    JoinMeetingReturn JoinMeeting(const std::string& user_name,
                                  const std::string& meeting_id);
    int32_t TransferAuth(const std::string& user_name,
                      const std::string& meeting_id);
    bool RequestAuth(const std::string& user_name,
                     const std::string& meeting_id);
    UserList GetCurrentUserList(const std::string& meeting_id);
    HeartReturnPackage HeartBeat(const HeartBeatSendPackage& package);
    bool ResumeUpdater(const std::string& meeting_id);
    
    // for provider_server
    Operations GetOperations(const std::string& meeting_id,
                             int32_t latest_serial_number);
    Document GetLatestDocument(const std::string& meeting_id);
    DocumentList GetHistorySnapshots(const std::string& meeting_id);
    Document GetDocument(const std::string& meeting_id, int32_t serial_number);

    //  pref for updater_server
    void BindUpdaterIpAndPort(const std::string& ip_address, int port);

    //  pref for provider_server
    void BindProviderIpAndPort(const std::string& ip_address, int port);
    
    //  pref for monitor_server
    void BindMonitorIpAndPort(const std::string& ip_address, int port);
    
private:
    ServerDelegate();

    static ServerDelegate* server_delegate_instance_;

    class Garbo {
    public:
        ~Garbo() {
            if (ServerDelegate::server_delegate_instance_ != NULL) {
                delete ServerDelegate::server_delegate_instance_;
            }
        }
    };

    static Garbo garbo_;

    std::string updater_ip_address_;
    int updater_port_;
    
    std::string provider_ip_address_;
    int provider_port_;
    
    std::string monitor_ip_address_;
    int monitor_port_;
    
};
}  // NetWork
}  // Client
}  // OnlineWhiteBoard
}  // Kingslanding

#endif  // KINGSLANDING_ONLINEWHITEBOARD_CLIENT_NETWORK_SERVERDELEGATE_H_
