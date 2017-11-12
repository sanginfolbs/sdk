//
//  IntripperEnvironment.h
//  IntripperSampleApp
//
//  Created by Sang.Mac.04 on 03/02/16.
//  Copyright © 2016 Sanginfo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

extern NSString *const iBORDERCOLOR;
extern NSString *const iFONTCOLOR;
extern NSString *const iSOMEFONTCOLOR;
@interface IntripperEnvironment : NSObject
+ (IntripperEnvironment *)instance;
-(NSString *)convertFeetToTimeCustom:(double)inMeters;
+ (UIImage *) imageWithView:(UIView *)view;
+ (void) circleView:(UIView *)source;
+ (void) circleButton:(UIButton *)source;
+ (void) circleButton:(UIButton *)source withColor:(UIColor *)bordercolor;
+ (void) AddRoundedCorners:(UIView *)source;
+ (void) AddRoundedCornersForAlert:(UIView *)source;
/**
 *  Add Offer in Push List
 *
 *  @param offer Detail of offers
 */
-(void)addinpushoffers:(NSDictionary *)offer;
/**
 *  Border to View
 *
 *  @param source View
 */
+(void) AddBorder:(UIView *)source;
@end
