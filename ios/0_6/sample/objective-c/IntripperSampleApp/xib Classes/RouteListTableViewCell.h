//
//  RouteListTableViewCell.h
//  shoppingmall
//
//  Created by Sanginfo on 08/01/16.
//  Copyright © 2016 Sanginfo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RouteListTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *imgInstrDir;
@property (strong, nonatomic) IBOutlet UILabel *lblInstr;
@property (strong, nonatomic) IBOutlet UILabel *lblDist;
@property (strong, nonatomic) IBOutlet UIImageView *imgSepLine;
+ (NSString *)reuseIdentifier;
@end
