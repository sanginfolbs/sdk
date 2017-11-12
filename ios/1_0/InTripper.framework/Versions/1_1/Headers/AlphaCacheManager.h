//
//  CacheManager.h
//  alcatraz
//
//  Created by Sang.Mac.04 on 22/07/14.
//  Copyright (c) 2014 Sanginfo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlphaCacheManager : NSObject{}
-(NSArray *)getFromCache:(int )days WithIdentifier:(NSString *)cacheid;
-(NSMutableDictionary *)getDictFromCache:(int )days WithIdentifier:(NSString *)cacheid;
-(NSArray *)getFromCacheWithMinute:(int )minutes WithIdentifier:(NSString *)cacheid;
-(BOOL)putInCache:(NSArray *)data WithIdentifier:(NSString *)cacheid;
-(BOOL)putDictInCache:(NSMutableDictionary *)data WithIdentifier:(NSString *)cacheid;
-(BOOL)isCacheExpired:(int )days searchIn:(NSSearchPathDirectory) inDirectory WithIdentifier:(NSString *)cacheid;
-(BOOL)removeFromCache:(NSString *)cacheid;

@end
