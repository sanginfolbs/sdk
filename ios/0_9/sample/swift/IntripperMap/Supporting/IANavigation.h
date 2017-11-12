//
//  IANavigation.h
//  InMaps
//
//  Created by Sang.Mac.04 on 08/04/14.
//  Copyright (c) 2014 Sanginfo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <InTripper/InTripper.h>

@class IANavigation;
static NSString *kAPIKey = @"c4698801-c660-4d49-8fb7-4b1d0f4725f9";
static NSString *kAPISecret = @"znOx9iAAK9pyukAs8KL7qhgF2L&VJh6XD%MsCR%Qf0Ng1wp9OpyRm)srKZU%%6VaLpjg7jNisOquOKpNFN42n0PXDAxHJpCmxAJ5(4uDRzN4PUX8IsmkYywevLBVpSbu";
static NSString *kFloorplanId1 = @"b538542b-d52c-4534-a844-c483828b6391";
static NSString *kFloorplanId2 = @"ecb84198-75af-4352-b5b7-f67ea60f35a1";
static NSString *kFloorplanId3 = @"f9b5c4b5-1ae6-4498-9529-46b1d8b50e0c";

@protocol IANavigationDelegate <NSObject>
/**
 *  Updates user's location as per latest readings from Indoor Atlas SDK
 *
 *  @param manager     instance of IANavigation
 *  @param newLocation Lat/Long of new location
 *  @param geoPoint    Lat/Long of new location
 *  @param radius      radius
 *  @param direction   northheading direction angle
 */
- (void)IAlocation:(IANavigation *)manager didUpdateLocation:(CGPoint)newLocation andLatLng:(CGIndoorMapPoint) geoPoint accuracy:(double)radius heading:(double)direction;

- (void)discoveringUserLocation:(IANavigation *)manager;
- (void)calibrationDone:(IANavigation *)manager isBackground:(BOOL)onBackground;
- (void)calibrationFailed:(IANavigation *)manager isBackground:(BOOL)onBackground;
/**
 *  Calls when the Indoor Atlas SDK throws an error e.g. during limited network connectivity
 *
 *  @param manager  Instance of IANavigation
 *  @param errorapi NSString Error to be shown
 */
- (void)fatalError:(IANavigation *)manager error:(NSString *)errorapi;
/**
 *  Calls when Indoor Atlas SDK throws an error while detecting user's location
 *
 *  @param manager    instance of IANavigation
 *  @param infostring NSString Error message
 */
- (void)walkToFixLocation:(IANavigation *)manager info:(NSString *)infostring;
/**
 *  Check for user's location unavailablity due to limited network connectivity
 *
 *  @param manager  instance of IANavigation
 *  @param errorapi NSString Error to display
 */
- (void)IAlocationUnavailable:(IANavigation *)manager error:(NSString *)errorapi;
/**
 *  Checks for user's location availablity in the venue
 *
 *  @param manager instance of IANavigation
 */
- (void)IAlocationAvailable:(IANavigation *)manager;

@optional
- (void)indoorAtlasNorthHeading:(double)northHead;
/**
 *  Called when the app gets a stabilised location for the blue dot on the map
 *
 *  @param manager Instance of IANavigation
 */
- (void)conversionDone:(IANavigation *)manager;
/**
 *  This is to acquire a stablised position for the blue dot on the map based on the diffrent readings from Indoor Atlas SDk
 *
 *  @param manager Instance of IANavigation
 */
- (void)conversionBegin:(IANavigation *)manager;
- (void)calibrationFinish:(IANavigation *)manager;
/**
 *  Tracks the status of convergence though various readings from Indoor Atlas SDK
 *
 *  @param manager    instance of IANavigation
 *  @param infostring NSString
 */
- (void)convergenceStatus:(IANavigation *)manager info:(NSString *)infostring;
//- (void)indoorAtlaslocation:(IANavigation *)manager didUpdateLocation:(CGPoint)newLocation floor:(int)floorlevel lat:(double)lat lng:(double)lng;
@end
@interface IANavigation : NSObject{
}
-(id)init:(NSString *)apikey hash:(NSString *)apisecret;
-(id)init:(NSString *)apikey hash:(NSString *)apisecret floorids:(NSArray *)floorlist;
@property (nonatomic, weak) id <IANavigationDelegate> Delegate;

-(void)StartInDoorAtlas:(float)mapScale  andmap:(int)mapid andApi:(NSDictionary *)api;
/**
 *  Resets IndoorAtlas Service
 */
-(void)ResetInDoorAtlas;
/**
 *  Stops IndoorAtlas Service
 */
-(void)StopInDoorAtlas;
/**
 *  Get's floor where user is present
 *
 *  @return int - floor
 */
-(int)floorNumber;
//-(void)initCalibration;
-(BOOL)isServiceActive;
@end

