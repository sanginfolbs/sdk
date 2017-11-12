//
//  MapSearch.h
//  Intripper
//
//  Created by Sanginfo on 03/02/16.
//  Copyright © 2016 Sanginfo. All rights reserved.
//

#import <Foundation/Foundation.h>
#define ToRadian(x) ((x) * M_PI/180)
#define ToDegrees(x) ((x) * 180/M_PI)
@class MapSearch;
/**
 *  Search types for MapSearch
 */
typedef NS_ENUM(NSInteger, SearchType) {
    /**
     *  Use for POI Search
     */
    Search_POI,
    /**
     *  Use for Amenities Search
     */
    Search_Amenity
};
/**
 *  Delegates for the events on MapSearch object.
 */
@protocol MapSearchDelegate<NSObject>
/**
 *  Called when the user starts typing in the search box.
 *
 *  @param sender An instance of MapSearch class.
 */
- (void)searchDidStartLoad:(MapSearch *)sender;
/**
 *  Called when the server returns the search results response.
 *
 *  @param sender   An instance of MapSearch class.
 *  @param response NSArray of search results to be displayed.
 */
- (void)searchDidFinishLoad:(MapSearch *)sender result:(NSArray *)response;

@end
/**
 *  This is the class used for Search operations in the Intripper SDK.
    The search object should be instantiated via the convenience constructor [[MapSearch alloc] init:<<SearchType>>];
 */
@interface MapSearch : NSObject
 @property(nonatomic,weak) id <MapSearchDelegate> mapSearchDelegate;
/**
 *  Initializes search APIs
 *
 *  @param searchFor Enum of SearchType (Search_POI/Search_Amenity)
 *
 *  @return Instance of MapSearch class.
 */
-(id)init:(SearchType)searchFor;

-(id)init:(SearchType)searchFor showArea:(BOOL)show;

/**
 *  Initializes search APIs
 *
 *  @param searchFor Enum of SearchType (Search_POI/Search_Amenity)
 *
 *  @return Instance of MapSearch class.
 */
-(id)init:(SearchType)searchFor withMapid:(int)map;
/**
 *  Performs the search operation by calling the relevant Search APIs.
 *
 *  @param text The text/term to search for.
 */
-(void)searching:(NSString *)text;

@end
