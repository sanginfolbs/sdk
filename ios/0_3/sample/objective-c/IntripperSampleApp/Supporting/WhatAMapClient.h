//
//  WhatAMapClient.h
//  gpsindoor
//
//  Created by Sang.Mac.04 on 17/03/15.
//  Copyright (c) 2015 indooratlas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>
@interface WhatAMapClient : AFHTTPRequestOperationManager
/**
 *  Single Object
 *
 *  @return WhatAMapClient
 */
    + (WhatAMapClient *) instance;
/**
 *  Create Instance
 *
 *  @param mapid for map
 *
 *  @return WhatAMapClient
 */
    + (WhatAMapClient *) createinstance:(NSString *)mapid;
-(NSString *)connectedSite;
@end
