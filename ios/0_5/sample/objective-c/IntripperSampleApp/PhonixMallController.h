//
//  ViewController.h
//  IntripperSampleApp
//
//  Created by Sang.Mac.04 on 02/02/16.
//  Copyright © 2016 Sanginfo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhonixMallController : UIViewController

@property (strong, nonatomic) IBOutlet UIView *vwMap;
//Map properties
@property (weak, nonatomic) IBOutlet UIButton *btnLocate;
@property (strong, nonatomic) IBOutlet UIButton *btnVolume;
@property (strong, nonatomic) IBOutlet UIButton *btnGetDirection;
@property (strong, nonatomic) IBOutlet UILabel  *lblZoomLevel;
//Top Bar
@property (weak, nonatomic) IBOutlet UIView *vwTopBar;
@property (weak, nonatomic) IBOutlet UIView *vwTopBarContainer;
@property (strong, nonatomic) IBOutlet UILabel *lblVenueName;
@property (strong, nonatomic) IBOutlet UIButton *btnSearch;
@property (strong, nonatomic) IBOutlet UIButton *btnCancel;
@property (strong, nonatomic) IBOutlet UITextField *txtSearchOption;
@property (strong, nonatomic) IBOutlet UIButton *btnGoBack;
@property (strong, nonatomic) IBOutlet UIButton *btnGoToMap;
//Store Bar
@property (strong, nonatomic) IBOutlet UIView *vwStoreDetail;
@property (strong, nonatomic) IBOutlet UILabel *lblStoreName;
@property (strong, nonatomic) IBOutlet UILabel *lblStoreTime;
@property (strong, nonatomic) IBOutlet UIButton *btnShowPath;
//Instruction Bar
@property (weak, nonatomic) IBOutlet UIView *vwTurnByTurn;
@property (weak, nonatomic) IBOutlet UIView *vwTurnDetail;
@property (weak, nonatomic) IBOutlet UIImageView *imgTurn;
@property (weak, nonatomic) IBOutlet UILabel *lblTurnInfo;
@property (weak, nonatomic) IBOutlet UIButton *btnNextRoute;
@property (weak, nonatomic) IBOutlet UIButton *btnPreviousRoute;
//Route Detail Bar
@property (strong, nonatomic) IBOutlet UIView *vwRouteDetail;
@property (weak, nonatomic) IBOutlet UILabel *lblEndPoint;
@property (weak, nonatomic) IBOutlet UIButton *btnStartNavigation;
@property (weak, nonatomic) IBOutlet UIButton *btnCloseNavigation;
@property (weak, nonatomic) IBOutlet UIImageView *imgNavigation;
@property (weak, nonatomic) IBOutlet UIImageView *imgCloseNavi;
@property (weak, nonatomic) IBOutlet UIView *vwStoreTimeFeet;
//Navigation Details
@property (strong, nonatomic) IBOutlet UILabel  * lblEstimatedTime;
@property (strong, nonatomic) IBOutlet UIView  * vwSeparatorOne;
@property (strong, nonatomic) IBOutlet UILabel  *lblDistanceinFt;
@property (strong, nonatomic) IBOutlet UIView  * vwSeparatorTwo;
@property (strong, nonatomic) IBOutlet UILabel  *lblLevels;
//Floor Change Bar
@property (strong, nonatomic) IBOutlet UIView *vwChangeFloor;

- (IBAction)onSearchTap:(id)sender;
- (IBAction)onCancelAction:(id)sender;

- (IBAction)searchEntered:(UITextField *)sender;
- (IBAction)onMoveBack:(UIButton *)sender;
- (IBAction)goBackToMap:(UIButton *)sender;

@end

