//
//  indoorio.h
//  gpsindoor
//
//  Created by Sang.Mac.04 on 17/03/15.
//  Copyright (c) 2015 indooratlas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface indoorio : NSObject
/**
 *  API Call
 *
 *  @param param
 *  @param block API Response
 */
    + (void)getDetail:(NSMutableDictionary *)param result:(void (^)(NSArray *posts, NSError *error))block;
/**
 *  POI Format Search to display
 *
 *  @param apiResponse
 *
 *  @return List of search
 */
    +(NSArray *)formatSearchResult:(NSArray *)apiResponse;
/**
 *  Format Amenities Search
 *
 *  @param apiResponse
 *
 *  @return List of Amenities
 */
    +(NSArray *)formatAmenitiesSearchResult:(NSArray *)apiResponse;
/**
 *  center Point
 *
 *  @param coordinates
 *
 *  @return Center location
 */
    +(CLLocationCoordinate2D)centerPoint:(NSArray *)coordinates;
@end
