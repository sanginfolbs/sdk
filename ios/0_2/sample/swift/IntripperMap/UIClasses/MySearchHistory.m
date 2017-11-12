//
//  MySearchHistory.m
//  InMaps
//
//  Created by Sang.Mac.04 on 03/05/14.
//  Copyright (c) 2014 Sanginfo. All rights reserved.
//

#import "MySearchHistory.h"

@implementation MySearchHistory

+(NSArray *)getSearchHistory:(NSString *)cacheid{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    //2) Create the full file path by appending the desired file name
    NSString *yourArrayFileName = [documentsDirectory stringByAppendingPathComponent:cacheid];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:yourArrayFileName];
    if (fileExists) {
        NSMutableArray *tempArray=[NSMutableArray arrayWithContentsOfFile:yourArrayFileName];
        NSMutableArray *optinForDelete=[[NSMutableArray alloc] init];
        for (NSDictionary *item in tempArray) {
            if ([[item objectForKey:@"result"] objectForKey:@"result"]!=nil) {
                [optinForDelete addObject:item];
            }
        }
        if ([optinForDelete count]>0) {
            [tempArray removeObjectsInArray:optinForDelete];
        }
        return tempArray;
    }
    
    return [[NSArray alloc] init];
}

+(BOOL)SaveHistory:(NSArray *)data WithIdentifier:(NSString *)cacheid{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    //2) Create the full file path by appending the desired file name
    NSString *yourArrayFileName = [documentsDirectory stringByAppendingPathComponent:cacheid];
    
    
    //Save the array
    [data writeToFile:yourArrayFileName atomically:YES];
    
    return YES;
}
@end
