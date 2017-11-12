//
//  ArriveToDestinationViewController.h
//  gpsindoor
//
//  Created by Sang.Mac.05 on 8/11/15.
//  Copyright (c) 2015 indooratlas. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol  ArriveToDestinationDelegate<NSObject>
-(void)HideExitNavigation;
@end
@interface ArriveToDestinationViewController : UIViewController
@property(nonatomic,weak)id <ArriveToDestinationDelegate> delegate;
@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) IBOutlet UIView *arrOuterCircle;
@property (strong, nonatomic) IBOutlet UIView *arrInnerCircle;
@property (strong, nonatomic) IBOutlet UIView *vwExitNavPopup;
- (IBAction)onExit:(UIButton *)sender;
@end
