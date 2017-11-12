//
//  FuzzySearchClient.h
//  gpsindoor
//
//  Created by Sang.Mac.04 on 14/04/15.
//  Copyright (c) 2015 indooratlas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>
@interface FuzzySearchClient : AFHTTPRequestOperationManager
/**
 *  instance
 *
 *  @return FuzzySearchClient
 */
+ (FuzzySearchClient *) instance;
/**
 *  create instance
 *
 *  @return Instance
 */
+ (FuzzySearchClient *) createinstance;
@end
