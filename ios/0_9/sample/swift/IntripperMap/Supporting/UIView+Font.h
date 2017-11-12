//
//  UIView+Font.h
//  gpsindoor
//
//  Created by Sang.Mac.04 on 27/03/15.
//  Copyright (c) 2015 indooratlas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView(Font)
- (NSMutableArray*) allSubViews;
/**
 *  Applies a universal font across views and its child elements
 *
 *  @param appView UIView 
 */
+(void)ChangeAppFont:(UIView *) appView;
@end
