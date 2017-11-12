//
//  FuzzySearchAPI.h
//  gpsindoor
//
//  Created by Sang.Mac.04 on 14/04/15.
//  Copyright (c) 2015 indooratlas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FuzzySearchAPI : NSObject
/**
 *  API Call
 *
 *  @param param
 *  @param block 
 */
 + (void)getDetail:(NSMutableDictionary *)param result:(void (^)(NSArray *posts, NSError *error))block;
/**
 *  format fuzzy Search Result
 *
 *  @param apiResponse
 *  @param searchString
 *
 *  @return List of Search
 */
+(NSArray *)formatfuzzySearchResult:(NSArray *)apiResponse andSearchFor:(NSString *)searchString;
@end
