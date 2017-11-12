//
//  UILabel+Boldify.m
//  InMaps
//
//  Created by Sang.Mac.04 on 17/02/14.
//  Copyright (c) 2014 Sanginfo. All rights reserved.
//

#import "UILabel+Boldify.h"

@implementation UILabel(Boldify)

- (void) boldUnderLineRange: (NSRange) range {
    if (![self respondsToSelector:@selector(setAttributedText:)]) {
        return;
    }
    NSMutableAttributedString *attributedText;
    if (!self.attributedText) {
        attributedText = [[NSMutableAttributedString alloc] initWithString:self.text];
    } else {
        attributedText = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    }
    [attributedText setAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"OpenSans-Semibold" size:self.font.pointSize],NSUnderlineStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleSingle]} range:range];
    self.attributedText = attributedText;
}

- (void) boldRange: (NSRange) range {
    if (![self respondsToSelector:@selector(setAttributedText:)]) {
        return;
    }
    NSMutableAttributedString *attributedText;
    if (!self.attributedText) {
        attributedText = [[NSMutableAttributedString alloc] initWithString:self.text];
    } else {
        attributedText = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    }
    [attributedText setAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"OpenSans-Semibold" size:self.font.pointSize]} range:range];
    self.attributedText = attributedText;
}


- (void) boldSubstring: (NSString*) substring {
    if (substring==nil) {
        return;
    }
    NSRange range = [self.text rangeOfString:substring];
    [self boldRange:range];
}

- (void) underlineRange: (NSRange) range {
    if (![self respondsToSelector:@selector(setAttributedText:)]) {
        return;
    }
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText] ;//[[NSMutableAttributedString alloc] initWithString:self.text];
    UIColor* textColor = [UIColor colorWithRed:1.0/255.0 green:174.0/255.0 blue:231.0/255.0 alpha:1.0];
    [attributedText setAttributes:@{NSForegroundColorAttributeName:textColor,NSUnderlineStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleSingle]} range:range];
    self.attributedText = attributedText;
}
- (void) underlineSubstring: (NSString*) substring {
    NSRange range = [self.text rangeOfString:substring];
    [self underlineRange:range];
}
- (void) boldUnderLineSubstring: (NSString*) substring{
    //NSRange range = [self.text rangeOfString:substring];
    //[self boldUnderLineRange:range];
    NSArray *ranges=[self rangesOfString:substring inString:self.text];
    for (NSValue *item in ranges) {
        [self boldUnderLineRange:[item rangeValue]];
    }
}

- (NSArray *)rangesOfString:(NSString *)searchString inString:(NSString *)str {
    NSMutableArray *results = [NSMutableArray array];
    NSRange searchRange = NSMakeRange(0, [str length]);
    NSRange range;
    while ((range = [str rangeOfString:searchString options:0 range:searchRange]).location != NSNotFound) {
        [results addObject:[NSValue valueWithRange:range]];
        searchRange = NSMakeRange(NSMaxRange(range), [str length] - NSMaxRange(range));
    }
    return results;
}

@end
