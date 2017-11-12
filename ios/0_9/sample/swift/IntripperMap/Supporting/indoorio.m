//
//  indoorio.m
//  gpsindoor
//
//  Created by Sang.Mac.04 on 17/03/15.
//  Copyright (c) 2015 indooratlas. All rights reserved.
//
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "indoorio.h"
#import "WhatAMapClient.h"
@implementation indoorio
+ (void) getDetail:(NSMutableDictionary *)param result:(void (^)(NSArray *posts, NSError *error))block{
    
    NSString  *apiendpoint=[param objectForKey:@"ep"];
    [param removeObjectForKey:@"ep"];
    //NSLog(@"%@",param);
    //NSLog(@"way server %@",[[WhatAMapClient instance] connectedSite]);
    [[WhatAMapClient instance] GET:apiendpoint parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *outPath;
        if ([responseObject isKindOfClass:[NSArray class]]){
            outPath=[[NSMutableArray alloc] initWithArray:responseObject];
        }
        else{
            outPath=[[NSMutableArray alloc] initWithObjects:responseObject, nil];
        }
        
        if (block) {
            block([NSArray arrayWithArray:outPath], nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block([NSArray array], error);
        }
    }];
}

+(NSArray *)formatSearchResult:(NSArray *)apiResponse{
    NSMutableArray *storeinfo=[[NSMutableArray alloc] init];
    NSMutableArray *locationArray=[[NSMutableArray alloc] init];
    for (NSDictionary *row in apiResponse) {
        NSArray *features=[row objectForKey:@"features"];
        for (NSDictionary *feature in features) {
            NSDictionary *geometry=[feature objectForKey:@"geometry"];
            NSDictionary *properties=[feature objectForKey:@"properties"];
            NSString *store=[properties objectForKey:@"attrs-store"];
            if (store) {
                NSArray *coordinates= [geometry objectForKey:@"coordinates"][0];
                NSMutableArray *endpoint=[[NSMutableArray alloc] init];
                
                [locationArray removeAllObjects];
                for (NSArray *point in coordinates) {
                    [endpoint addObject:[NSString stringWithFormat:@"%f,%f",[[point objectAtIndex:1] floatValue], [[point objectAtIndex:0] floatValue]]];
                    [locationArray addObject:[[CLLocation alloc] initWithLatitude:[[point objectAtIndex:1] floatValue]
                                                                        longitude:[[point objectAtIndex:0] floatValue]]];
                }
                
                
                NSString *level=[properties objectForKey:@"level"];
                
                CLLocationCoordinate2D centeroidarea=[indoorio centerPoint:locationArray];
                
                NSString *centroidpoint=[NSString stringWithFormat:@"%f,%f",centeroidarea.longitude,centeroidarea.latitude];
                
                NSString *centerpoint=[properties objectForKey:@"attrs-_referenceLocation"];
                
                if (centerpoint==nil) {
                    centerpoint=[NSString stringWithFormat:@"%f,%f",centeroidarea.longitude,centeroidarea.latitude];
                }
                else{
                    //Convert to virtual point
                    //MapProperties *mp=[MapProperties instance];
                    NSArray *centersplit=[centerpoint componentsSeparatedByString:@","];
                    CLLocationCoordinate2D ptcenter=CLLocationCoordinate2DMake([centersplit[1] doubleValue], [centersplit[0] doubleValue]);//[mp virtualCoordinate:CGMakeMapPoint([centersplit[1] doubleValue], [centersplit[0] doubleValue], 0)];
                    centerpoint=[NSString stringWithFormat:@"%f,%f",ptcenter.longitude,ptcenter.latitude];
                    
                }
                NSMutableString *category=[[NSMutableString alloc] init];
                if ([properties objectForKey:@"attrs-product_categories"]){
                    [category appendString:@", "];
                    [category appendString:[properties objectForKey:@"attrs-product_categories"]];
                }
               
                if ([properties objectForKey:@"attrs-category"]){
                    [category appendString:@", "];
                    [category appendString:[properties objectForKey:@"attrs-category"]];
                }
                
                if ([properties objectForKey:@"attrs-product_categories_men"]){
                    [category appendString:@", "];
                    [category appendString:[properties objectForKey:@"attrs-product_categories_men"]];
                }
                
                if ([properties objectForKey:@"attrs-product_categories_women"]){
                    [category appendString:@", "];
                    [category appendString:[properties objectForKey:@"attrs-product_categories_women"]];
                }
                
                
                NSString *facilities;
                if ([properties objectForKey:@"attrs-store_facilities"])
                    facilities=[properties objectForKey:@"attrs-store_facilities"];
                else
                    facilities=@"-";
                
                /*NSString *unitId;
                if ([properties objectForKey:@"unitId"])
                    unitId=[properties objectForKey:@"unitId"];
                else
                    unitId=@"-";
                NSArray *areaids;
                if ([properties objectForKey:@"areas"])
                    areaids=[properties objectForKey:@"areas"];
                else
                    areaids=[[NSArray alloc]init];
                */
                
                NSString *description;
                if ([properties objectForKey:@"attrs-store_description"])
                    description=[properties objectForKey:@"attrs-store_description"];
                else
                    description=@"-";
                
                NSString *storeimage;
                if ([properties objectForKey:@"attrs-store_image"])
                    storeimage=[properties objectForKey:@"attrs-store_image"];
                else
                    storeimage=@"-";
                
                NSString *storelogo;
                if ([properties objectForKey:@"attrs-store_logo"]){
                    //http://res.cloudinary.com/wlabs/image/fetch/b_rgb:FFFFFF,c_pad,h_114,w_168/http://res.cloudinary.com/wlabs/image/upload/v1/retailer/a/aq-ar/aritzia/us/logos/4072logogray.png
                    NSString *url=[properties objectForKey:@"attrs-store_logo"];
                    NSArray *urls=[url componentsSeparatedByString:@"http"];
                    if ([urls count]==3) {
                        storelogo=[NSString stringWithFormat:@"http%@",urls[2]];
                    }
                    else
                        storelogo=[NSString stringWithFormat:@"http%@",urls[1]];
                    }
                else
                    storelogo=@"-";
                
                NSString *storehours;
                if ([properties objectForKey:@"attrs-hours"])
                    storehours=[properties objectForKey:@"attrs-hours"];
                else
                    storehours=@"-";
                
                NSString *url;
                if ([properties objectForKey:@"attrs-store_url"])
                    url=[properties objectForKey:@"attrs-store_url"];
                else
                    url=@"";
                
                NSString *ph;
                if ([properties objectForKey:@"attrs-store_phone"])
                    ph=[properties objectForKey:@"attrs-store_phone"];
                else
                    ph=@"";
                
                
                NSString *areaId=[properties objectForKey:@"IID"];
                NSDictionary *temp=[NSDictionary dictionaryWithObjectsAndKeys:[store capitalizedString],@"store"
                                    ,[NSNumber numberWithInt:[level intValue]],@"floor"
                                    ,centerpoint,@"center"
                                    ,centroidpoint,@"centroid"
                                    ,category,@"category"
                                    ,facilities,@"facilities"
                                    ,endpoint,@"polygon"
                                    ,areaId,@"id"
                                    ,description,@"desc"
                                    ,storeimage,@"img"
                                    ,storelogo,@"logo"
                                    ,storehours,@"hours"
                                    ,url,@"url"
                                    ,ph,@"ph"
                                    , nil];
                // ,unitId,@"unit"
                //,areaids,@"area"
                [storeinfo addObject:temp];
                
            }
            
        }
        
    }
    return storeinfo;
}
+(NSArray *)formatAmenitiesSearchResult:(NSArray *)apiResponse{
    NSMutableArray *storeinfo=[[NSMutableArray alloc] init];
    NSMutableArray *locationArray=[[NSMutableArray alloc] init];
    for (NSDictionary *row in apiResponse) {
        NSArray *features=[row objectForKey:@"features"];
        for (NSDictionary *feature in features) {
            NSDictionary *geometry=[feature objectForKey:@"geometry"];
            NSDictionary *properties=[feature objectForKey:@"properties"];
            //NSString *store=[properties objectForKey:@"attrs-tags"];
            //NSString *store=[properties objectForKey:@"areaAttrs-store"];
             NSString *store=[properties objectForKey:@"attrs-title"];
            if(!store){
                NSString *strStreet = [properties objectForKey:@"attrs-Street"];
                if(strStreet){
                     store = [NSString stringWithFormat:@"%@ %@",strStreet,[properties objectForKey:@"attrs-tags"] ];
                }
                else{
                    store = [properties objectForKey:@"attrs-tags"];
                }
                
                
            }
            if (store) {
                NSArray *coordinates= [geometry objectForKey:@"coordinates"];
                NSMutableArray *endpoint=[[NSMutableArray alloc] init];
                
                [locationArray removeAllObjects];
                
                if ([[geometry objectForKey:@"type"] isEqualToString:@"Point"]) {
                    [endpoint addObject:[NSString stringWithFormat:@"%f,%f",[[coordinates objectAtIndex:1] floatValue], [[coordinates objectAtIndex:0] floatValue]]];
                    [locationArray addObject:[[CLLocation alloc] initWithLatitude:[[coordinates objectAtIndex:1] floatValue]
                                                                        longitude:[[coordinates objectAtIndex:0] floatValue]]];
                }
                else{
                for (NSArray *areapoint in coordinates) {
                    [endpoint addObject:[NSString stringWithFormat:@"%f,%f",[[areapoint objectAtIndex:1] floatValue], [[areapoint objectAtIndex:0] floatValue]]];
                    [locationArray addObject:[[CLLocation alloc] initWithLatitude:[[areapoint objectAtIndex:1] floatValue]
                                                                        longitude:[[areapoint objectAtIndex:0] floatValue]]];
                }
                }
                
                NSString *level=[properties objectForKey:@"level"];
                
                CLLocationCoordinate2D centeroidarea=[indoorio centerPoint:locationArray];
                
                NSString *centroidpoint=[NSString stringWithFormat:@"%f,%f",centeroidarea.longitude,centeroidarea.latitude];
                
                NSString *centerpoint=[properties objectForKey:@"attrs-_referenceLocation"];
                
                if (centerpoint==nil) {
                    centerpoint=[NSString stringWithFormat:@"%f,%f",centeroidarea.latitude,centeroidarea.longitude];
                }
                else{
                    //Convert to virtual point
                    //MapProperties *mp=[MapProperties instance];
                    NSArray *centersplit=[centerpoint componentsSeparatedByString:@","];
                    CLLocationCoordinate2D ptcenter=CLLocationCoordinate2DMake([centersplit[1] doubleValue], [centersplit[0] doubleValue]);//[mp virtualCoordinate:CGMakeMapPoint([centersplit[1] doubleValue], [centersplit[0] doubleValue], 0)];
                    centerpoint=[NSString stringWithFormat:@"%f,%f",ptcenter.latitude,ptcenter.longitude];
                    
                }
                NSMutableString *category=[[NSMutableString alloc] init];
                if ([properties objectForKey:@"attrs-product_categories"]){
                    [category appendString:@", "];
                    [category appendString:[properties objectForKey:@"attrs-product_categories"]];
                }
                
                if ([properties objectForKey:@"attrs-category"]){
                    [category appendString:@", "];
                    [category appendString:[properties objectForKey:@"attrs-category"]];
                }
                
                if ([properties objectForKey:@"attrs-product_categories_men"]){
                    [category appendString:@", "];
                    [category appendString:[properties objectForKey:@"attrs-product_categories_men"]];
                }
                
                if ([properties objectForKey:@"attrs-product_categories_women"]){
                    [category appendString:@", "];
                    [category appendString:[properties objectForKey:@"attrs-product_categories_women"]];
                }
                
                
                NSString *facilities;
                if ([properties objectForKey:@"attrs-store_facilities"])
                    facilities=[properties objectForKey:@"attrs-store_facilities"];
                else
                    facilities=@"-";
                
                /*NSString *unitId;
                 if ([properties objectForKey:@"unitId"])
                 unitId=[properties objectForKey:@"unitId"];
                 else
                 unitId=@"-";
                 NSArray *areaids;
                 if ([properties objectForKey:@"areas"])
                 areaids=[properties objectForKey:@"areas"];
                 else
                 areaids=[[NSArray alloc]init];
                 */
                
                NSString *description;
                if ([properties objectForKey:@"attrs-store_description"])
                    description=[properties objectForKey:@"attrs-store_description"];
                else
                    description=@"-";
                
                NSString *storeimage;
                if ([properties objectForKey:@"attrs-store_image"])
                    storeimage=[properties objectForKey:@"attrs-store_image"];
                else
                    storeimage=@"-";
                
                NSString *storelogo;
                if ([properties objectForKey:@"attrs-store_logo"]){
                    //http://res.cloudinary.com/wlabs/image/fetch/b_rgb:FFFFFF,c_pad,h_114,w_168/http://res.cloudinary.com/wlabs/image/upload/v1/retailer/a/aq-ar/aritzia/us/logos/4072logogray.png
                    NSString *url=[properties objectForKey:@"attrs-store_logo"];
                    NSArray *urls=[url componentsSeparatedByString:@"http"];
                    if ([urls count]==3) {
                        storelogo=[NSString stringWithFormat:@"http%@",urls[2]];
                    }
                    else
                        storelogo=[NSString stringWithFormat:@"http%@",urls[1]];
                }
                else
                    storelogo=@"-";
                
                NSString *storehours;
                if ([properties objectForKey:@"attrs-hours"])
                    storehours=[properties objectForKey:@"attrs-hours"];
                else
                    storehours=@"-";
                
                NSString *url;
                if ([properties objectForKey:@"attrs-store_url"])
                    url=[properties objectForKey:@"attrs-store_url"];
                else
                    url=@"";
                
                NSString *ph;
                if ([properties objectForKey:@"attrs-store_phone"])
                    ph=[properties objectForKey:@"attrs-store_phone"];
                else
                    ph=@"";
                
                
                NSString *areaId=[properties objectForKey:@"IID"];
                 NSString *locatedAt=store;
//                NSDictionary *temp=[NSDictionary dictionaryWithObjectsAndKeys:[store capitalizedString],@"store"
//                                    ,[NSNumber numberWithInt:[level intValue]],@"floor"
//                                    ,centerpoint,@"center"
//                                    ,centroidpoint,@"centroid"
//                                    ,category,@"category"
//                                    ,facilities,@"facilities"
//                                    ,endpoint,@"polygon"
//                                    ,areaId,@"id"
//                                    ,description,@"desc"
//                                    ,storeimage,@"img"
//                                    ,storelogo,@"logo"
//                                    ,storehours,@"hours"
//                                    ,url,@"url"
//                                    ,ph,@"ph"
//                                    , nil];
                // ,unitId,@"unit"
                //,areaids,@"area"
                NSDictionary *temp=[NSDictionary dictionaryWithObjectsAndKeys:store,@"store"
                                    ,[NSNumber numberWithInt:[level intValue]],@"floor"
                                    ,description,@"desc"
                                    ,areaId,@"id"
                                    ,storelogo,@"logo"
                                    ,@"brand_match",@"origin"
                                    ,endpoint,@"polygon"
                                    ,category,@"categories"
                                    ,@"",@"brands"
                                    ,centerpoint,@"center"
                                    ,[NSNumber numberWithInt:1],@"sortat"
                                    ,locatedAt,@"locatedat"
                                    , nil];

                [storeinfo addObject:temp];
                
            }
            
        }
        
    }
    return storeinfo;
}
+(CLLocationCoordinate2D)centerPoint:(NSArray *)coordinates{
    
    CLLocationDegrees minLat = 0.0,minLng = 0.0,maxLat = 0.0,maxLng = 0.0;
    int i=0;
    
    for(CLLocation *coordinate in coordinates) {
        if (i==0) {
            minLat = coordinate.coordinate.latitude;
            minLng = coordinate.coordinate.longitude;
            
            maxLat = coordinate.coordinate.latitude;
            maxLng = coordinate.coordinate.longitude;
        }
        else{
            minLat = MIN(minLat, coordinate.coordinate.latitude);
            minLng = MIN(minLng, coordinate.coordinate.longitude);
        
            maxLat = MAX(maxLat, coordinate.coordinate.latitude);
            maxLng = MAX(maxLng, coordinate.coordinate.longitude);
        }
        i=i+1;
    }
    
    CLLocationCoordinate2D coordinateOrigin = CLLocationCoordinate2DMake(minLat, minLng);
    CLLocationCoordinate2D coordinateMax = CLLocationCoordinate2DMake(maxLat, maxLng);
    
    MKMapPoint upperLeft = MKMapPointForCoordinate(coordinateOrigin);
    MKMapPoint lowerRight = MKMapPointForCoordinate(coordinateMax);
    
    //Create the map rect
    MKMapRect mapRect = MKMapRectMake(upperLeft.x,
                                      upperLeft.y,
                                      lowerRight.x - upperLeft.x,
                                      lowerRight.y - upperLeft.y);
    
    //Create the region
    MKCoordinateRegion region = MKCoordinateRegionForMapRect(mapRect);
    
    //THIS HAS THE CENTER, it should include spread
    //NSLog(@"%f",region.center.latitude);
    //NSLog(@"%f",region.center.longitude);
    return region.center;
    
}
@end
