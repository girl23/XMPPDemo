//
//  registerViewController.m
//  XMPPTest
//
//  Created by wdwk on 2017/5/8.
//  Copyright © 2017年 wksc. All rights reserved.
//

#import "registerViewController.h"
#import "XMPPManager.h"
@interface registerViewController ()<XMPPStreamDelegate>
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passWordTextField;

@end

@implementation registerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[XMPPManager shareManager].xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    // Do any additional setup after loading the view.
}
-(void)xmppStreamDidRegister:(XMPPStream *)sender{
    NSLog(@"注册陈功");
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error{
    NSLog(@"注册失败");
    
}
- (IBAction)registerButtonClick:(id)sender {
    [[XMPPManager shareManager]registerWithUserName:self.userNameTextField.text passWord:self.passWordTextField.text];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
