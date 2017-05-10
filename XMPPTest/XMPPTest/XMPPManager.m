//
//  XMPPManager.m
//  XMPPDemo
//
//  Created by wdwk on 2017/5/5.
//  Copyright © 2017年 wksc. All rights reserved.
//

#import "XMPPManager.h"

/**
 连接的目的

 - ConnectToServerPurposeLogin: 连接服务器用于登录
 - ConnectToServerPurposeRegister: 连接服务器用于注册
 */
typedef NS_ENUM(NSInteger,ConnectToServerPurpose){
    ConnectToServerPurposeLogin,
    ConnectToServerPurposeRegister
};
@interface XMPPManager()

/**
 保存用户密码
 */
@property(nonatomic,copy)NSString *passWord;

/**
 连接服务器的目的
 */
@property(nonatomic,assign)ConnectToServerPurpose  connectToServerPurpose;

/**
 记录好友请求是谁在请求
 */
@property(nonatomic,strong)XMPPJID * fromJID;

@end
@implementation XMPPManager

+(XMPPManager *)shareManager{
    static XMPPManager *manager=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager=[[XMPPManager alloc]init];
    });
    return manager;
}
-(instancetype)init{
    if (self=[super init]) {
        //初始化通信通道对象；
        self.xmppStream=[[XMPPStream alloc]init];
        //设置服务器IP地址；
        self.xmppStream.hostName=kHostName;
        self.xmppStream.hostPort=kHostPort;
        [self.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        
        
//        花名册数据存储
        XMPPRosterCoreDataStorage *rosterStorage=[XMPPRosterCoreDataStorage sharedInstance];
//        创建花名册管理对象；
        self.xmppRoster=[[XMPPRoster alloc]initWithRosterStorage:rosterStorage dispatchQueue:dispatch_get_main_queue()];
//        激活通信通道
        [self.xmppRoster activate:self.xmppStream];
        [self.xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        
        
//        创建信息归档数据存储对象
        XMPPMessageArchivingCoreDataStorage *xmppMessageArchivingCoreDataStorage=[XMPPMessageArchivingCoreDataStorage sharedInstance];
//        创建数据归档对象
        self.xmppMessageArchiving=[[XMPPMessageArchiving alloc]initWithMessageArchivingStorage:xmppMessageArchivingCoreDataStorage dispatchQueue:dispatch_get_main_queue()];
        //  激活通信通道
        [self.xmppMessageArchiving activate:self.xmppStream];
//        创建数据管理器
        self.context=xmppMessageArchivingCoreDataStorage.mainThreadManagedObjectContext;
        
    }
    return self;
    
}

-(void)loginWithUserName:(NSString *)userName passWord:(NSString *)passWord{
    //连接服务器
    //在登录的时候保存一下密码：
    self.connectToServerPurpose=ConnectToServerPurposeLogin;
    self.passWord=passWord;
    [self connectToServerWithUserName:userName];
}
-(void)registerWithUserName:(NSString *)userName passWord:(NSString *)passWord{
    self.connectToServerPurpose=ConnectToServerPurposeRegister;
    self.passWord=passWord;
    [self connectToServerWithUserName:userName];
}
-(void)connectToServerWithUserName:(NSString *)userName
{
//    根据name创建JID
    XMPPJID * jid=[XMPPJID jidWithUser:userName domain:kDomain resource:kResource];
//    设置通信通道对象JID
    self.xmppStream.myJID=jid;
//    向服务器发送请求
//    判断服务器的连接状态，如若是已经或正在连接状态，要断开连接，发送下线连接状态；
    if ([self.xmppStream isConnected]||[self.xmppStream isConnecting]) {
//        发送下线连接状态；
        XMPPPresence *presence=[XMPPPresence presenceWithType:@"unavailable"];
        [self.xmppStream sendElement:presence];
//        断开连接
        [self.xmppStream disconnect];

    }
//    向服务器发送请求；-1表示没有超市
    NSError * error=nil;
    [self.xmppStream connectWithTimeout:-1 error:&error];
    if (error!=nil) {
       
        NSLog(@"连接错误:%@", error.localizedDescription);
    }
    else{
        NSLog(@"连接成功");
    }
}

-(void)xmppStreamConnectDidTimeout:(XMPPStream *)sender{
    NSLog(@"连接超时");
}

-(void)xmppStreamDidConnect:(XMPPStream *)sender{
    NSLog(@"连接成功，需要验证一下密码：");
    switch (self.connectToServerPurpose) {
        case ConnectToServerPurposeLogin:
            [self.xmppStream authenticateWithPassword:self.passWord error:nil];
            break;
        case ConnectToServerPurposeRegister:
            [self.xmppStream registerWithPassword:self.passWord error:nil];
            break;
        default:
            break;
    }
  
}
//好友状态
-(void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence{
    
//    available 上线
//    
//    away 离开
//    
//    do not disturb 忙碌
//        
//    unavailable 下线
    NSString *presenceType = [presence type];
    NSString *presenceFromUser = [[presence from] user];
    
    if (![presenceFromUser isEqualToString:[[sender myJID] user]]) {
        if ([presenceType isEqualToString:@"available"]) {
            //
        } else if ([presenceType isEqualToString:@"unavailable"]) {            //
        }
    }
}
//收到好友请求的方法
-(void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence{
    NSLog(@"收到好友请求");
    self.fromJID=presence.from;
    UIAlertView * alert=[[UIAlertView alloc]initWithTitle:@"好友请求" message:presence.from.user delegate:self cancelButtonTitle:@"拒绝" otherButtonTitles:@"同意", nil];
    [alert show];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
//            拒绝
            [self.xmppRoster rejectPresenceSubscriptionRequestFrom:self.fromJID];
            break;
        case 1:
//            同意
            [self.xmppRoster acceptPresenceSubscriptionRequestFrom:self.fromJID andAddToRoster:YES];
            break;
        default:
            break;
    }
}
@end
