//
//  Conversion.h
//  shoppingmall
//
//  Created by Sang.Mac.04 on 20/11/15.
//  Copyright © 2015 Sanginfo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  ConversionBandDelegate<NSObject>
-(void)HideConvergenceDialog;
@end
@interface Conversion : UIViewController
@property(nonatomic,weak)id <ConversionBandDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIView *vwConversionTitle;

@property (weak, nonatomic) IBOutlet UILabel *lblconvergenceMsg;
@property (weak, nonatomic) IBOutlet UILabel *lblConversionTitle;
@property (weak, nonatomic) IBOutlet UIView *vwConvergenceBottomBar;
@property (weak, nonatomic) IBOutlet UILabel *lblConMessage;
@property (weak, nonatomic) IBOutlet UIView *vwOuterCircle;
@property (weak, nonatomic) IBOutlet UIView *vwInnerCircle;
@property (weak, nonatomic) IBOutlet UIImageView *imgNeedle;
@property (strong, nonatomic) IBOutlet UIView *vwConvergence;
@property (weak, nonatomic) IBOutlet UIImageView *imgActionDone;
@property (weak, nonatomic) IBOutlet UILabel *lblConvoTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnClose;
@property (weak, nonatomic) IBOutlet UIView *vwButtonCloseContainer;

-(void)cancelAnimation;
-(void)setText:(NSString*)strMessage;
@property (weak, nonatomic) IBOutlet UIButton *onCloseConversionDialog;
- (IBAction)onCloseDialog:(id)sender;

@end
