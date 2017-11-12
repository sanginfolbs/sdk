//
//  IntripperEnvironment.m
//  IntripperSampleApp
//
//  Created by Sang.Mac.04 on 03/02/16.
//  Copyright © 2016 Sanginfo. All rights reserved.
//

#import "IntripperEnvironment.h"
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import "UIColor+Expanded.h"
@interface IntripperEnvironment()
{
     NSMutableArray *pushOffers;
}
@end
@implementation IntripperEnvironment

NSString *const iBORDERCOLOR=@"cacaca";
NSString *const iFONTCOLOR=@"00b2ff";
NSString *const iSOMEFONTCOLOR=@"727580";
+ (IntripperEnvironment *)instance
{
    static IntripperEnvironment *_mapsharedClient = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^
                  {
                      _mapsharedClient = [[IntripperEnvironment alloc] init];
                  });
    return _mapsharedClient;
}
-(id)init
{
    pushOffers=[[NSMutableArray alloc] init];
    return self;
}
-(NSString *)convertFeetToTimeCustom:(double)inMeters{
    double distanceinFt=inMeters*3.28084f;
    NSString *output;
    float timeTaken= ceil(distanceinFt/150);// 150 feet=1 minute & 45.72 meter=1 minute
    
    if (timeTaken>1) {
        output=[NSString stringWithFormat:@"%.0f mins away",timeTaken];
    }
    else{
        output=[NSString stringWithFormat:@"%.0f min away",timeTaken];
    }
    return output;
}
+ (void) circleView:(UIView *)source{
    CGFloat borderWidth = 0.0f;
    source.layer.borderColor = [UIColor blackColor].CGColor;//[UIColor colorWithHexString:BORDERCOLOR].CGColor;// [UIColor colorWithRed:0.792 green:0.792 blue:0.792 alpha:1].CGColor; /*#cacaca*///[UIColor lightGrayColor].CGColor;
    source.layer.borderWidth = borderWidth;
    source.layer.cornerRadius = source.frame.size.width/2;
    source.layer.masksToBounds = YES;
    
}
+ (void) circleButton:(UIButton *)source{
    CGFloat borderWidth = 0.5f;
    source.layer.borderColor = [UIColor colorWithHexString:iBORDERCOLOR].CGColor;// [UIColor colorWithRed:0.792 green:0.792 blue:0.792 alpha:1].CGColor; /*#cacaca*///[UIColor lightGrayColor].CGColor;
    source.layer.borderWidth = borderWidth;
    source.layer.cornerRadius = source.frame.size.width/2;
    source.layer.masksToBounds = YES;
}
+ (void) circleButton:(UIButton *)source withColor:(UIColor *)bordercolor{
    CGFloat borderWidth = 2.0f;
    source.layer.borderColor = bordercolor.CGColor;// [UIColor colorWithRed:0.792 green:0.792 blue:0.792 alpha:1].CGColor; /*#cacaca*///[UIColor lightGrayColor].CGColor;
    source.layer.borderWidth = borderWidth;
    source.layer.cornerRadius = source.frame.size.width/2;
    source.layer.masksToBounds = YES;
}

+ (UIImage *) imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, [[UIScreen mainScreen] scale]);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}
+ (void) AddRoundedCorners:(UIView *)source{
    source.layer.cornerRadius = 5;
    source.layer.masksToBounds = YES;
}
+ (void) AddRoundedCornersForAlert:(UIView *)source{
    source.layer.cornerRadius = 7;
    source.layer.masksToBounds = YES;
    source.layer.borderColor = [UIColor colorWithHexString:iBORDERCOLOR].CGColor;
}
-(void)addinpushoffers:(NSDictionary *)offer{
    if ([pushOffers count]>0) {
        //Check For Duplicate
        if([offer objectForKey:@"id"]){
            NSPredicate *filterFor=[NSPredicate predicateWithFormat:@"(id = %@)", [offer objectForKey:@"id"]];
            NSArray *resultArray=[pushOffers filteredArrayUsingPredicate:filterFor];
            if ([resultArray count]>0) {
                [pushOffers removeObjectsInArray:resultArray];
            }
        }
    }
    NSMutableDictionary *offerUpdate=[NSMutableDictionary dictionaryWithDictionary:offer];
    [offerUpdate setObject:[NSNumber numberWithInt:1] forKey:@"unseen"];
    [pushOffers addObject:offerUpdate];
}
+ (void) AddBorder:(UIView *)source{
    CGFloat borderWidth = 1.0f;
    source.layer.borderColor = [UIColor colorWithHexString:iBORDERCOLOR].CGColor;// [UIColor colorWithRed:0.792 green:0.792 blue:0.792 alpha:1].CGColor; /*#cacaca*///[UIColor lightGrayColor].CGColor;
    source.layer.borderWidth = borderWidth;
    //source.layer.cornerRadius = 5;
    source.layer.cornerRadius = 3;
    source.layer.masksToBounds = YES;
}

@end
