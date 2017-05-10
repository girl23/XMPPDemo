//
//  chatTableViewController.h
//  XMPPTest
//
//  Created by wdwk on 2017/5/8.
//  Copyright © 2017年 wksc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPManager.h"
@interface chatTableViewController : UITableViewController
@property(nonatomic, strong) XMPPJID *friendJID;
@end
