//
//  WaitViewController.h
//  gpsindoor
//
//  Created by Sang.Mac.04 on 28/03/15.
//  Copyright (c) 2015 indooratlas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WaitViewController : UIViewController
@property (weak,nonatomic) IBOutlet UILabel *lblInfo;
@property(weak,nonatomic) IBOutlet UIActivityIndicatorView *loader;
@property (weak, nonatomic) IBOutlet UIImageView *imgLoader;
/**
 *  Shows Loader like google preloader for background tasks
 */
+(void)ShowLoader;
/**
 *  Shows Loader with custom text
 *
 *  @param text NSString- The text to show on loader
 */
+(void)ShowLoader:(NSString *)text;
/**
 *  Hides the loader
 */
+(void)HideLoader;
@end
