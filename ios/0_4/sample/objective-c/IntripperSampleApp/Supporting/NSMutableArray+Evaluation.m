//
//  NSMutableArray+QueueAdditions.m
//  ciscobce
//
//  Created by Blackhawk on 13/12/11.
//  Copyright 2011 CISCO. All rights reserved.
//

#import "NSMutableArray+Evaluation.h"
/**
   @brief Implement Queue logic
 */
@implementation NSMutableArray (Evaluation)
/// Queues are first-in-first-out, so we remove objects from the head
- (id) dequeue {
	// if ([self count] == 0) return nil; // to avoid raising exception (Quinn)
	id headObject = [self objectAtIndex: 0];
	if (headObject != nil) {
		//[[headObject retain] autorelease]; // so it isn't dealloc'ed on remove
		[self removeObjectAtIndex: 0];
	}
	return headObject;
}

/// Add to the tail of the queue (no one likes it when people cut in line!)
- (void) enqueue: (id) anObject andmaxadd:(int)maxItem {
    if([self count]==maxItem){
        [self dequeue];
    }
	[self addObject: anObject];
	//this method automatically adds to the end of the array
}

-(NSValue *)MeanGEO{
    float xSum=0;
    float ySum=0;
    for (NSValue *item in self) {
        CGPoint currentpoint=[item CGPointValue];
        xSum=xSum+currentpoint.x;
        ySum=ySum+currentpoint.y;
    }
    if([self count]>0){
    xSum=xSum/[self count];
    ySum=ySum/[self count];
    }
    return [NSValue valueWithCGPoint:CGPointMake((float)xSum,(float)ySum)];
}
-(NSValue *)MeanLast3{
    float xSum=0;
    float ySum=0;
    if (self.count>3) {
        int j=self.count-3;
        for (int i=j; i<self.count; i++) {
            NSValue *item=[self objectAtIndex:i];
            CGPoint currentpoint=[item CGPointValue];
            xSum=xSum+currentpoint.x;
            ySum=ySum+currentpoint.y;
        }
        xSum=xSum/3;
        ySum=ySum/3;
        return [NSValue valueWithCGPoint:CGPointMake((int)xSum,(int)ySum)];
    }
    else{
        return [NSValue valueWithCGPoint:CGPointMake((int)xSum,(int)ySum)];
    }
}

@end