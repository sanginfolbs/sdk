//
//  ArriveToDestinationViewController.m
//  gpsindoor
//
//  Created by Sang.Mac.05 on 8/11/15.
//  Copyright (c) 2015 indooratlas. All rights reserved.
//

#import "ArriveToDestinationViewController.h"
#import "UIColor+Expanded.h"
#import "UIView+Font.h"
#import "IntripperEnvironment.h"

@interface ArriveToDestinationViewController ()

@end

@implementation ArriveToDestinationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
 //   [UIView ChangeAppFont:self.view];
    [IntripperEnvironment AddRoundedCorners:self.view];
    [IntripperEnvironment circleView:self.arrInnerCircle];
    [IntripperEnvironment circleView:self.arrOuterCircle];
    [IntripperEnvironment AddRoundedCorners:self.vwExitNavPopup];
    self.lblTitle.textColor = [UIColor colorWithHexString:iSOMEFONTCOLOR];
    
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

- (IBAction)onExit:(UIButton *)sender {
    [self.delegate HideExitNavigation];
}
@end
