//
//  NotificationEngine.h
//  InMaps
//
//  Created by Sang.Mac.04 on 15/11/13.
//  Copyright (c) 2013 Sanginfo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol NotificationEngineProtocol <NSObject>

@optional
- (void) InMapsNotification: (NSNotification *) note;
@end

@interface NotificationEngine : NSObject{
}

+ (NotificationEngine *)sharedInstance;
-(void)StartNotificationService:(NSDictionary *)launchOptions inApp:(UIWindow *)inAppWindow;
-(void)registerWithToken:(NSData*)deviceToken;
- (void)ShowNotification:(NSDictionary*)userInfo;
- (void)ShowBackgroundNotification:(NSDictionary*)userInfo;
-(void)setNewMacAddress:(NSString *)newMac andMapID:(NSInteger)map;
//-(void)reDownloadFile:(NSString *) file;
//-(void)ActivateBeaconNotification;
//-(void)DeActivateBeaconNotification;
-(void)registerUser;
@end
