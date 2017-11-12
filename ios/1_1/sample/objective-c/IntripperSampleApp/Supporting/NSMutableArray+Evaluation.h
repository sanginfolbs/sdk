//
//  NSMutableArray+QueueAdditions.h
//  ciscobce
//
//  Created by Blackhawk on 13/12/11.
//  Copyright 2011 CISCO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

/**
   @brief Implement Queue logic
 */
@interface NSMutableArray (Evaluation)
- (id)dequeue;
-(void)enqueue : (id)obj andmaxadd:(int)maxItem ;

-(NSValue *)MeanGEO;
-(NSValue *)MeanLast3;

@end