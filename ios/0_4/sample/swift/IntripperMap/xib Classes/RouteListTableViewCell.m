//
//  RouteListTableViewCell.m
//  shoppingmall
//
//  Created by Sanginfo on 08/01/16.
//  Copyright © 2016 Sanginfo. All rights reserved.
//

#import "RouteListTableViewCell.h"

@implementation RouteListTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
+ (NSString *)reuseIdentifier {
    return @"RouteListCell";
}

@end
