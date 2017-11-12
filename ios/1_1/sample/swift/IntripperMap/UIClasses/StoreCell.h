//
//  StoreCell.h
//  InMaps
//
//  Created by Sang.Mac.04 on 12/02/14.
//  Copyright (c) 2014 Sanginfo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StoreCell : UITableViewCell
//@property (strong, nonatomic) IBOutlet UILabel *lblProduct;
//@property (strong, nonatomic) IBOutlet UIImageView *imgProduct;
//@property (strong, nonatomic) IBOutlet UILabel *lblDetail;
@property (strong, nonatomic) IBOutlet UIImageView *imgStoreLogo;
@property (strong, nonatomic) IBOutlet UILabel *lblStoreName;
@property (strong, nonatomic) IBOutlet UILabel *lblLevel;
@property (nonatomic, strong) NSString *strLogoURL;
@end


