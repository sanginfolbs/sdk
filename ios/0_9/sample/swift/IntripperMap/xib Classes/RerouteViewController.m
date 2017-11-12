//
//  RerouteViewController.m
//  gpsindoor
//
//  Created by Sanginfo on 15/05/15.
//  Copyright (c) 2015 indooratlas. All rights reserved.
//

#import "RerouteViewController.h"
#import "UIView+Font.h"
#import "IntripperEnvironment.h"
@interface RerouteViewController ()

@end

@implementation RerouteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
 //   [UIView ChangeAppFont:self.view];
    //[AlphaEnvironment AddBorder:self.view];
     [IntripperEnvironment AddRoundedCorners:self.view];
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
