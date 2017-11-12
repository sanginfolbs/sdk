//
//  IntripperAPI.h
//  Intripper
//
//  Created by Sanginfo on 07/02/16.
//  Copyright © 2016 Sanginfo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface IntripperAPI : NSObject
/**
 *  Get Intripper API Object
 *
 *  @return API Object
 */
+ (instancetype)configuration;
/**
 *  Share Instance
 *
 *  @return API Object
 */
+ (instancetype)sharedInstance;
-(int)mapid;
-(NSString *)language;
-(void) setLanguage:(NSString *)lang;
- (instancetype)CreateInstance:(int)mapid;
-(void)RegisterDevice:(NSDictionary *)request result:(void (^)(NSArray *posts, NSError *error))response;
-(void)getStoreList:(void (^)(NSArray *posts, NSError *error))response;
-(void)getStoreListWithCategory:(NSString *)category result:(void (^)(NSArray *posts, NSError *error))response;
-(void)getStoreListWithCategoryKeyword:(NSString *)category keyword:(NSString *)q result:(void (^)(NSArray *posts, NSError *error))response;
-(void)getCategory:(void (^)(NSArray *posts, NSError *error))response;
-(void)getSearch:(NSString *)q result:(void (^)(NSArray *posts, NSError *error))response;
-(void)getMovieList:(void (^)(NSArray *posts, NSError *error))response;
/**
 *  Upload image of Profile
 *
 *  @param img
 *  @param refno
 */
-(void)uploadProfileImage:(UIImage *)img andRefNo:(NSString *)refno;
-(void)NewBuddyRequest:(NSString *)buddyCode user:(NSInteger)myid result:(void (^)(NSArray *posts, NSError *error))response;
-(void)acceptBuddyRequest:(NSString *)buddyref result:(void (^)(NSArray *posts, NSError *error))response;
-(void)rejectBuddyRequest:(NSString *)buddyref result:(void (^)(NSArray *posts, NSError *error))response;
-(void)getActiveMyBuddies:(NSInteger)myid result:(void (^)(NSArray *posts, NSError *error))response;
-(void)getPendingMyBuddies:(NSInteger)myid result:(void (^)(NSArray *posts, NSError *error))response;
-(void)BuddiesDeleteRequest:(NSInteger)myid result:(void (^)(NSArray *posts, NSError *error))response;
-(void)BuddiesResendRequest:(NSInteger)myid result:(void (^)(NSArray *posts, NSError *error))response;
-(void)offerList:(void (^)(NSArray *posts, NSError *error))response;
-(void)RequestApiCall:(NSDictionary *)param result:(void (^)(NSArray *posts, NSError *error))response;
-(void)getServerMsg:(void (^)(NSArray *posts, NSError *error))response;
-(void)getMapLanguage:(int)mapRef Local:(NSString *)locallanguage result:(void (^)(NSArray *posts, NSError *error))response;
@end
