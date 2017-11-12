//
//  Preferences.h
//  SanginfoMap
//
//  Created by Sang.Mac.04 on 09/10/13.
//  Copyright (c) 2013 Sanginfo. All rights reserved.
//

#import <Foundation/Foundation.h>
extern NSString *const PREF_DEVICEID;
extern NSString *const PREF_MACID;
extern NSString *const PREF_SETTINGMACID;
extern NSString *const PREF_NAME;
extern NSString *const PREF_EMAIL;
extern NSString *const PREF_PHONE;
extern NSString *const PREF_ORG;
extern NSString *const PREF_DESIGNATION;
extern NSString *const PREF_MAPID;
extern NSString *const PREF_LOG_LEVEL;
extern NSString *const PREF_PASSCODE;
extern NSString *const PREF_REGISTERID;
extern NSString *const PREF_BIRTH;
extern NSString *const PREF_GENDER;
extern NSString *const PREF_ACCESSTOKEN;
extern NSString *const PREF_BUDDYOPTIN;
extern NSString *const PREF_CACHEVERSION;
extern NSString *const PREF_COUNTRYCODE;

@interface Preferences : NSObject

///Get Preferences value for given key
+(NSString *)getPreferences : (NSString *)key;
///Update Preferences Value for given key
/**
 if key is present in preferences table value get updated
 else new row get created in same table to store value
 */
+(BOOL)setPreferences : (NSString *)key forValue : (NSString *)preferencesValue;
///Update attributes value
/**List of attributes
 - Display
 - min
 - max
 - Type
 */
+(BOOL)setAttribute : (NSString *)key forValue : (NSDictionary *)preferencesValue;

///Application user name
+(NSString *)getOwnerName;
+(NSString *)getEmail;
+(NSString *)getPhone;
+(NSString *)getOrg;
+(NSString *)getTitle;
+ (NSString *) getNotificationID;
+ (NSString *) getMyMacAddress;
+ (NSString *) getSettingMacAddress;
+ (NSString *) getMap;
+ (NSString *) getPassCode;
+ (NSInteger) getDiagnosticLevel;
+ (NSInteger) getRegisterID;
+ (NSString *)getBirth;
+ (NSString *)getGender;
+ (NSString *)getAccessToken;
+ (BOOL) isBuddy_OptIn;
+ (NSInteger) getCacheVersion;
+ (NSString *) getCountryCode;
@end
