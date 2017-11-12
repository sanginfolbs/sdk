//
//  IndoorAtlasNavigation.m
//  InMaps
//
//  Created by Sang.Mac.04 on 08/04/14.
//  Copyright (c) 2014 Sanginfo. All rights reserved.
//
#import <UIKit/UIKit.h>

#import "IANavigation.h"
#import <IndoorAtlas/IALocationManager.h>
#import <IndoorAtlas/IAResourceManager.h>
#import <AudioToolbox/AudioServices.h>
#import "NSMutableArray+Evaluation.h"


#ifndef APPTESTENV
#ifdef DEBUG
//#define APPTESTENV
#endif
#endif

@interface IANavigation()<IALocationManagerDelegate>{
    CGPoint paddingpoint;
    BOOL blnStopedBYSDK;
    int maxSampleresult;
    volatile int apiErrorCount;
    BOOL CalibrationStarted;
    BOOL convergenceOccur;
    BOOL networkError;
    BOOL serviceStoped;
    BOOL _convergenceStatusHandler;
    BOOL _handShakeWithIA;
}
@property (nonatomic, strong) IALocationManager *manager;
@property (nonatomic, strong) IAResourceManager *resourceManager;
@property (nonatomic, strong) IAFloorPlan *floorPlan;


@property (nonatomic, retain) NSNumber*   imageScale;
@property (nonatomic, retain) NSString*   apikey;
@property (nonatomic, retain) NSString*   apiSecret;
@property (nonatomic, retain) NSString*   graphicID;
@property (nonatomic, retain) NSNumber*   floorNo;
@property (nonatomic, retain) NSNumber*   setAccessKey;
@property (nonatomic,retain)  NSMutableArray *LoactionReadings;
@property (nonatomic, retain) NSString*   lastFloorDetected;
@property (nonatomic,retain)  NSMutableArray *venuefloorsids;
@end
@implementation IANavigation
-(id)init:(NSString *)apikey hash:(NSString *)apisecret floorids:(NSArray *)floorlist{
    self = [super init];
    if (self) {
        self.apikey=apikey;
        self.apiSecret=apisecret;
        self.setAccessKey=[NSNumber numberWithBool:YES];
        // Create IALocationManager and point delegate to receiver
        self.manager = [IALocationManager new];
        
        // Set IndoorAtlas API key and secret
        [self.manager setApiKey:self.apikey andSecret:self.apiSecret];
        self.floorNo=[NSNumber numberWithInt:-999];
        self.venuefloorsids=[NSMutableArray arrayWithArray:floorlist];
        self.manager.delegate = self;
        [self.manager startUpdatingLocation];
        
    }
    return self;
    
}
-(id)init:(NSString *)apikey hash:(NSString *)apisecret{
    self = [super init];
    if (self) {
        self.apikey= apikey;
        self.apiSecret=apisecret;
        
        self.setAccessKey=[NSNumber numberWithBool:YES];
        // Create IALocationManager and point delegate to receiver
        self.manager = [IALocationManager new];
        self.manager.delegate = self;
        
        // Set IndoorAtlas API key and secret
        [self.manager setApiKey:self.apikey andSecret:self.apiSecret];
        self.floorNo=[NSNumber numberWithInt:-999];
        self.venuefloorsids=[[NSMutableArray alloc] init];
        [self.venuefloorsids addObject:kFloorplanId1];
        [self.venuefloorsids addObject:kFloorplanId2];
        [self.venuefloorsids addObject:kFloorplanId3];
        
    }
    return self;
}

-(BOOL)isFloorIDInList:(NSString *)seachid{
    BOOL isidPresent=NO;
    for (NSString *item in self.venuefloorsids) {
        if ([item isEqualToString:seachid]) {
            isidPresent=YES;
            break;
        }
    }
    return isidPresent;
}

#pragma mark IALocationManager delegate methods

- (void)indoorLocationManager:(IALocationManager *)manager didEnterRegion:(IARegion *)region
{
    NSLog(@"Floor detected as %@",region.identifier);
    if ([self isFloorIDInList:region.identifier]) {
        NSLog(@"Floorplan in Active List");
        if ([region.identifier isEqualToString:self.graphicID]) {
            [self fetchFloorplanWithId:region.identifier];
        }
        else{
            NSLog(@"Not Selected Floorplan");
        }
        
    }
    else{
        //No Floor plan in Active List close Conversion
        [self setCriticalLog:[NSString stringWithFormat:@"Alien Floor id %@",region.identifier] ];
        /*if (!convergenceOccur) {
         //convergenceOccur=YES;
         if ([self.Delegate respondsToSelector:@selector(conversionDone:)]) {
         [self.Delegate conversionDone:self];
         }
         }*/
    }
    
    /*
     if ([region.identifier isEqualToString:self.lastFloorDetected]) {
     //[self fetchFloorplanWithId:region.identifier];
     }
     else{
     self.lastFloorDetected=region.identifier;
     if ([self.lastFloorDetected isEqualToString:self.graphicID]) {
     [self fetchFloorplanWithId:region.identifier];
     }
     else{
     //New Floor plan detected
     
     }
     }
     */
}


/**
 * Fetch floor plan and image with ID
 * These methods are just wrappers around server requests.
 * You will need api key and secret to fetch resources.
 */
- (void)fetchFloorplanWithId:(NSString*)floorplanId
{
    if (_handShakeWithIA) {
        NSLog(@"calling same fetchFloorPlanWithId previously");
        return;
    }
    NSLog(@"on fetchFloorplanWithId:%@",floorplanId);
    CalibrationStarted=NO;
    convergenceOccur=NO;
    networkError=NO;
    return;
    __weak typeof(self) weakSelf = self;
    _handShakeWithIA=YES;
    [self.resourceManager fetchFloorPlanWithId:floorplanId andCompletion:^(IAFloorPlan *floorplan, NSError *error) {
        _handShakeWithIA=NO;
        if (error) {
            [self setCriticalLog:[NSString stringWithFormat:@"opps,%@ there was error during floorplan fetch: %@", floorplanId,error]];
            
            apiErrorCount=apiErrorCount+1;
            networkError=YES;
            NSLog(@"api error log at fetch %d",apiErrorCount);
            if(apiErrorCount<4){
                //[self.Delegate walkToFixLocation:self info:@"Waiting for location. \nKeep walking my friend."];
                [weakSelf performSelector:@selector(NetworkErrorfetchFloorplanWithId:) withObject:floorplanId afterDelay:0.2f];
            }
            else{
                [weakSelf.Delegate fatalError:self error:@"Indoor position cannot be determined due to limited network connectivity."];
                [weakSelf setCriticalLog:@"Indoor position cannot be determined due to limited network connectivity."];
            }
            return;
        }
        
        NSLog(@"fetched floorplan with id: %@", floorplanId);
        weakSelf.floorPlan = floorplan;
    }];
}


-(void)NetworkErrorfetchFloorplanWithId:(NSString*)floorplanId{
    if (networkError) {
        [self fetchFloorplanWithId:floorplanId];
    }
}

/**
 * Authenticate to IndoorAtlas services
 */
- (void)authenticateAndFetchFloorplan
{
    // Create floor plan manager
    self.resourceManager = [IAResourceManager resourceManagerWithLocationManager:self.manager];
    
    // Optionally set initial location
    NSLog(@"Start Location for :%@",self.graphicID);
    IALocation *location = [IALocation locationWithFloorPlanId:self.graphicID];
    self.manager.location = location;
    
    // Request location updates
    //[self.manager startUpdatingLocation];
    
}


/**
 *  Start indoor atlas service
 *
 *  @param mapScale default 1
 *  @param mapid    map refrence
 *  @param api      detail apikey,apiSecret,graphicID,floor,padding
 */
-(void)StartInDoorAtlas:(float)mapScale  andmap:(int)mapid andApi:(NSDictionary *)api{
    NSLog(@"starting IndoorAtlas");
    if (![self.graphicID isEqualToString:[api objectForKey:@"graphicID"]]) {
        if (self.LoactionReadings==nil) {
            self.LoactionReadings=[[NSMutableArray alloc] init ];
        }
        else{
            [self.LoactionReadings removeAllObjects];
        }
    }
    _convergenceStatusHandler=[self.Delegate respondsToSelector:@selector(convergenceStatus:info:)];
    /*else{
     if (serviceStoped==NO) {
     return;
     }
     }*/
    
    serviceStoped=NO;
    maxSampleresult=10;
    
    self.imageScale=[NSNumber numberWithFloat:mapScale];
    self.graphicID=[api objectForKey:@"graphicID"]==nil?@"":[api objectForKey:@"graphicID"];
    if ([api objectForKey:@"floor"]) {
        self.floorNo=[api objectForKey:@"floor"];
    }
    NSString *padding=[api objectForKey:@"padding"];
    
    NSArray *paddingxy = [padding componentsSeparatedByString:@","];
    paddingpoint=CGPointMake([[paddingxy objectAtIndex:0] floatValue], [[paddingxy objectAtIndex:1] floatValue]);
    if (![self.graphicID isEqualToString:@""]) {
        
        [self setCriticalLog:[NSString stringWithFormat:@"Started service for floor %d with floorid %@",[self.floorNo intValue],self.graphicID]];
        if (self.floorPlan==nil) {
            NSLog(@"new Plan id %@",self.graphicID);
            _handShakeWithIA=NO;
            [self.manager stopUpdatingLocation];
            IALocation *location = [IALocation locationWithFloorPlanId:self.graphicID];
            self.manager.location = location;
            [self.manager startUpdatingLocation];
            convergenceOccur=NO;
            //[self authenticateAndFetchFloorplan];
            //[self fetchFloorplanWithId:self.graphicID];
            if (!convergenceOccur) {
                if ([self.Delegate respondsToSelector:@selector(conversionBegin:)]) {
                    [self.Delegate conversionBegin:self];
                }
            }
        }
        else{
            NSLog(@"ok new Plan id %@",self.graphicID);
            self.floorPlan=nil;
            IALocation *location = [IALocation locationWithFloorPlanId:self.graphicID];
            self.manager.location = location;
            _handShakeWithIA=NO;
            [self fetchFloorplanWithId:self.graphicID];
            convergenceOccur=NO;
            if (!convergenceOccur) {
                if ([self.Delegate respondsToSelector:@selector(conversionBegin:)]) {
                    [self.Delegate conversionBegin:self];
                }
            }
        }
    }
    //NSLog(@"%@",api);
    /*}
     else{
     NSLog(@"alredy started positioning");
     }*/
}
-(void)ResetInDoorAtlas{
    if (networkError) {
        [self authenticateAndFetchFloorplan];
    }
}
-(void)StopInDoorAtlas{
    
    blnStopedBYSDK=NO;
    serviceStoped=YES;
    [self.manager stopUpdatingLocation];
    self.floorPlan=nil;
    //[self.LoactionReadings removeAllObjects];
    apiErrorCount=0;
    //self.graphicID=@"";
}
-(void)NetworkFailStopInDoorAtlas{
    blnStopedBYSDK=NO;
    serviceStoped=YES;
    [self.manager stopUpdatingLocation];
    //[self.LoactionReadings removeAllObjects];
    //apiErrorCount=0;
    //self.graphicID=@"";
}


#pragma mark IndoorAtlasPositionerDelegate methods

/**
 * Handle location changes
 */
- (void)indoorLocationManager:(IALocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    
    
    //if (self.floorPlan != nil) {
        //loc.floor
        
        IALocation* loc = [locations lastObject];
        IAFloor *floorID=[(IALocation*)locations.lastObject floor];
        if (floorID==nil) {
            NSLog(@"Invalid Floor");
            return;
        }
        if((int)floorID.level==[self.floorNo intValue]){
             //[self setLogSkyZone:loc.location.coordinate.latitude and:loc.location.coordinate.longitude withAcuracy:loc.location.horizontalAccuracy andstatus:self.graphicID];
            //[self setLogSGalleria:loc.location.coordinate.latitude and:loc.location.coordinate.longitude withAcuracy:loc.location.horizontalAccuracy andstatus:self.graphicID];
            
#ifndef APPTESTENV
            if(loc.location.horizontalAccuracy>=40)
            {
                if (!convergenceOccur) {
                    [self.Delegate IAlocation:self didUpdateLocation:CGPointMake(0, 0) andLatLng:CGMakeMapPoint(loc.location.coordinate.latitude, loc.location.coordinate.longitude, [self.floorNo intValue]) accuracy:loc.location.horizontalAccuracy heading:loc.location.course];//False reading not use for location
                    [self setLog:loc.location.coordinate.latitude and:loc.location.coordinate.longitude withAcuracy:loc.location.horizontalAccuracy andstatus:@"skiped"];
                }
                
                return;
            }
#else
            //NSLog(@"Accuracy %f",loc.location.horizontalAccuracy);
            if(loc.location.horizontalAccuracy>30)
            {
                if (!convergenceOccur) {
                    [self.Delegate IAlocation:self didUpdateLocation:CGPointMake(0, 0) andLatLng:CGMakeMapPoint(loc.location.coordinate.latitude, loc.location.coordinate.longitude, [self.floorNo intValue]) accuracy:loc.location.horizontalAccuracy heading:loc.location.course];//False reading not use for location
                    [self setLog:loc.location.coordinate.latitude and:loc.location.coordinate.longitude withAcuracy:loc.location.horizontalAccuracy andstatus:@"skiped"];
                }
                return;
            }
#endif
            
            
            [self setLog:loc.location.coordinate.latitude and:loc.location.coordinate.longitude withAcuracy:loc.location.horizontalAccuracy andstatus:self.graphicID];
            
            apiErrorCount=0;
            if(self.Delegate!=nil){
                CGPoint cp;
                
                cp =CGPointMake(loc.location.coordinate.latitude,loc.location.coordinate.longitude);
                [self.LoactionReadings enqueue:[NSValue valueWithCGPoint:cp] andmaxadd:maxSampleresult];
                if ([self.LoactionReadings count]==1) {//First reading
                    if ([self.Delegate respondsToSelector:@selector(calibrationFinish:)]) {
                        [self.Delegate calibrationFinish:self];
                    }
                }
                
                if ([self.LoactionReadings count]>7) {
                    NSValue *avarage=[self.LoactionReadings MeanGEO];
                    CGPoint p = [avarage CGPointValue];
                    CLLocation *apiLocation=[[CLLocation alloc] initWithLatitude:loc.location.coordinate.latitude longitude:loc.location.coordinate.longitude];
                    CLLocation *meanLocation=[[CLLocation alloc] initWithLatitude:p.x longitude:p.y];
                    CLLocationDistance difference= [apiLocation distanceFromLocation:meanLocation ];
                    //NSLog(@"Diffrence distance %f",difference);
                    double maxTorrance=7;
#ifdef APPTESTENV
                    //TODO set 7
                    maxTorrance=7;
#endif
                    if (difference<=maxTorrance) {
                        if (!convergenceOccur) {
                            convergenceOccur=YES;
                            if ([self.Delegate respondsToSelector:@selector(conversionDone:)]) {
                                [self.Delegate conversionDone:self];
                            }
                        }
                        
                        //NSLog (@"%lu",(unsigned long)[self.LoactionReadings count]);
                        
                        //[self.Delegate indoorAtlaslocation:self didUpdateLocation:cp floor:[self.floorNo intValue] lat:position.coordinate.latitude lng:position.coordinate.longitude];
                        if ([self.Delegate respondsToSelector:@selector(indoorAtlasNorthHeading:)]) {
                            [self.Delegate indoorAtlasNorthHeading:loc.location.course];
                        }
                        [self.Delegate IAlocation:self didUpdateLocation:cp andLatLng:CGMakeMapPoint(loc.location.coordinate.latitude, loc.location.coordinate.longitude, [self.floorNo intValue]) accuracy:loc.location.horizontalAccuracy heading:loc.location.course];
                        
                        [self setLog:loc.location.coordinate.latitude and:loc.location.coordinate.longitude withAcuracy:loc.location.horizontalAccuracy andstatus:[NSString stringWithFormat:@"Correct %f,%f",difference,maxTorrance]];
                    }
                    else{
                        //[self.Delegate discoveringUserLocation:self];
                        if (!convergenceOccur) {
                            [self.Delegate convergenceStatus:self info:@"discovering location"];
                            [self setLog:loc.location.coordinate.latitude and:loc.location.coordinate.longitude withAcuracy:loc.location.horizontalAccuracy andstatus:@"discovering location"];
                        }
                    }
                    
                }
                else{
                    //[self.Delegate indoorAtlaslocation:self didUpdateLocation:cp floor:[self.floorNo intValue] lat:position.coordinate.latitude lng:position.coordinate.longitude];
                    //NSLog();
                    if (!convergenceOccur) {
                        if(_convergenceStatusHandler){
                            [self.Delegate convergenceStatus:self info:[NSString stringWithFormat:@"reading %lu",(unsigned long)[self.LoactionReadings count]]];
                        }
                        //[self.Delegate walkToFixLocation:self info:@"Waiting for location. \nKeep walking my friend."];
                        [self.Delegate IAlocation:self didUpdateLocation:cp andLatLng:CGMakeMapPoint(loc.location.coordinate.latitude, loc.location.coordinate.longitude, [self.floorNo intValue]) accuracy:loc.location.horizontalAccuracy heading:loc.location.course];
                        [self setLog:loc.location.coordinate.latitude and:loc.location.coordinate.longitude withAcuracy:loc.location.horizontalAccuracy andstatus:[NSString stringWithFormat:@"reading %lu",(unsigned long)[self.LoactionReadings count]]];
                    }
                }
                
            }
        }
        else{
            IAFloor *floorID=[loc floor];
            
            [self setCriticalLog:[NSString stringWithFormat:@"Floor %ld %@",(long)floorID.level,[loc.region identifier]]];
        }
        
    //}
    
}
- (void)indoorLocationManager:(nonnull IALocationManager*)manager statusChanged:(nonnull IAStatus*)status{
    NSString *statusDisplay;
    switch (status.type) {
        case kIAStatusServiceAvailable:
            statusDisplay=@"Connected";
            break;
        case kIAStatusServiceOutOfService:
            statusDisplay=@"OutOfservice";
            break;
        case kIAStatusServiceUnavailable:
            statusDisplay=@"Service Unavailable";
            break;
        case kIAStatusServiceLimited:
            if(_convergenceStatusHandler){
                //[self.Delegate convergenceStatus:self info:@"Waiting For Fix"];
                [self.Delegate convergenceStatus:self info:@"Acquiring location"];
            }
            statusDisplay=@"Service Limited";
            break;
        default:
            statusDisplay=@"Unknown";
            break;
    }
    NSLog(@"IALocationManager status %d %@",status.type, statusDisplay) ;
    
}



/**
 * State packet handling from IndoorAtlasPositioner
 */
/*- (void)indoorAtlasPositioner:(IndoorAtlasPositioner*)positioner stateChanged:(IndoorAtlasPositionerState*)state
 {
 static NSString *map[] = {
 @"kIndoorAtlasPositioningStateStopped",
 @"kIndoorAtlasPositioningStateConnecting",
 @"kIndoorAtlasPositioningStateReconnecting",
 @"kIndoorAtlasPositioningStateConnected",
 @"kIndoorAtlasPositioningStateLoading",
 @"kIndoorAtlasPositioningStateReady",
 @"kIndoorAtlasPositioningStateWaitingForFix",
 @"kIndoorAtlasPositioningStatePositioning"
 @"kIndoorAtlasPositioningStateBuffering",
 @"kIndoorAtlasPositioningStateHeavyBuffering",
 };
 
 if (state.error) {
 //apiErrorCount=0;
 switch (state.error.code) {
 case kIndoorAtlasErrorRequestTimedOut:
 [self.Delegate IAlocationUnavailable:self error:@"Indoor position cannot be determined due to limited network connectivity."];
 break;
 case kIndoorAtlasErrorServiceUnavailable:
 [self.Delegate IAlocationUnavailable:self error:@"Indoor Atlas service temporarily unavailable."];
 break;
 case kIndoorAtlasErrorNoNetwork:
 [self.Delegate IAlocationUnavailable:self error:@"Indoor position cannot be determined due to limited network connectivity."];
 break;
 case kIndoorAtlasErrorLowSamplingRate:
 [self.Delegate IAlocationUnavailable:self error:@"Indoor position cannot be determined due to limited network connectivity."];
 break;
 default:
 [self.Delegate IAlocationUnavailable:self error:@"Network or service temporarily unavailable."];
 break;
 }
 networkError=YES;
 [self setCriticalLog:[NSString stringWithFormat:@"Network failed state changed to %@ (%d)", map[state.state], state.state]];
 NSLog(@"Network failed state changed to %@ (%d)", map[state.state], state.state);
 //[self StopInDoorAtlas];
 } else {
 if (state.state==kIndoorAtlasPositioningStateWaitingForFix) {
 if ([IndoorAtlasBackgroundCalibrator quality]== kIndoorAtlasCalibrationQualityPoor) {
 if(_convergenceStatusHandler){
 [self.Delegate convergenceStatus:self info:@"Calibration needed!"];
 }
 //[self.Delegate walkToFixLocation:self info:@"Calibration needed!"];
 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.4f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
 //[self.Delegate walkToFixLocation:self info:@"Please shake your phone to re-calibrate."];
 CalibrationStarted=YES;
 
 
 });
 }
 else{
 if(_convergenceStatusHandler){
 [self.Delegate convergenceStatus:self info:@"Waiting For Fix"];
 }
 
 //[self.Delegate walkToFixLocation:self info:@"Waiting for location.\nKeep walking my friend"];
 
 }
 }
 else if(state.state==kIndoorAtlasPositioningStatePositioning){
 if (CalibrationStarted) {
 //Vibrate phone
 AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
 CalibrationStarted=NO;
 }
 }
 else if(state.state==kIndoorAtlasPositioningStateConnecting){
 networkError=NO;
 if (!convergenceOccur) {
 if ([self.Delegate respondsToSelector:@selector(conversionBegin:)]) {
 [self.Delegate conversionBegin:self];
 }
 }
 }
 else if(state.state==kIndoorAtlasPositioningStateConnected){
 networkError=NO;
 [self.Delegate IAlocationAvailable:self];
 }
 
 
 NSLog(@"state changed to %@ (%d)", map[state.state], state.state);
 }
 
 if(blnStopedBYSDK){
 if (state.state == kIndoorAtlasPositioningStateStopped) {
 if ([positioner.floorplan.floorplanId isEqualToString: self.graphicID]) {
 // Start again from calibration if positioning stopped and floor plan was not changed
 apiErrorCount=apiErrorCount+1;
 NSLog(@"api error log at Loop %d",apiErrorCount);
 if(apiErrorCount<4){
 //[self.Delegate walkToFixLocation:self info:@"Waiting for location. \nKeep walking my friend."];
 [self NetworkFailStopInDoorAtlas];
 [self performSelector:@selector(NetworkErrorStartPositioningWithFloorplan:) withObject:positioner.floorplan afterDelay:3.0f];
 }
 else{
 [self StopInDoorAtlas];
 [self.Delegate fatalError:self error:@"Indoor position cannot be determined due to limited network connectivity."];
 [self setCriticalLog:@"Positioning Error:limited network connectivity."];
 
 }
 
 }
 
 [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
 } else {
 // It is good idea to disable idle timer when positioning.
 // This prevents the screen from dimming.
 [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
 }
 
 }
 
 }
 */

/*#pragma mark IndoorAtlasBackgroundCalibratorDelegate methods
 
 - (void)indoorAtlasBackgroundCalibratorDidStartCalibrating
 {
 NSLog(@"background calibrator started");
 }
 
 - (void)indoorAtlasBackgroundCalibratorDidFinishCalibratingWithStatus:(BOOL)failed
 {
 NSLog(@"background calibrator finished with %s", (failed ? "failure" : "success"));
 }
 
 - (void)indoorAtlasBackgroundCalibratorProgress:(float)progress
 {
 NSLog(@"background calibrator progress: %.0f%%", progress * 100.0f);
 }*/

#pragma mark IndoorAtlasPositionerDelegate methods

-(void)setLog:(float)lat and:(float)lng withAcuracy:(float)acu andstatus:(NSString *)state{
    NSLog(@"%@ location %f/%f %f",state,lat,lng,acu);
    return;
    
    CLLocation *lt=[[CLLocation alloc] initWithLatitude:lat longitude:lng];
   
    
    
}




-(void)setCriticalLog:(NSString *)state{
    NSLog(@"%@",state);
    return;
}
/*
-(void)setLogSkyZone:(float)lat and:(float)lng withAcuracy:(float)acu andstatus:(NSString *)state{
    PFObject *testObject = [PFObject objectWithClassName:@"skyzone"];
    CLLocation *lt=[[CLLocation alloc] initWithLatitude:lat longitude:lng];
    PFGeoPoint *vp=[PFGeoPoint geoPointWithLocation:lt];
    //testObject.ob
    testObject[@"location"] = vp;
    NSString *dateString = [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                          dateStyle:NSDateFormatterShortStyle
                                                          timeStyle:NSDateFormatterLongStyle];
    testObject[@"accuracy"]=[NSNumber numberWithFloat:acu];
    testObject[@"status"]=state;
    testObject[@"Floor"]=self.floorNo;
    testObject[@"user"] = [NSNumber numberWithInteger:111];
    testObject[@"app"]=[[NSBundle mainBundle] bundleIdentifier];
    testObject[@"devicetime"] = dateString;
    [testObject saveInBackground];
}

-(void)setLogSGalleria:(float)lat and:(float)lng withAcuracy:(float)acu andstatus:(NSString *)state{
    PFObject *testObject = [PFObject objectWithClassName:@"galleria"];
    CLLocation *lt=[[CLLocation alloc] initWithLatitude:lat longitude:lng];
    PFGeoPoint *vp=[PFGeoPoint geoPointWithLocation:lt];
    //testObject.ob
    testObject[@"location"] = vp;
    NSString *dateString = [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                          dateStyle:NSDateFormatterShortStyle
                                                          timeStyle:NSDateFormatterLongStyle];
    testObject[@"accuracy"]=[NSNumber numberWithFloat:acu];
    testObject[@"status"]=state;
    testObject[@"Floor"]=self.floorNo;
    testObject[@"user"] = [NSNumber numberWithInteger:111];
    testObject[@"app"]=[[NSBundle mainBundle] bundleIdentifier];
    testObject[@"devicetime"] = dateString;
    [testObject saveInBackground];
}*/
-(int)floorNumber{
    return  [self.floorNo intValue];
}
-(BOOL)isServiceActive{
    return !serviceStoped;
}
@end
