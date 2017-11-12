//
//  WhatAMapClient.m
//  gpsindoor
//
//  Created by Sang.Mac.04 on 17/03/15.
//  Copyright (c) 2015 indooratlas. All rights reserved.
//

#import "WhatAMapClient.h"
#import <InTripper/InTripper.h>
@interface WhatAMapClient()

@end
static WhatAMapClient *_mapClient = nil;
@implementation WhatAMapClient
+ (WhatAMapClient *)instance {
    
    /*@synchronized (self) {
     if (_mapClient == nil) {
     
     }
     }*/
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_mapClient == nil) {
            //Error while creating object
        }
        
    });
    return _mapClient;
    
    return _mapClient;
}
+ (WhatAMapClient *) createinstance:(NSString *)mapid{
    if (_mapClient!=nil) {
        _mapClient=nil;
    }
    _mapClient = [[WhatAMapClient alloc] initWithBaseURL:[NSURL URLWithString:[kIOAPIURLString stringByAppendingFormat:@"%@/",mapid]]];
    return _mapClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super  initWithBaseURL:url];
    if (!self) {
        
        return nil;
    }
    self.requestSerializer = [AFJSONRequestSerializer serializer];
    self.responseSerializer = [AFJSONResponseSerializer serializer];
    //[self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
    //[self setDefaultHeader:@"Accept" value:@"application/json"];
    //[self setDefaultHeader:@"Accept" value:@"text/html"];
    
    // By default, the example ships with SSL pinning enabled for the app.net API pinned against the public key of adn.cer file included with the example. In order to make it easier for developers who are new to AFNetworking, SSL pinning is automatically disabled if the base URL has been changed. This will allow developers to hack around with the example, without getting tripped up by SSL pinning.
    /*if ([[url scheme] isEqualToString:@"https"] && [[url host] isEqualToString:@"alpha-api.app.net"]) {
     [self setDefaultSSLPinningMode:AFSSLPinningModePublicKey];
     }*/
    
    return self;
}
-(NSString *)connectedSite{
    return [self.baseURL absoluteString];
}
@end
