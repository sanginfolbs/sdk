//
//  FuzzySearchAPI.m
//  gpsindoor
//
//  Created by Sang.Mac.04 on 14/04/15.
//  Copyright (c) 2015 indooratlas. All rights reserved.
//

#import "FuzzySearchAPI.h"
#import "FuzzySearchClient.h"
#import <MapKit/MapKit.h>

@implementation FuzzySearchAPI
+ (void) getDetail:(NSMutableDictionary *)param result:(void (^)(NSArray *posts, NSError *error))block{
    
    NSString  *apiendpoint=[param objectForKey:@"ep"];
    [param removeObjectForKey:@"ep"];
    [[FuzzySearchClient instance] GET:apiendpoint parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *outPath;
        if ([responseObject isKindOfClass:[NSArray class]]){
            outPath=[[NSMutableArray alloc] initWithArray:responseObject];
        }
        else{
            outPath=[[NSMutableArray alloc] initWithObjects:responseObject, nil];
        }
        //NSLog(@"result count %d",(int)[outPath count]);
        [outPath insertObject:param atIndex:0];
        //NSLog(@"result count after %d",(int)[outPath count]);

        if (block) {
            block([NSArray arrayWithArray:outPath], nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block([NSArray array], error);
        }
    }];
}

+(NSArray *)formatfuzzySearchResult:(NSArray *)apiResponse andSearchFor:(NSString *)searchString{
    NSMutableArray *storeinfo=[[NSMutableArray alloc] init];
    NSMutableArray *locationArray=[[NSMutableArray alloc] init];
    for (NSDictionary *row in apiResponse) {
        NSArray *features=[row objectForKey:@"features"];
        for (NSDictionary *feature in features) {
            NSDictionary *geometry=[feature objectForKey:@"geometry"];
            
            NSDictionary *properties=[feature objectForKey:@"properties"];
            NSString *store;
            NSString *areaId;
            NSString *pinPoint;
            if ([properties objectForKey:@"store"]) {
                NSDictionary *storeDetail=[properties objectForKey:@"store"];
                store=[[storeDetail objectForKey:@"name"] capitalizedString];
                areaId=[storeDetail objectForKey:@"IID"];
            }
            else if([properties objectForKey:@"attrs-store"]){
                store=[[properties objectForKey:@"attrs-store"] capitalizedString];
                areaId=[properties objectForKey:@"IID"];
            }
            else{
                areaId=@"-";
                store=@"-";
            }
            NSString *locatedAt=store;
            if ([properties objectForKey:@"attrs-_referenceLocation"])
            {
                NSArray *splitArray=[[properties objectForKey:@"attrs-_referenceLocation"] componentsSeparatedByString:@","];
                
//                pinPoint=[NSString stringWithFormat:@"%f,%f",[splitArray[1] doubleValue],[splitArray[0] doubleValue]];
                pinPoint=[NSString stringWithFormat:@"%f,%f",[splitArray[0] doubleValue],[splitArray[1] doubleValue]];
            }
            else{
                if([[geometry objectForKey:@"type"] isEqualToString:@"Point"]){
                    NSArray *coordinates= [geometry objectForKey:@"coordinates"];
                    pinPoint=[NSString stringWithFormat:@"%f,%f",[coordinates[1] floatValue],[coordinates[0] floatValue]];
                }
                else{
                    NSArray *coordinates= [geometry objectForKey:@"coordinates"][0];
                    [locationArray removeAllObjects];
                    for (NSArray *point in coordinates) {
                        
                        [locationArray addObject:[[CLLocation alloc] initWithLatitude:[[point objectAtIndex:1] floatValue]
                                                                            longitude:[[point objectAtIndex:0] floatValue]]];
                    }
                    
                    CLLocationCoordinate2D centeroidarea=[FuzzySearchAPI centerStorePoint:locationArray];
                    pinPoint=[NSString stringWithFormat:@"%f,%f",centeroidarea.longitude,centeroidarea.latitude];
//                    pinPoint=[NSString stringWithFormat:@"%f,%f",centeroidarea.latitude,centeroidarea.longitude];
                }
            }
            if(![store isEqualToString:@"-"]){
                NSString *level=[properties objectForKey:@"level"];
                NSString *origin=[properties objectForKey:@"origin"];
                NSString *description=@"";
                NSString *storelogo;
                if ([properties objectForKey:@"attrs-store_logo"]){
                    NSString *url=[properties objectForKey:@"attrs-store_logo"];
                    NSArray *urls=[url componentsSeparatedByString:@"http"];
                    if ([urls count]==3) {
                        storelogo=[NSString stringWithFormat:@"http%@",urls[2]];
                    }
                    else
                        storelogo=[NSString stringWithFormat:@"http%@",urls[1]];
                }
                else{
                    
                    storelogo=@"-";
                }
                NSMutableDictionary *matchFor=[[NSMutableDictionary alloc] init];
                NSMutableArray *category=[[NSMutableArray alloc] init];
                NSMutableArray *brand=[[NSMutableArray alloc] init];
                
                if ([properties objectForKey:@"_match"]){
                    
                    matchFor=[NSMutableDictionary dictionaryWithDictionary:[properties objectForKey:@"_match"]];
                    NSMutableSet *removeDuplicte=[[NSMutableSet alloc] init];

                    if ([matchFor objectForKey:@"properties.attrs-category"]) {
                        NSArray *attrs_category=[matchFor objectForKey:@"properties.attrs-category"];
                        
                        for (NSString *itCategory in attrs_category) {
                            NSArray *splitArray=[itCategory componentsSeparatedByString:@","];
                            for (NSString *item in splitArray) {
                                 NSString *tempItem=[item stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                                if (![[tempItem capitalizedString] isEqualToString:store]) {
                                    NSUInteger rowCount=[removeDuplicte count];
                                    [removeDuplicte addObject:tempItem];
                                    if (rowCount!=[removeDuplicte count]) {
                                        [category addObject:tempItem];
                                    }
                                }
                                
                            }
                        }
                       
                    }
                    
                    NSArray *arrtempCategory=[properties objectForKey:@"categories"];
                    if (arrtempCategory!=nil) {
                        for (NSString *item in arrtempCategory) {
                            NSString *tempItem=[item stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                            if (![[tempItem capitalizedString] isEqualToString:store]) {
                                NSUInteger rowCount=[removeDuplicte count];
                                [removeDuplicte addObject:tempItem];
                                if (rowCount!=[removeDuplicte count]) {
                                    [category addObject:tempItem];
                                }
                            }
                        }
                    }
                    
                    //category=[NSMutableArray arrayWithArray:[removeDuplicte allObjects]];
                    /*if ([matchFor objectForKey:@"properties.categories"]) {
                        [category addObjectsFromArray:[matchFor objectForKey:@"properties.categories"]];
                         //category=[NSMutableArray arrayWithArray:[matchFor objectForKey:@"properties.categories"]];
                    }*/
                     
                    //[category addObjectsFromArray:[matchFor objectForKey:@"properties.categories"]];
                    
                    NSMutableSet *removeDuplicateBrand=[[NSMutableSet alloc] init];
                    
                    if ([matchFor objectForKey:@"properties.brands"]) {
                        for (NSString *item in [matchFor objectForKey:@"properties.brands"]) {
                             NSString *tempItem=[item stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                            if (![[tempItem capitalizedString] isEqualToString:store]) {
                                NSUInteger rowCount=[removeDuplicateBrand count];
                                [removeDuplicateBrand addObject:tempItem];
                                if (rowCount!=[removeDuplicateBrand count]) {
                                    [brand addObject:tempItem];
                                }
                            }
                        }
                    }
                    NSArray *arrtempbrands=[properties objectForKey:@"brands"];
                    if (arrtempbrands!=nil) {
                        for (NSString *item in arrtempbrands) {
                            NSString *tempItem=[item stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                            if (![[tempItem capitalizedString] isEqualToString:store]) {
                                NSUInteger rowCount=[removeDuplicateBrand count];
                                [removeDuplicateBrand addObject:tempItem];
                                if (rowCount!=[removeDuplicateBrand count]) {
                                    [brand addObject:tempItem];
                                }
                            }
                        }
                    }
                    //brand=[NSMutableArray arrayWithArray:[NSMutableArray arrayWithArray:[removeDuplicateBrand allObjects]]];
                }
                else{
                //Dont hav _match in API call
                    NSMutableSet *removeDuplicte=[[NSMutableSet alloc] init];
                    NSArray *arrtempCategory=[properties objectForKey:@"categories"];
                    if (arrtempCategory!=nil) {
                        for (NSString *item in arrtempCategory) {
                            NSString *tempItem=[item stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                            if (![[tempItem capitalizedString] isEqualToString:store]) {
                                NSUInteger rowCount=[removeDuplicte count];
                                [removeDuplicte addObject:tempItem];
                                if (rowCount!=[removeDuplicte count]) {
                                    [category addObject:tempItem];
                                }
                            }
                        }
                    }
                    
                    NSMutableSet *removeDuplicateBrand=[[NSMutableSet alloc] init];
                    NSArray *arrtempbrands=[properties objectForKey:@"brands"];
                    if (arrtempbrands!=nil) {
                        for (NSString *item in arrtempbrands) {
                            NSString *tempItem=[item stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                            if (![[tempItem capitalizedString] isEqualToString:store]) {
                                NSUInteger rowCount=[removeDuplicateBrand count];
                                [removeDuplicateBrand addObject:tempItem];
                                if (rowCount!=[removeDuplicateBrand count]) {
                                    [brand addObject:tempItem];
                                }
                            }
                        }
                    }
                    
                }
                NSString *gtype=[geometry objectForKey:@"type"];
                NSArray *coordinates;
                NSMutableArray *endpoint=[[NSMutableArray alloc] init];
                if ([gtype isEqualToString:@"Point"]) {
                    coordinates= [geometry objectForKey:@"coordinates"];
                    [endpoint addObject:[NSString stringWithFormat:@"%f,%f",[[coordinates objectAtIndex:1] floatValue], [[coordinates objectAtIndex:0] floatValue]]];
                    pinPoint=[NSString stringWithFormat:@"%f,%f",[[coordinates objectAtIndex:1] floatValue], [[coordinates objectAtIndex:0] floatValue]];
                }
                else{
                    coordinates= [geometry objectForKey:@"coordinates"][0];
                    for (NSArray *point in coordinates) {
                        [endpoint addObject:[NSString stringWithFormat:@"%f,%f",[[point objectAtIndex:1] floatValue], [[point objectAtIndex:0] floatValue]]];
                    }
                }
                NSNumber *sortLevel;
                
                if ([origin isEqualToString:@"category_match"]) {
                    sortLevel=[NSNumber numberWithInt:1];//[NSNumber numberWithInt:3];
                }
                else if ([origin isEqualToString:@"brand_match"]) {
                    sortLevel=[NSNumber numberWithInt:1];//[NSNumber numberWithInt:2];
                }
                else if ([origin isEqualToString:@"brand_or_category_match"]) {
                    sortLevel=[NSNumber numberWithInt:1];
                }
                else if ([origin isEqualToString:@"store_match"]) {
                    sortLevel=[NSNumber numberWithInt:0];
                }
                
                if (![origin isEqualToString:@"store_match"]){
                    NSString *matchStringFor;
                    BOOL matchFound=NO;
                    NSArray *arrtempCategory=[properties objectForKey:@"categories"];
                     //Check For Whole Word
                    matchStringFor=[FuzzySearchAPI WordSearchMatch:searchString inBrand:brand inCategory:category searchStore:store];
                    if ([matchStringFor isEqualToString:@""]) {
                        //Split word
                        NSArray *splitArray=[searchString componentsSeparatedByString:@" "];
                        for (NSString *sp in splitArray) {
                            matchStringFor=[FuzzySearchAPI WordSearchMatch:sp inBrand:brand inCategory:category searchStore:store];
                            if (![matchStringFor isEqualToString:@""]) {
                                matchFound=YES;
                                break;
                            }
                        }
                        
                    }
                    else{
                        matchFound=YES;
                        if ([brand count]>0) {
                            if ([brand[0] isEqualToString:matchStringFor]) {
                                if([arrtempCategory count]>0){
                                    matchStringFor=[NSString stringWithFormat:@"%@ %@",matchStringFor,[arrtempCategory objectAtIndex:0]];
                                }
                            }
                        }
                    }
                    
                    if (!matchFound) {
                        matchStringFor=store;
                    }
                   
                    if (![[matchStringFor capitalizedString] isEqualToString:store]) {
                        //store=[NSString stringWithFormat:@"%@ in %@",[matchStringFor stringByReplacingOccurrencesOfString:store withString:@""],store];
                        store=[NSString stringWithFormat:@"%@ in %@",matchStringFor,store];
                        /*if ([store hasPrefix:@" in "]) {
                            store=[store stringByReplacingOccurrencesOfString:@" in " withString:@""];
                            origin=@"store_match";
                            sortLevel=[NSNumber numberWithInt:0];
                            
                        }*/
                         store=[store stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    }
                    else{
                        origin=@"store_match";
                        sortLevel=[NSNumber numberWithInt:0];
                    }
                    
                    
                    /* Remove duplicate with same name
                    NSPredicate *filterFor=[NSPredicate predicateWithFormat:@"(store = %@)", store];
                    NSArray *resultArray=[storeinfo filteredArrayUsingPredicate:filterFor];
                    if ([resultArray count]>0) {
                        //Update only polygon
                        NSMutableDictionary *temp=[NSMutableDictionary dictionaryWithDictionary: resultArray[0]];
                        [endpoint addObjectsFromArray:[temp objectForKey:@"polygon"]];
                        [temp setObject:endpoint forKey:@"polygon"];
                        [storeinfo removeObjectsInArray:resultArray];
                        [storeinfo addObject:temp];
                        
                    }
                    else{*/
                    if ([pinPoint isEqualToString:@"-"]) {
                        pinPoint=endpoint[0];
                    }
                        NSDictionary *temp=[NSDictionary dictionaryWithObjectsAndKeys:store,@"store"
                                            ,[NSNumber numberWithInt:[level intValue]],@"floor"
                                            ,description,@"desc"
                                            ,areaId,@"id"
                                            ,storelogo,@"logo"
                                            ,origin,@"origin"
                                            ,endpoint,@"polygon"
                                            ,category,@"categories"
                                            ,brand,@"brands"
                                            ,pinPoint,@"center"
                                            ,sortLevel,@"sortat"
                                            ,locatedAt,@"locatedat"
                                            , nil];
                        
                        [storeinfo addObject:temp];
                    //}
                    
                }
                else{
                    
                    NSDictionary *temp=[NSDictionary dictionaryWithObjectsAndKeys:store,@"store"
                                        ,[NSNumber numberWithInt:[level intValue]],@"floor"
                                        ,description,@"desc"
                                        ,areaId,@"id"
                                        ,storelogo,@"logo"
                                        ,origin,@"origin"
                                        ,endpoint,@"polygon"
                                        ,category,@"categories"
                                        ,brand,@"brands"
                                        ,pinPoint,@"center"
                                        ,sortLevel,@"sortat"
                                        ,locatedAt,@"locatedat"
                                        , nil];
                    
                    [storeinfo addObject:temp];
                }
        
    
                
                
            }
        }
        
    }
    NSMutableArray *deletedPOI=[[NSMutableArray alloc] init];
    for (NSDictionary *result in storeinfo) {
        NSString *storeName=[result objectForKey:@"store"];
        NSArray *arryIn=[storeName componentsSeparatedByString:@" in "];
        if ([arryIn count]==2) {
            if ([arryIn[0] isEqualToString:arryIn[1]]) {
                [deletedPOI addObject:result];
            }
        }
    }
    if ([deletedPOI count]>0) {
        [storeinfo removeObjectsInArray:deletedPOI];
    }
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"sortat" ascending:YES];
    NSSortDescriptor *sortstore = [NSSortDescriptor sortDescriptorWithKey:@"locatedat" ascending:YES];
    NSSortDescriptor *sortByTitle = [NSSortDescriptor sortDescriptorWithKey:@"store" ascending:YES];
    NSArray *sortedArray=[storeinfo sortedArrayUsingDescriptors:@[sort,sortstore,sortByTitle]];
    
    NSMutableArray *tempSortList=[[NSMutableArray alloc] init];
    
    NSPredicate *filterForSort=[NSPredicate predicateWithFormat:@"(sortat = %d)", 0];//Only Store match
    NSMutableArray *allStoreArray=[NSMutableArray arrayWithArray:[sortedArray filteredArrayUsingPredicate:filterForSort]];
    
    filterForSort=[NSPredicate predicateWithFormat:@"(locatedat CONTAINS[cd] %@)", searchString];//Check search Word
    NSArray *containWordStore=[NSArray arrayWithArray:[allStoreArray filteredArrayUsingPredicate:filterForSort]];
    if ([containWordStore count]>0) {
        [allStoreArray removeObject:containWordStore];
        [tempSortList addObjectsFromArray:containWordStore];
        [tempSortList addObjectsFromArray:allStoreArray];
    }
    else{
        [tempSortList addObjectsFromArray:allStoreArray];
    }
    
    filterForSort=[NSPredicate predicateWithFormat:@"(sortat > %d)", 0];//others Store match
    NSMutableArray *allpoiArray=[NSMutableArray arrayWithArray:[sortedArray filteredArrayUsingPredicate:filterForSort]];
    
    filterForSort=[NSPredicate predicateWithFormat:@"(locatedat CONTAINS[cd] %@)", searchString];//Check search Word on POI
    NSArray *containWordPOI=[NSArray arrayWithArray:[allpoiArray filteredArrayUsingPredicate:filterForSort]];
    if ([containWordPOI count]>0) {
        [allpoiArray removeObject:containWordPOI];
        [tempSortList addObjectsFromArray:containWordPOI];
        [tempSortList addObjectsFromArray:allpoiArray];
    }
    else{
        [tempSortList addObjectsFromArray:allpoiArray];
    }
    
    
    
    NSMutableArray *arrFilterResult=[[NSMutableArray alloc] init];
    for (NSDictionary *result in tempSortList) {
        NSPredicate *filterFor=[NSPredicate predicateWithFormat:@"(store = %@)", [result objectForKey:@"store"]];//Remove duplicate Store if any
        NSArray *resultArray=[arrFilterResult filteredArrayUsingPredicate:filterFor];
        if ([resultArray count]==0) {
            [arrFilterResult addObject:result];
        }
        else{
            if ([[result objectForKey:@"origin"] isEqualToString:@"store_match"]) {
                NSPredicate *filterFor=[NSPredicate predicateWithFormat:@"(store = %@) and (floor = %d)", [result objectForKey:@"store"],[[result objectForKey:@"floor"] intValue]]; //Remove duplicate Store if any
                NSArray *resultArray=[arrFilterResult filteredArrayUsingPredicate:filterFor];
                if ([resultArray count]==0) {
                    [arrFilterResult addObject:result];
                }
                
            }
        }
    }
    
    return arrFilterResult;
}

+(NSString *)WordSearchMatch:(NSString *)searchString inBrand:(NSArray *)brand inCategory:(NSArray *)category searchStore:(NSString *)store{
    NSString *matchStringFor;
    BOOL matchFound=NO;
    //Check For match brand
    NSPredicate *filterFor=[NSPredicate predicateWithFormat:@"(SELF CONTAINS[cd] %@)", searchString];
    NSArray *resultArray=[brand filteredArrayUsingPredicate:filterFor];
    if ([resultArray count]>0) {
        
         matchStringFor=resultArray[0];
        /*if(![matchStringFor isEqualToString:store])
        {
            matchStringFor=resultArray[0];
            matchFound=YES;
        }
        else{*/
            if ([category count]>0) {
                //NSString *joinedString = [category componentsJoinedByString:@","];
                //matchStringFor=[NSString stringWithFormat:@"%@ %@",matchStringFor,joinedString];
                matchStringFor=[NSString stringWithFormat:@"%@ %@",matchStringFor,category[0]];
                matchFound=YES;
            }
        //}
        
    }
    if (!matchFound) {
        filterFor=[NSPredicate predicateWithFormat:@"(SELF CONTAINS[cd] %@)", searchString];
        resultArray=[category filteredArrayUsingPredicate:filterFor];
        if ([resultArray count]>0) {
                matchStringFor=resultArray[0];
            if(![[matchStringFor capitalizedString] isEqualToString:[store capitalizedString]])
            {
                if ([brand count]>0) {
                    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
                    NSArray *sortedArray=[brand sortedArrayUsingDescriptors:@[sort]];
                    NSString *joinedString = [sortedArray componentsJoinedByString:@","];
                    matchStringFor=[NSString stringWithFormat:@"%@ %@",joinedString,resultArray[0]];
                }
                matchFound=YES;
            }
        }
    }
    if (matchFound) {
        return matchStringFor;
    }
    else{
        if ([category count]>0) {
            return category[0];
        }
        return @"";
    }

}
+(CLLocationCoordinate2D)centerStorePoint:(NSArray *)coordinates{
    
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
