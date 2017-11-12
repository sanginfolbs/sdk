//
//  UILabel_Boldify.h
//  InMaps
//
//  Created by Sang.Mac.04 on 17/02/14.
//  Copyright (c) 2014 Sanginfo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (Boldify){
}
/**
 *  Makes a part of a string in bold
 *
 *  @param substring NSString part of string to be made bold
 */
- (void) boldSubstring: (NSString*) substring;
/**
 *  Makes a part of a string bold and underlined
 *
 *  @param substring substring NSString part of string to be made bold and underlined
 */
- (void) boldUnderLineSubstring: (NSString*) substring;
/**
 *  Underlines a part of a string
 *
 *  @param substring NSString part of a string to be underlined
 */
- (void) underlineSubstring: (NSString*) substring;
@end
