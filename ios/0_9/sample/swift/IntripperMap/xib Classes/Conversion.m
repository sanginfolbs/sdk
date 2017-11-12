//
//  Conversion.m
//  shoppingmall
//
//  Created by Sang.Mac.04 on 20/11/15.
//  Copyright © 2015 Sanginfo. All rights reserved.
//

#import "Conversion.h"
#import <QuartzCore/QuartzCore.h>
#import "IntripperEnvironment.h"

@interface Conversion ()

@end

@implementation Conversion{
    int _direction;
    int _angle;
    BOOL cancelAll;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    _angle = 10;
    _direction = 1;
   
    [super viewDidLoad];
 //   [UIView ChangeAppFont:self.view];
    [IntripperEnvironment AddRoundedCorners:self.vwConvergence];
     [self rotataleRight:self.imgNeedle];
   
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void) movePend
{
    if(_direction == 45){
        _direction = 1;
    } else if(_direction == 180) {
        _direction = 0;
    }
    _angle = (_direction) ? _angle-- : _angle++;  // Determine which way to rotate.
    self.imgNeedle.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI * (_angle/ 180.0));
}
- (void) swingPendulum;
{
    CABasicAnimation *rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@";transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0]; ///* full rotation*/ * roation * duration ];
    rotationAnimation.duration = 2.0;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = 10.0;
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    [self.imgNeedle.layer addAnimation:rotationAnimation forKey:@";rotationAnimation"];
}
-(void)cancelAnimation {
    [self.imgNeedle.layer removeAllAnimations]; //!
    [self.lblConvoTitle.layer removeAllAnimations];
    
    cancelAll = YES;
}

-(void)setText:(NSString*)strMessage{
    self.lblConMessage.text = strMessage;
}

-(void)rotataleRight:(UIView *)view
{
    if(cancelAll){
        return;
    }
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         view.transform = CGAffineTransformMakeRotation(-.95);
                     }
                     completion:^(BOOL finished) {
                         
                         [self performSelector:@selector(rotataleLeft:) withObject:view afterDelay:0.1];
                         
                     }];
    
}
-(void)rotataleLeft:(UIView *)view
{
    if(cancelAll){
        return;
    }
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         view.transform = CGAffineTransformMakeRotation(.95);
                     }
                     completion:^(BOOL finished) {
                         
                         [self performSelector:@selector(rotataleRight:) withObject:view afterDelay:0.1];
                         
                         
                     }];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onCloseDialog:(id)sender {
    [self.delegate HideConvergenceDialog];
}
@end
