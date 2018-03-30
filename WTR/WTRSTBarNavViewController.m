//
//  WTRSTBarNavViewController.m
//  WTRGitCs
//
//  Created by wfz on 2018/2/23.
//  Copyright © 2018年 wfz. All rights reserved.
//

#import "WTRSTBarNavViewController.h"

@interface WTRSTBarNavViewController ()

@end

@implementation WTRSTBarNavViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(id)init
{
    self=[super init];
    if (self) {
        self.StatusBarIsBlack=NO;
    }
    return self;
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    if (self.StatusBarIsBlack) {
        return UIStatusBarStyleDefault;
    }
    return UIStatusBarStyleLightContent;
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
