//
//  GoogleFloorButton.m
//  InMaps
//
//  Created by Sang.Mac.04 on 25/09/14.
//  Copyright (c) 2014 Sanginfo. All rights reserved.
//

#import "IntripperFloorButton.h"
#import "UIColor+Expanded.h"
#import "IntripperEnvironment.h"
@interface IntripperFloorButton()
{
}
@property (nonatomic,retain)  NSNumber *buttonOfferCount;
@end
@implementation IntripperFloorButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)ShowCircleLayer:(int)offerCount
{
    if (offerCount==0){
        CALayer *borderLayer=[self circleLayer];
        if (borderLayer!=nil) {
            [borderLayer removeFromSuperlayer];
            [self.layer needsDisplay];
        }
    }
    else{
        CALayer *oldcircleLayer=[self circleLayer];
        if (oldcircleLayer!=nil) {
            [oldcircleLayer removeFromSuperlayer];
        }
    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    [circleLayer setFrame:self.layer.bounds];
    [circleLayer setPath:[[UIBezierPath bezierPathWithOvalInRect:CGRectMake(5, 7, self.bounds.size.width-10, self.bounds.size.width-10)] CGPath]];
    [circleLayer setName:@"offers"];
    [circleLayer setStrokeColor:[[UIColor colorWithHexString:iFONTCOLOR] CGColor]];
    [circleLayer setFillColor:[[UIColor clearColor] CGColor]];
    circleLayer.rasterizationScale = 2.0 * [UIScreen mainScreen].scale;
    circleLayer.shouldRasterize = YES;
    
    CGRect  containerFrame=circleLayer.frame;
    
    CGRect markerFrame=CGRectMake(containerFrame.size.width-13, 6, 12, 12);
    CGRect txtFrame=CGRectMake(containerFrame.size.width-13, 7, 12, 12);
        
    CAShapeLayer *redDotLayer = [CAShapeLayer layer];
    [redDotLayer setFrame:markerFrame];
    [redDotLayer setPath:[[UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, markerFrame.size.width, markerFrame.size.width)] CGPath]];
    [redDotLayer setFillColor:[[UIColor redColor] CGColor]];
    [redDotLayer setCornerRadius:6.0f];
    redDotLayer.rasterizationScale = 2.0 * [UIScreen mainScreen].scale;
    redDotLayer.shouldRasterize = YES;
    [circleLayer addSublayer:redDotLayer];
    
    CATextLayer *label = [[CATextLayer alloc] init];
    [label setName:@"textlayer"];
    [label setFont:@"OpenSans"];
    [label setFontSize:8];
    [label setFrame:txtFrame];
    [label setString:[NSString stringWithFormat:@"%d",offerCount]];
    [label setAlignmentMode:kCAAlignmentCenter];
    [label setForegroundColor:[[UIColor whiteColor] CGColor]];
    [label setBackgroundColor:[[UIColor clearColor] CGColor]];
    label.rasterizationScale = 2.0 * [UIScreen mainScreen].scale;
    label.shouldRasterize = YES;
    //label.position=CGPointMake(6, 6);
    [circleLayer insertSublayer:label above:redDotLayer];
    
    [self.layer addSublayer:circleLayer];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)setSelected:(BOOL)selected
{
    super.selected=selected;
    if (selected) {
        self.backgroundColor = [UIColor whiteColor];
        [[self layer] setBorderWidth:.7f];
        [[self layer] setBorderColor:[[UIColor lightGrayColor] colorWithAlphaComponent:.5f].CGColor];
        self.layer.zPosition=INT_MAX;
        CALayer *borderLayer=[self BorderLayer];
        if (borderLayer!=nil) {
            //[borderLayer removeFromSuperlayer];
            borderLayer.borderColor=[[UIColor whiteColor] colorWithAlphaComponent:.5f].CGColor;
            [borderLayer setNeedsDisplay];
        }
        NSLog(@"Offer Count %d",[self.buttonOfferCount intValue]);
        [self ShowCircleLayer:[self.buttonOfferCount intValue]];
        /*CALayer *circleLayer=[self circleLayer];
        if (circleLayer!=nil) {
            //[self ShowCircleLayer:0];
        }*/
    }
    else {
        self.backgroundColor = [UIColor whiteColor];
        [[self layer] setBorderWidth:0.0f];
        [[self layer] setBorderColor:[UIColor clearColor].CGColor];
        self.layer.zPosition=INT_MIN;
        CALayer *borderLayer=[self BorderLayer];
        if (borderLayer!=nil) {
            borderLayer.borderColor=[[UIColor lightGrayColor] colorWithAlphaComponent:.5f].CGColor;
        }
        
        [self ShowCircleLayer:[self.buttonOfferCount intValue]];
        
        
    }
}
- (CALayer *)circleLayer {
    for (CALayer *layer in [self.layer sublayers]) {
        
        if ([[layer name] isEqualToString:@"offers"]) {
            return layer;
        }
    }
    return nil;
}


- (CALayer *)BorderLayer {
    for (CALayer *layer in [self.layer sublayers]) {
        
        if ([[layer name] isEqualToString:@"border"]) {
            return layer;
        }
    }
    return nil;
}

-(void)setOfferCount:(int)offercount{
    self.buttonOfferCount=[NSNumber numberWithInt:offercount];
}
@end
