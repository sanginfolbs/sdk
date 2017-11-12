//
//  IntripperLanguage.h
//  Intripper
//
//  Created by apple on 22/08/17.
//  Copyright © 2017 Sanginfo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IntripperLanguage : NSObject
    + (IntripperLanguage *)instance;
    -(void)setNewLocal:(int)mapid Local:(NSString *)locallanguage;
-(NSString *)translate:(NSString *)word;

@end
