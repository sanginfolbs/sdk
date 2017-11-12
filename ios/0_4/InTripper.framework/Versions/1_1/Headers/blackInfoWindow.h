//
//  blackInfoWindow.h
//  shoppingmall
//
//  Created by Sanginfo on 30/12/15.
//  Copyright © 2015 Sanginfo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface blackInfoWindow : UIViewController
@property (strong, nonatomic) IBOutlet UIImageView *imgLeft;
@property (strong, nonatomic) IBOutlet UIImageView *imgRight;
-(void)setText:(NSString *)data;
@end
