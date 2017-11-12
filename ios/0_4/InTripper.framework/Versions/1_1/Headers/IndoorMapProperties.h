//
//  MapProperties.h
//  gpsindoor
//
//  Created by Sang.Mac.04 on 28/03/15.
//  Copyright (c) 2015 indooratlas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <GoogleMaps/GoogleMaps.h>
#import "IndoorMapObject.h"
@interface IndoorMapProperties : NSObject
+ (IndoorMapProperties *)instance;
+(instancetype)createNewMap:(NSDictionary *)details;
-(NSString *)FloorName:(int)ioFloor;
-(NSString *)ioMapID;
-(NSString *)IAFloorPlanID:(int)ioFloor;
-(NSString *)IAAPIapikey;
-(NSString *)IAAPIapiSecret;
-(CLLocationCoordinate2D)virtualCoordinate:(CGIndoorMapPoint)location;
-(CLLocationCoordinate2D)geoCoordinateFromVirtual:(CGIndoorMapPoint)location;
-(int)getMapFactor;
-(NSArray *)venueCategories;
-(void)setStoreCount:(NSArray *)stores;
-(NSString *)mapname;
-(NSString *)storeCategoryIcon:(NSString *)storeid;
-(NSArray *)LevelInformation;
-(NSArray *)FloorListIDs;
-(CGIndoorMapPoint)mapCenterPoint;
-(float) mapInitialZoom;
-(NSArray *)StoreLables;
-(void)SetStoreLables:(NSArray *)listLables;
-(NSString *)MapboxFloorPlanID:(int)ioFloor;
-(NSString *)MapboxMapToken;
-(GMSCoordinateBounds *)getAreaBound;
-(GMSPath *)getAreaRect;
-(float)maxMapZoom;
-(float)minMapZoom;
-(int)BackToLeashDistance;
-(int)maxPathDiversion;
-(NSDictionary *)extraSettings;
-(NSDictionary *)getBuildingAtUserLocation:(CGIndoorMapPoint)userLocation;
-(int)IAExternalFloorID:(NSString *)ioFloor;
-(NSArray *)buildingList;
@end
