//
//  FuzzySearchClient.m
//  gpsindoor
//
//  Created by Sang.Mac.04 on 14/04/15.
//  Copyright (c) 2015 indooratlas. All rights reserved.
//

#import "FuzzySearchClient.h"
#import <InTripper/InTripper.h>
static FuzzySearchClient *_fuzzySearchClient = nil;
@implementation FuzzySearchClient
+ (FuzzySearchClient *)instance {
    
    /*@synchronized (self) {
     if (_mapClient == nil) {
     
     }
     }*/
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_fuzzySearchClient == nil) {
            //Error while creating object
        }
        
    });
    return _fuzzySearchClient;
    
}
+ (FuzzySearchClient *) createinstance{
    if (_fuzzySearchClient!=nil) {
        _fuzzySearchClient=nil;
    }
    _fuzzySearchClient = [[FuzzySearchClient alloc] initWithBaseURL:[NSURL URLWithString:kFuzzySearchAPIURLString]];
    return _fuzzySearchClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super  initWithBaseURL:url];
    if (!self) {
        
        return nil;
    }
    self.requestSerializer = [AFJSONRequestSerializer serializer];
    self.responseSerializer = [AFJSONResponseSerializer serializer];
    
    return self;
}

@end
