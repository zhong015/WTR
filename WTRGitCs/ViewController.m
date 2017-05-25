//
//  ViewController.m
//  WTRGitCs
//
//  Created by wfz on 2017/5/23.
//  Copyright © 2017年 wfz. All rights reserved.
//

#import "ViewController.h"
#import "WTRHUD.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [WTRHUD showHUDBInView:self.view];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
