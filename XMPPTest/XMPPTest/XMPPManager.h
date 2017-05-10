//
//  XMPPManager.h
//  XMPPDemo
//
//  Created by wdwk on 2017/5/5.
//  Copyright © 2017年 wksc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XMPPFramework/XMPPFramework.h>
@interface XMPPManager : NSObject<XMPPStreamDelegate,XMPPRosterDelegate,UIAlertViewDelegate>

/**
 通讯注册需要一个通信通道对象；
 */
@property(nonatomic, strong)XMPPStream *xmppStream;

/**
 好友花名册管理对象；
 */
@property(nonatomic, strong)XMPPRoster *xmppRoster;
//信息归档对象

@property(nonatomic, strong)XMPPMessageArchiving *xmppMessageArchiving;
//数据管理器存储我们的信息
@property(nonatomic, strong)NSManagedObjectContext *context;

/**
 单例
 @return 返回XMPPManager
 */
+(XMPPManager*)shareManager;

/**
 登录

 @param userName 用户名
 @param passWord 密码
 */
-(void)loginWithUserName:(NSString *)userName passWord:(NSString *)passWord;

/**
 注册
 @param userName 用户名
 @param passWord 密码
 */
-(void)registerWithUserName:(NSString *)userName passWord:(NSString *)passWord;


@end
