//
//  Common.h
//  TapConnect
//
//  Created by Donald Pae on 4/27/14.
//  Copyright (c) 2014 donald. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DATETIME_FORMAT @"yyyy-MM-dd HH:mm:ss"
#define DATE_FORMAT     @"yyyy-MM-dd"

// nearby equipment's location type
#define kLocationTypeCurrentLocation      @"CURRENT LOCATION"
#define kLocationTypeImmediateVicinity      @"IMMEDIATE VICINITY"

// remote notification's alert type
#define kRemoteNotificationTypeKey          @"alert_type"
#define kRemoteNotificationTypeAlert        @"alert"
#define kRemoteNotificationTypeWatch        @"watch"
#define kRemoteNotificationTypeForcedLogout @"forcedloggedout"
#define kRemoteNotificationLocation         @"locationtracked"

// notifications
#define kTriggeredAlertChanged  @"triggeredalertchanged"
#define kDataChanged        @"data changed"
#define kLocatingChanged    @"locating changed"
#define kVicinityBeaconsChanged @"vicinity beacons changed"
#define kFoundEquipmentsChanged @"found equipments changed"
#define kCurrentLocationChanged @"current location changed"

// keys from server
#define kDeviceListDeviceNameKey    @"device_name"
#define kDeviceListUserDeviceIdKey  @"user_device_id"
#define kDeviceListDeviceTokenKey   @"device_token"

#define USE_PUSHANIMATION_FOR_DETAILVIEW    0

@interface Common : NSObject

+ (BOOL)hasConnectivity;
+ (NSString *)date2str:(NSDate *)convertDate withFormat:(NSString *)formatString;
+ (NSDate *)str2date:(NSString *)dateString withFormat:(NSString *)formatString;
@end
