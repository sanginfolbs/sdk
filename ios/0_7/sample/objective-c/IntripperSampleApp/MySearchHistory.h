//
//  MySearchHistory.h
//  InMaps
//
//  Created by Sang.Mac.04 on 03/05/14.
//  Copyright (c) 2014 Sanginfo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MySearchHistory : NSObject
+(NSArray *)getSearchHistory:(NSString *)cacheid;
+(BOOL)SaveHistory:(NSArray *)data WithIdentifier:(NSString *)cacheid;
@end
