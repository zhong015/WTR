//
//  ViewController.m
//  WTRGitCs
//
//  Created by wfz on 2017/5/23.
//  Copyright © 2017年 wfz. All rights reserved.
//

#import "ViewController.h"
#import "WTRDefine.h"
#import "SLImageSelectViewController.h"
#import "UIImage+WTRManager.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation ViewController
{
    NSArray *nameArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];

    if (ISIPhoneX) {
        NSLog(@"呵呵呵");
    }
    nameArray=@[@"图片选取剪切"];

    UITableView *tablev=[[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tablev.dataSource=self;
    tablev.delegate=self;
    [self.view addSubview:tablev];

    tablev.contentInset=UIEdgeInsetsMake(ISIPhoneX?44:20, 0, ISIPhoneX?40:20, 0);

    [tablev registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return nameArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.textLabel.text=nameArray[indexPath.row];
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            {
                SLImageSelectViewController *scvc=[SLImageSelectViewController new];
                [self.navigationController pushViewController:scvc animated:YES];
            }
            break;
            
        default:
            break;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
