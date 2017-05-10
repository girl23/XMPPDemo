//
//  LoginViewController.m
//  XMPPDemo
//
//  Created by wdwk on 2017/5/5.
//  Copyright © 2017年 wksc. All rights reserved.
//

#import "LoginViewController.h"
#import "XMPPManager.h"
@interface LoginViewController ()<XMPPStreamDelegate>
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    添加代理
    [[XMPPManager shareManager].xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    // Do any additional setup after loading the view.
}
- (IBAction)loginButtonAction:(id)sender {
    [[XMPPManager shareManager] loginWithUserName:self.userNameTextField.text passWord:self.passwordTextField.text];
}
- (IBAction)registerButtonAction:(id)sender {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    NSLog(@"登录成功");
//    登录成功后设置上限状态
    XMPPPresence *presence=[XMPPPresence presenceWithType:@"available"];
    
    [[XMPPManager shareManager].xmppStream sendElement:presence];
    
//    如果验证成功进入好友界面
    [self performSegueWithIdentifier:@"roster" sender:nil];
}
-(void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error{
    NSLog(@"登录失败");
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
