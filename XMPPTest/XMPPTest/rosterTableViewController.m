//
//  rosterTableViewController.m
//  XMPPTest
//
//  Created by wdwk on 2017/5/8.
//  Copyright © 2017年 wksc. All rights reserved.
//

#import "rosterTableViewController.h"
#import "XMPPManager.h"
#import "chatTableViewController.h"
@interface rosterTableViewController ()<XMPPRosterDelegate>
@property(nonatomic, strong)NSMutableArray * dataArray;
@end

@implementation rosterTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=[XMPPManager shareManager].xmppStream.myJID.user ;
    
    self.dataArray=[NSMutableArray array];
    [[XMPPManager shareManager].xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)xmppRosterDidBeginPopulating:(XMPPRoster *)sender withVersion:(NSString *)version{
    NSLog(@"开始检索好友");
}
-(void)xmppRoster:(XMPPRoster *)sender didReceiveRosterItem:(DDXMLElement *)item{
     NSLog(@"检索到好友");
    //取到JID字符串；
    NSString *jidStr=[[item attributeForName:@"jid"] stringValue];
//    根据jid字符串创建jid对象
    XMPPJID *jid=[XMPPJID jidWithString:jidStr];
//把好友加到数组中
    if ([self.dataArray containsObject:jid]) {
        return;
    }
    [self.dataArray addObject:jid];
    //如果好友多的话让它滚到好友的最后一个位置；
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:self.dataArray.count-1 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}
-(void)xmppRosterDidEndPopulating:(XMPPRoster *)sender{
     NSLog(@"检索好友结束");
}
- (IBAction)addFriend:(id)sender {
    
    UIAlertView * alert=[[UIAlertView alloc]initWithTitle:@"提示"message:@"添加好友"delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
     alert.alertViewStyle=UIAlertViewStylePlainTextInput;
    [alert show];
   
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        UITextField *textField=[alertView textFieldAtIndex:0];
//        根据内容创建JID
        XMPPJID *jid=[XMPPJID jidWithUser:textField.text domain:kDomain resource:kResource];
//        添加好友
        [[XMPPManager shareManager].xmppRoster addUser:jid withNickname:nil];
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return self.dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellID" forIndexPath:indexPath];
    
//    取出数组中的jid对象给cell赋值；
    XMPPJID *jid=self.dataArray[indexPath.row];
    cell.textLabel.text=jid.user ;
    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
//通过segue取到聊天界面控制器；
    chatTableViewController *chatTVC=segue.destinationViewController;
//    取得cell
    UITableViewCell *cell=sender;
//    找到cell对应的indexPath
    NSIndexPath *indexPath=[self.tableView indexPathForCell:cell];
    
//    取出JID
    XMPPJID * jid=self.dataArray[indexPath.row];
    chatTVC.friendJID=jid;
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
