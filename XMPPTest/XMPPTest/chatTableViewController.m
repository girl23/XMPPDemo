//
//  chatTableViewController.m
//  XMPPTest
//
//  Created by wdwk on 2017/5/8.
//  Copyright © 2017年 wksc. All rights reserved.
//

#import "chatTableViewController.h"
#import "XMPPManager.h"
#import "FriendCell.h"
@interface chatTableViewController ()<XMPPStreamDelegate,UIAlertViewDelegate>
@property(nonatomic, strong)NSMutableArray * messageArray;
@end

@implementation chatTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//  初始化数组
    self.messageArray=[NSMutableArray array];
//    给通信通道添加代理
   [ [XMPPManager shareManager].xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self reloadMessage];
    
}

-(void)reloadMessage
{
//    我们的信息都是存储在临时数据库中，所以我们要在临时数据库中查找
    NSManagedObjectContext *context=[XMPPManager shareManager].context;
//    创建查询
    NSFetchRequest *fetchRequest=[[NSFetchRequest alloc]init];
    
//    创建实体描述类；
    NSEntityDescription *entityDescription=[NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject" inManagedObjectContext:context];
    [fetchRequest setEntity:entityDescription];
//  通过谓词 检索信息
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"bareJidStr ==%@ and streamBareJidStr==%@",self.friendJID.bare,[XMPPManager shareManager].xmppStream.myJID.bare];
//    根据实体的，时间属性shenxu排序,
    NSSortDescriptor * sortDescriptor=[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    NSArray * fetchArray=[context executeFetchRequest:fetchRequest error:nil];
    if (fetchArray.count!=0) {
        if (self.messageArray.count!=0) {
            [self.messageArray removeAllObjects];
        }
        [self.messageArray addObjectsFromArray:fetchArray];
        [self.tableView reloadData];
    }
    //动画效果
    if (self.messageArray.count!=0) {
        NSIndexPath * indexPath=[NSIndexPath indexPathForRow:self.messageArray.count-1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES   ];
    }
    
}

-(void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message
{
    NSLog(@"消息发送成功");
    [self reloadMessage];
    
}
-(void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message{
    NSLog(@"成功接受消息");
    [self reloadMessage];
}
- (IBAction)sendAction:(id)sender {
    
    UIAlertView * alert=[[UIAlertView alloc]initWithTitle:@"发送消息"message:@""delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"发送", nil];
     alert.alertViewStyle=UIAlertViewStylePlainTextInput;
    [alert show];
   
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex) {
        UITextField * textField=[alertView textFieldAtIndex:0];
        //创建信息
        XMPPMessage *message=[XMPPMessage messageWithType:@"chat" to:self.friendJID];
        [message addBody:textField.text];
        
        [[XMPPManager shareManager].xmppStream sendElement:message];
        [self reloadMessage];
        
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
    return self.messageArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    取出数据源中的消息
    XMPPMessageArchiving_Message_CoreDataObject *message=self.messageArray[indexPath.row];
    if (message.isOutgoing) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatCell1" forIndexPath:indexPath];

        cell.textLabel.text=message.body;
         return cell;
    }
    else{
        FriendCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatCell2" forIndexPath:indexPath];
        cell.chatLabel.text=message.body;
        return cell;
        
    }
    
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
