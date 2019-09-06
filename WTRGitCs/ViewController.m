//
//  ViewController.m
//  WTRGitCs
//
//  Created by wfz on 2017/5/23.
//  Copyright © 2017年 wfz. All rights reserved.
//

#import "ViewController.h"
#import "WTRDefine.h"
#import "NSObject+WTRExtension.h"

@interface ONECS : NSObject

@property(nonatomic,copy)NSString *onen;

@property(nonatomic,copy)NSString *onew;

@property(nonatomic,strong)NSArray *arr1;
@property(nonatomic,strong)NSMutableArray *arr2;

@end

@implementation ONECS

+(NSDictionary *)WTR_objectClassInArray
{
    return @{@"arr1":@"ONECS",@"arr2":@"ONECS"};
}

@end

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation ViewController
{
    UIImageView *imv;
    NSArray *nameArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];

    NSDictionary *dic=@{@"onen":@"ddd",@"onew":@"ooo",@"arr1":@[@{@"onen":@"ddd1",@"onew":@"ooo",@"arr1":@[]},@{@"onen":@"ddd2",@"onew":@"ooo",@"arr1":@[]}],@"arr2":@[@{@"onen":@"ddd1",@"onew":@"ooo",@"arr1":@[]},@{@"onen":@"ddd2",@"onew":@"ooo",@"arr1":@[]}]};

    ONECS *ccs=[ONECS WTR_ObjectWithKeyValues:dic];

    NSLog(@"%@",ccs.onen);

    NSLog(@"%@",ccs.WTR_JSONString);

//    imv=[[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Users/wfz/Desktop/asd.png"]];
//    [self.view addSubview:imv];

    
//    if (ISIPhoneX) {
//        NSLog(@"呵呵呵");
//    }
//    nameArray=@[@"图片选取剪切"];
//
//    UITableView *tablev=[[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
//    tablev.dataSource=self;
//    tablev.delegate=self;
//    [self.view addSubview:tablev];
//
//    tablev.contentInset=UIEdgeInsetsMake(ISIPhoneX?44:20, 0, ISIPhoneX?40:20, 0);
//
//    [tablev registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
//    imv.center=CGPointMake(arc4random()%100/100.0*self.view.frame.size.width, arc4random()%100/100.0*self.view.frame.size.height);

//    [WTRHUD showHUDWInView:self.view];

//    if (arc4random()%2) {
//        [WTRHUD showSuccessWInView:self.view WithStatus:@"呵呵呵"];
//    }else{
//        [WTRHUD showErrorBInView:self.view WithStatus:@"错误提示"];
//    }
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
