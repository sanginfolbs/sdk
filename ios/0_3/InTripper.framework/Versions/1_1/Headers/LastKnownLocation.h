//
//  LastKnownLocation.h
//  InMaps
//
//  Created by Sang.Mac.04 on 08/09/14.
//  Copyright (c) 2014 Sanginfo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LastKnownLocation : NSObject

@property (nonatomic,retain)  NSNumber *mapid;
@property (nonatomic,retain)  NSNumber *floor;

+ (LastKnownLocation *)instance;
-(CGPoint)getLocation:(int)mapid;
-(void)setLocation:(CGPoint)location;
-(void)setgeoLocation:(double)lat longitude:(double)lng;
-(double)getlatitude;
-(double)getlongitude;

@end
